enum DeepLinkType {
  job,
  notification,
  customer,
  report,
  unknown;

  static DeepLinkType parse(String path) {
    final lower = path.toLowerCase();
    if (lower.contains('job')) return DeepLinkType.job;
    if (lower.contains('notification')) return DeepLinkType.notification;
    if (lower.contains('customer')) return DeepLinkType.customer;
    if (lower.contains('report')) return DeepLinkType.report;
    return DeepLinkType.unknown;
  }
}

class ParsedDeepLink {
  final String rawUrl;
  final DeepLinkType type;
  final String targetId;
  final Map<String, String> queryParameters;

  ParsedDeepLink({
    required this.rawUrl,
    required this.type,
    required this.targetId,
    this.queryParameters = const {},
  });

  factory ParsedDeepLink.fromUriString(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      final host = uri.host.isEmpty ? (uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '') : uri.host;
      final type = DeepLinkType.parse(host.isNotEmpty ? host : uri.path);
      
      String id = '';
      if (uri.pathSegments.length > 1) {
        id = uri.pathSegments[1];
      } else if (uri.pathSegments.isNotEmpty && uri.pathSegments.first != host) {
        id = uri.pathSegments.first;
      } else if (uri.queryParameters.containsKey('id')) {
        id = uri.queryParameters['id']!;
      } else {
        id = 'DEFAULT-101';
      }

      return ParsedDeepLink(
        rawUrl: uriString,
        type: type,
        targetId: id,
        queryParameters: uri.queryParameters,
      );
    } catch (_) {
      return ParsedDeepLink(
        rawUrl: uriString,
        type: DeepLinkType.unknown,
        targetId: '',
      );
    }
  }
}
