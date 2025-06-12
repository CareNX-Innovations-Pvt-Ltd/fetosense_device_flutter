import 'package:appwrite/appwrite.dart';

/// A service class for configuring and providing an Appwrite [Client] instance.
///
/// This class initializes the Appwrite client with the specified endpoint,
/// project ID, and self-signed certificate settings. Use the [instance] getter
/// to access the configured [Client] throughout the application.
///
/// Example usage:
/// ```dart
/// final appwriteClient = AppwriteService().instance;
///
class AppwriteService {
  final Client client;

  AppwriteService()
      : client = Client()
    ..setEndpoint('http://172.172.241.56/v1')
    ..setProject('67ecd82100347201f279')
    ..setSelfSigned(status: true);

  Client get instance => client;
}
