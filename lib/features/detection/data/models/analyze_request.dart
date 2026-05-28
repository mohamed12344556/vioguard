class AnalyzeRequest {
  final String url;

  const AnalyzeRequest({required this.url});

  Map<String, dynamic> toJson() => {'url': url};
}
