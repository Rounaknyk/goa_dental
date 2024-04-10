import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/providers/add_patient_provider.dart';
import 'package:goa_dental_clinic/providers/add_plan_provider.dart';
import 'package:goa_dental_clinic/providers/add_pre_provider.dart';
import 'package:goa_dental_clinic/providers/pd_provider.dart';
import 'package:goa_dental_clinic/providers/user_provider.dart';
import 'package:goa_dental_clinic/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  return runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => AddPatientProvider()),
    ChangeNotifierProvider(create: (context) => AddPlanProvider()),
    ChangeNotifierProvider(create: (context) => AddPreProvider()),
    ChangeNotifierProvider(create: (context) => UserProvider()),
    ChangeNotifierProvider(create: (context) => PdProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: kPrimaryColor,
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: kPrimaryColor,),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(kPrimaryColor),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
