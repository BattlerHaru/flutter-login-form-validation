import 'dart:convert';
import 'dart:io';
import 'package:formvalidation/src/preferencias_usuario/preferencias_usuario.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';

import 'package:formvalidation/src/models/producto_model.dart';

class ProductosProvider {
  // EXAMPLE
  // https://YOUR-DATABASE-PROJECT.firebaseio.com
  final String _url = '<YOUR DATABASE FIREBASE URL>';

  final _prefs = new PreferenciasUsuario();

  Future<bool> crearProducto(ProductoModel producto) async {
    final url = '$_url/productos.json?auth=${_prefs.token}';
    final resp = await http.post(url, body: productoModelToJson(producto));

    final decodeData = json.decode(resp.body);
    print(decodeData);

    return true;
  }

  Future<bool> editarProducto(ProductoModel producto) async {
    final url = '$_url/productos/${producto.id}.json?auth=${_prefs.token}';
    final resp = await http.put(url, body: productoModelToJson(producto));

    final decodeData = json.decode(resp.body);
    print(decodeData);

    return true;
  }

  Future<List<ProductoModel>> cargarProductos() async {
    final url = '$_url/productos.json?auth=${_prefs.token}';
    final resp = await http.get(url);

    final Map<String, dynamic> decodeData = json.decode(resp.body);
    final List<ProductoModel> productos = new List();

    if (decodeData == null) return [];
    if (decodeData['error'] != null) return [];

    decodeData.forEach((id, prod) {
      final prodTemp = ProductoModel.fromJson(prod);
      prodTemp.id = id;

      productos.add(prodTemp);
    });

    return productos;
  }

  Future<int> borrarProducto(String id) async {
    final url = '$_url/productos/$id.json?auth=${_prefs.token}';
    final resp = await http.delete(url);

    return 1;
  }

  Future<String> subirImagen(File img) async {
    // EXAMPLE
    // https://api.cloudinary.com/v1_1/<USER>/image/upload?upload_preset=<USER-UPLOAD-PRESET>
    final url = Uri.parse('<YOUR API CLOUDINARY>');

    final mimeType = mime(img.path).split('/');

    final imgUploadRequest = http.MultipartRequest(
      'POST',
      url,
    );

    final file = await http.MultipartFile.fromPath(
      'file',
      img.path,
      contentType: MediaType(
        mimeType[0],
        mimeType[1],
      ),
    );

    imgUploadRequest.files.add(file);

    final streamResponse = await imgUploadRequest.send();

    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salio mal');
      print(resp.body);
      return null;
    }

    final respData = json.decode(resp.body);
    return respData['secure_url'];
  }
}
