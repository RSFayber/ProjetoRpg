import 'dart:convert';

import 'package:flutter/services.dart';

class AssetJsonDatasource {
  AssetJsonDatasource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<List<Map<String, dynamic>>> loadList(String path) async {
    final raw = await _bundle.loadString(path);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }
}
