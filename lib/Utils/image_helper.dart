class ImageHelper {
  static const String _baseUrl = "https://api.grabatoz.ae";

  static String getUrl(String url) {
    if (url.isEmpty) return "";

    if (url.startsWith('http')) {
      return url;
    }

    return _baseUrl + url.replaceAll('//', '/');
  }
}
