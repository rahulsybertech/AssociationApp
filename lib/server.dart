import 'dart:convert';
import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

/*void main(List<String> args) async {
  final app = Router();

  // GET API Example
  app.get('/hello', (Request request) {
    return Response.ok('Hello from Dart Backend');
  });

  // POST API Example
  app.post('/echo', (Request request) async {
    final body = await request.readAsString();
    return Response.ok('You sent: $body');
  });

  // Start server
  final server = await io.serve(
    const Pipeline()
        .addMiddleware(logRequests()) // Logs all requests
        .addHandler(app),
    InternetAddress.anyIPv4,
    8080,
  );

  print('✅ Server running on http://${server.address.host}:${server.port}');
}*/

void main(List<String> args) async {
  final app = Router();

  // POST /login API
  app.post('/login', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    final username = data['username'];
    final password = data['password'];

    // Hardcoded check (replace with DB query later)
    if (username == 'admin' && password == '1234') {
      // Create JWT token
      final jwt = JWT({'username': username});
      final token = jwt.sign(SecretKey('my_secret_key'));

      return Response.ok(
        jsonEncode({'status': 'success', 'token': token}),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      return Response.forbidden(
        jsonEncode({'status': 'error', 'message': 'Invalid credentials'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Start server
  final server = await io.serve(
    const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(app),
    InternetAddress.anyIPv4,
    8080,
  );

  print('✅ Server running on http://${server.address.host}:${server.port}');
}