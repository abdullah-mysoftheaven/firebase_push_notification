import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'FCM.dart';
import 'messaging_service/notification_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Firebase Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  static final navKey = GlobalKey<NavigatorState>();
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  var isTapped = '';
  var notificationTitle = 'No Title';
  var notificationBody = 'No Body';
  var notificationData = 'No Data';

  _changeData(String msg) {
    notificationData = msg;
    print("notificationData:: "+notificationData);
  }

  _changeBody(String msg) {
    notificationBody = msg;
    final context = MyHomePage.navKey.currentState?.overlay?.context;
    print("notificationBody:: $notificationBody");
    // _showAlert(Get.context!, notificationTitle, notificationBody, notificationData);
  }

  _changeTitle(String msg) {
    notificationTitle = msg;
    print("notificationTitle:: "+notificationTitle);
  }

  void initState() {
    print('vumiseba app initState');
    WidgetsFlutterBinding.ensureInitialized();
    // configLoading();

    final firebaseMessaging = FCM();

    firebaseMessaging.setNotifications();

    firebaseMessaging.streamCtlr.stream.listen(_changeData);
    firebaseMessaging.bodyCtlr.stream.listen(_changeBody);
    firebaseMessaging.titleCtlr.stream.listen(_changeTitle);

  }

  @override
  Widget build(BuildContext context) {
    NotificationServices notificationServices = NotificationServices();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Flutter Firebase project',
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:(){},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), 
    );
  }
}




