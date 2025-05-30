import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Firebase Messaging Background Handler
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  
  runApp(MyApp());
}

// Background message handler (for when app is in the background or terminated)
Future<void> backgroundMessageHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.notification?.title}");
  // Handle background message here (e.g., show notification)
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notifications Demo',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize Firebase Messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a message while in the foreground: ${message.notification?.title}");
      // Handle foreground message here (e.g., show dialog or in-app notification)
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message clicked! ${message.notification?.title}");
      // Handle notification tap here (e.g., navigate to a screen)
    });

    // Get the token for FCM
    FirebaseMessaging.instance.getToken().then((String? token) {
      print("FCM Token: $token");
      // You can send this token to your server for targeting specific devices
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Push Notifications Demo")),
      body: Center(child: Text("Push notifications will appear here")),
    );
  }
}