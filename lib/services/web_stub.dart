// Web stub for dart:io classes that don't exist on web
import 'dart:typed_data';

class File {
  final String path;

  File(this.path);

  Future<void> copy(String newPath) {
    throw UnsupportedError('File operations not supported on web');
  }

  Future<Uint8List> readAsBytes() {
    throw UnsupportedError('File operations not supported on web');
  }

  Future<bool> exists() async {
    return false; // On web, we don't have file system access
  }

  bool existsSync() {
    return false; // On web, we don't have file system access
  }

  Future<void> delete() async {
    // No-op on web
  }
}

class SocketException implements Exception {
  final String message;
  SocketException(this.message);
}

class InternetAddress {
  static Future<List<InternetAddress>> lookup(String host) {
    throw UnsupportedError('InternetAddress.lookup not supported on web');
  }

  List<int> get rawAddress =>
      throw UnsupportedError('rawAddress not supported on web');
}
