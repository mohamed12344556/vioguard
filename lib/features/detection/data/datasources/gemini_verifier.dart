import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/config/gemini_config.dart';
import '../models/gemini_verification.dart';

/// Asks Google Gemini to act as a "second opinion" on the primary AI model's
/// violence classification, for both text and video results.
///
/// Talks to Gemini over its plain HTTPS REST endpoint via Dio rather than the
/// `google_generative_ai` package: that package uses gRPC, which fails with
/// "Connection refused" on some Android emulators. The REST call works there.
///
/// This is a best-effort verification layer: if Gemini is disabled (no key),
/// errors out, or returns an unparseable reply, callers get `null` and should
/// simply not show the second-opinion card.
class GeminiVerifier {
  final Dio _dio = Dio();

  /// Models tried in order. The free tier rate-limits each model separately
  /// (~20 req/min), so when the primary returns 429 we fall back to the next
  /// model, which has its own quota.
  static const List<String> _models = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-flash-latest',
  ];

  /// REST endpoint for a given model: `…/models/<model>:generateContent`.
  String _endpointFor(String model) =>
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$model:generateContent';

  bool get isEnabled => GeminiConfig.isEnabled;

  /// Verifies a TEXT classification. [text] is the analyzed content,
  /// [modelSaysViolent] is the primary model's verdict.
  Future<GeminiVerification?> verifyText({
    required String text,
    required bool modelSaysViolent,
  }) {
    final prompt =
        '''
You are a content-safety reviewer. Another AI model analyzed the TEXT below and
classified it as ${modelSaysViolent ? 'VIOLENT' : 'NOT VIOLENT'}.

Independently decide whether the text contains violence, threats, or aggressive
intent. Be objective. Then reply ONLY with a JSON object of this exact shape:
{
  "is_violent": <true|false>,
  "confidence": <number between 0 and 1>,
  "reason": "<one or two short sentences explaining your verdict in the user's language>",
  "violent_words": [<the exact words or short phrases from the TEXT that signal violence/threats/aggression; copy them verbatim as they appear in the TEXT, in any language; empty array if none>]
}

TEXT TO REVIEW:
"""
$text
"""
''';
    return _ask(prompt, modelSaysViolent: modelSaysViolent);
  }

  /// Verifies a VIDEO classification using the model's reported scores and the
  /// source context (we don't upload the video itself in this layer).
  Future<GeminiVerification?> verifyVideo({
    required bool modelSaysViolent,
    required double violenceScore,
    required double nonViolenceScore,
    required double confidence,
    String? sourceUrl,
  }) {
    String pct(double v) => (v * 100).toStringAsFixed(1);
    final prompt =
        '''
You are a content-safety reviewer. A video-violence-detection AI model analyzed
a video and produced these results:
- Verdict: ${modelSaysViolent ? 'VIOLENT' : 'NOT VIOLENT'}
- Violence score: ${pct(violenceScore)}%
- Non-violence score: ${pct(nonViolenceScore)}%
- Overall confidence: ${pct(confidence)}%
${sourceUrl != null && sourceUrl.isNotEmpty ? '- Source URL: $sourceUrl' : ''}

Based on these scores and any context you can infer, judge whether the model's
verdict is reasonable and well-supported. Reply ONLY with a JSON object of this
exact shape:
{
  "is_violent": <true|false  (your assessment of whether the video is violent)>,
  "confidence": <number between 0 and 1>,
  "reason": "<one or two short sentences explaining whether the model's verdict looks sound>"
}
''';
    return _ask(prompt, modelSaysViolent: modelSaysViolent);
  }

  Future<GeminiVerification?> _ask(
    String prompt, {
    required bool modelSaysViolent,
  }) async {
    if (!isEnabled) return null;

    // Rotate over (key × model). When a key hits its free-tier quota (429) on
    // a model, move to the next model on the same key; once all models on a key
    // are exhausted, move to the NEXT KEY. This keeps verification working as
    // long as any key still has quota left.
    for (final key in GeminiConfig.keys) {
      for (final model in _models) {
        try {
          final raw = await _callModel(key, model, prompt);
          if (raw == null || raw.isEmpty) continue; // bad shape → next model
          final jsonStr = _extractJson(raw);
          if (jsonStr == null) continue;
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          debugPrint('🔎 GEMINI verdict ($model): $map');
          return GeminiVerification.fromJson(
            map,
            modelSaysViolent: modelSaysViolent,
          );
        } on DioException catch (e) {
          final status = e.response?.statusCode;
          // 429 = this key's quota for this model is spent; try next model,
          // then next key. Other HTTP errors: also just move on.
          debugPrint('⚠️ GEMINI ${_mask(key)}/$model failed (HTTP $status)');
          continue;
        } catch (e) {
          debugPrint('⚠️ GEMINI ${_mask(key)}/$model failed: $e');
          continue;
        }
      }
    }
    debugPrint('⚠️ GEMINI: all keys/models exhausted, no verdict');
    return null;
  }

  /// Masks a key for logging (shows only the last 4 chars).
  String _mask(String key) =>
      key.length <= 4 ? '****' : '…${key.substring(key.length - 4)}';

  /// One POST to a specific model with a specific key. Returns the model's raw
  /// text reply (the JSON string we asked for), or null on unexpected shape.
  Future<String?> _callModel(String key, String model, String prompt) async {
    final response = await _dio.post(
      _endpointFor(model),
      queryParameters: {'key': key},
      options: Options(
        headers: {'Content-Type': 'application/json'},
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
      data: {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          // Low temperature → more deterministic, fact-checking-style answers.
          'temperature': 0.2,
          'responseMimeType': 'application/json',
        },
      },
    );

    // Gemini's REST shape: candidates[0].content.parts[0].text holds the JSON.
    final data = response.data as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    return (candidates != null && candidates.isNotEmpty)
        ? ((candidates.first['content']?['parts'] as List?)?.first?['text']
                  as String?)
              ?.trim()
        : null;
  }

  /// Gemini usually returns clean JSON (we request it), but it can wrap the
  /// object in markdown fences. Pull out the first {...} block defensively.
  String? _extractJson(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    return raw.substring(start, end + 1);
  }
}
