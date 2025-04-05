import 'package:appwrite/appwrite.dart';

class AppwriteService {
  final Client client;

  AppwriteService()
      : client = Client()
    ..setEndpoint('http://172.172.241.56/v1')
    ..setProject('67ecd82100347201f279')
    ..setSelfSigned(status: true); // For self-signed certificates (dev use only)

  Client get instance => client;
}
