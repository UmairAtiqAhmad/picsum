import 'package:http/http.dart' as http;

class LoremPicsum {
  final String _baseUrl = 'picsum.photos';

  Future<dynamic> _getRequest(String url, {Map<String, String>? query}) async {
    var uri = Uri.https(_baseUrl, url, query);
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<dynamic> getImageList({required int page, int limit = 50}) async {
    var url = '/v2/list';
    var query = {'page': '$page', 'limit': '$limit'};
    var response = await _getRequest(url, query: query);

    return response;
  }
}
