class PicsumImage {
  late int id;
  late String author;
  late int width;
  late int height;
  late String url;
  late String downloadUrl;

  PicsumImage({
    required this.id,
    required this.author,
    required this.width,
    required this.height,
    required this.url,
    required this.downloadUrl,
  });

  PicsumImage.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    author = json['author'];
    width = json['width'];
    height = json['height'];
    url = json['url'];
    downloadUrl = json['download_url'];
  }
}
