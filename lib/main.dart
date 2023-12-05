import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_push_notification/utils/assets.dart';
import 'package:flutter/material.dart';

import 'FCM.dart';
import 'messaging_service/notification_services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

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
    print('my app initState');
    WidgetsFlutterBinding.ensureInitialized();
    // configLoading();

    final firebaseMessaging = FCM();

    firebaseMessaging.setNotifications();

    firebaseMessaging.streamCtlr.stream.listen(_changeData);
    firebaseMessaging.bodyCtlr.stream.listen(_changeBody);
    firebaseMessaging.titleCtlr.stream.listen(_changeTitle);

  }

  // Function to initialize Firebase and get Firestore instance
  FirebaseFirestore getFirestoreInstance() {
    return FirebaseFirestore.instance;
  }

  // Function to fetch data from Firestore
  Stream<QuerySnapshot> fetchDataFromFirestore() {
    return getFirestoreInstance().collection('ImageList').snapshots();
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
      body:StreamBuilder<QuerySnapshot>(
        stream: fetchDataFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // If data is available, display it in a ListView
          final data = snapshot.data!;

          // print(">>>>>>>>>>>>>>>>>${data.docs}<<<<<<<<<<<<<<<<<<<");
          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              // Access each document in the snapshot
              final document = data.docs[index];
              // You can access specific fields using document.data()['field_name']

              final countryData = document.data() as Map<String, dynamic>?;
              // Check if countryData is not null and 'name' field exists
              final imageLinkId = countryData?['imageLink'] ?? '';
              final name = countryData?['name'] ?? '';


              final documentId = document.id;


              return Row(
                children: [
                  Expanded(child: Container(
                    margin: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),

                    height: 150,
                    // width: 150,

                    child:Column(
                      children: [
                        Expanded(child: Row(
                          children: [
                            Expanded(child: InkWell(
                              onTap: (){
                                updateDataInFirestore(documentId);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FadeInImage.assetNetwork(
                                  fit: BoxFit.fill,
                                  placeholder: Assets.loadingImage,


                                  // image:"https://drive.google.com/uc?export=view&id=1VxXLQglhtZHR7_xIUToZIXhA10yxRzWf",
                                  image:"https://drive.google.com/uc?export=view&id=$imageLinkId",

                                  imageErrorBuilder: (context, url, error) =>
                                      Image.asset(
                                        Assets.emptyImage,
                                        fit: BoxFit.fill,
                                      ),
                                ),
                              ),
                            ))
                          ],
                        )),
                        Text(name)

                      ],
                    ),
                  ))
                ],
              );


                ListTile(
                title: Text(imageLinkId),
                // subtitle: Text(document.data()['description']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:(){
          addDataToFirestore();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }




  // Inside FirestoreExample class
// Function to add data to a collection in Firestore with an auto-generated document ID
  Future<void> addDataToFirestore() async {
    try {
      await getFirestoreInstance().collection('ImageList').add({
        'imageLink': '1VxXLQglhtZHR7_xIUToZIXhA10yxRzWf',
        'name': 'value2',
        // Add more fields as needed
      });
      print('Data added successfully!');
    } catch (e) {
      print('Error adding data: $e');
    }
  }



  // Function to update data in a specific document in Firestore
  Future<void> updateDataInFirestore(String documentId) async {
    try {
      await getFirestoreInstance().collection('ImageList').doc(documentId).update({
        'imageLink': '1VxXLQglhtZHR7_xIUToZIXhA10yxRzWf',
        'name': 'Flower',
        // Add more fields to update as needed
      });
      print('Data updated successfully!');
    } catch (e) {
      print('Error updating data: $e');
    }
  }


}




