import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import './components/bottom_nav_bar.dart';
import './utils/keys.dart';

import './providers/property_provider.dart';
import './providers/filter_provider.dart'; // ← add this
import './services/property_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(seconds: 3));
  await dotenv.load(fileName: ".env");

  // 2️⃣ Check that the key is in memory
  // sanity-check that you actually got a key
  assert(
    dotenv.env['GOOGLE_MAPS_API_KEY']?.isNotEmpty == true,
    'You must define GOOGLE_MAPS_API_KEY in .env',
  );
  print('Maps key loaded'); // silently confirm in dev

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: false,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $fcmToken");
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final user = FirebaseAuth.instance.currentUser;
  if (user != null && user.phoneNumber == '+919999888877') {
    await fixCommercialSpaceProperties();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PropertyProvider>(
          create: (_) => PropertyProvider(),
        ),
        ChangeNotifierProvider<FilterProvider>(
          // ← register it here
          create: (_) => FilterProvider(),
        ),
        Provider<PropertyService>(
          create: (_) => PropertyService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LANDANDPLOT',
      theme: ThemeData(
        fontFamily: 'Lato',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: BottomNavBar(key: bottomNavBarKey),
    );
  }
}

Future<void> fixCommercialSpaceProperties() async {
  final query = await FirebaseFirestore.instance
      .collection('properties')
      .where('propertyType', isEqualTo: 'Commercial Space')
      .get();

  for (final doc in query.docs) {
    await doc.reference.update({'propertyType': 'Commercial'});
    print('✅ Updated property: ${doc.id}');
  }

  print('🎉 Done updating all Commercial Space entries');
}
