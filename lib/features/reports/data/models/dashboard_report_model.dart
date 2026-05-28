class VideoSummary {
  final int totalVideos;
  final int violentIncidents;
  final int nonViolentAnalyses;

  const VideoSummary({
    required this.totalVideos,
    required this.violentIncidents,
    required this.nonViolentAnalyses,
  });

  factory VideoSummary.fromJson(Map<String, dynamic> json) {
    return VideoSummary(
      totalVideos: (json['totalVideos'] as num?)?.toInt() ?? 0,
      violentIncidents: (json['violentIncidents'] as num?)?.toInt() ?? 0,
      nonViolentAnalyses: (json['nonViolentAnalyses'] as num?)?.toInt() ?? 0,
    );
  }
}

class TextSummary {
  final int totalTexts;
  final int violentIncidents;
  final int againstViolenceAnalyses;
  final int neutralTextAnalyses;

  const TextSummary({
    required this.totalTexts,
    required this.violentIncidents,
    required this.againstViolenceAnalyses,
    required this.neutralTextAnalyses,
  });

  factory TextSummary.fromJson(Map<String, dynamic> json) {
    return TextSummary(
      totalTexts: (json['totalTexts'] as num?)?.toInt() ?? 0,
      violentIncidents: (json['violentIncidents'] as num?)?.toInt() ?? 0,
      againstViolenceAnalyses:
          (json['againstViolenceAnalyses'] as num?)?.toInt() ?? 0,
      neutralTextAnalyses:
          (json['neutralTextAnalyses'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardReportModel {
  final int totalAnalyses;
  final int totalViolentIncidents;
  final int totalNonViolentAnalyses;
  final int totalAgainstViolenceAnalyses;
  final int totalNeutralTextAnalyses;
  final double violencePercentage;
  final VideoSummary videoSummary;
  final TextSummary textSummary;
  final bool enableMonthlyReports;
  final DateTime dateFrom;
  final DateTime dateTo;

  const DashboardReportModel({
    required this.totalAnalyses,
    required this.totalViolentIncidents,
    required this.totalNonViolentAnalyses,
    required this.totalAgainstViolenceAnalyses,
    required this.totalNeutralTextAnalyses,
    required this.violencePercentage,
    required this.videoSummary,
    required this.textSummary,
    required this.enableMonthlyReports,
    required this.dateFrom,
    required this.dateTo,
  });

  factory DashboardReportModel.fromJson(Map<String, dynamic> json) {
    return DashboardReportModel(
      totalAnalyses: (json['totalAnalyses'] as num?)?.toInt() ?? 0,
      totalViolentIncidents:
          (json['totalViolentIncidents'] as num?)?.toInt() ?? 0,
      totalNonViolentAnalyses:
          (json['totalNonViolentAnalyses'] as num?)?.toInt() ?? 0,
      totalAgainstViolenceAnalyses:
          (json['totalAgainstViolenceAnalyses'] as num?)?.toInt() ?? 0,
      totalNeutralTextAnalyses:
          (json['totalNeutralTextAnalyses'] as num?)?.toInt() ?? 0,
      violencePercentage:
          (json['violencePercentage'] as num?)?.toDouble() ?? 0.0,
      videoSummary: VideoSummary.fromJson(
          json['videoSummary'] as Map<String, dynamic>? ?? {}),
      textSummary: TextSummary.fromJson(
          json['textSummary'] as Map<String, dynamic>? ?? {}),
      enableMonthlyReports: json['enableMonthlyReports'] as bool? ?? false,
      dateFrom: DateTime.tryParse(json['dateFrom'] as String? ?? '') ??
          DateTime.now(),
      dateTo: DateTime.tryParse(json['dateTo'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
