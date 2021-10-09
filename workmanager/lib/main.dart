import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

var client = http.Client();
callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    DateTime ido = DateTime.now();
    var uriResponse = await client.get(Uri.parse(task));
    var responseData = json.decode(uriResponse.body);
    if (responseData['status'] != 'ok') {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('your channel id', 'your channel name',
              'your channel description',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: false);
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await notificationsPlugin.show(0, responseData['status'],
          'Szolgaltatas leallt: ' + ido.toString(), platformChannelSpecifics,
          payload: 'item x');
    }
    return Future.value(true);
  });
}

void initializeSetting() async {
  var initializeAndroid = AndroidInitializationSettings('ic_launcher');
  var initializeSetting = InitializationSettings(android: initializeAndroid);
  await notificationsPlugin.initialize(initializeSetting);
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final myController = TextEditingController();

  @override
  void initState() {
    initializeSetting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('automatic api request'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: myController,
                decoration: InputDecoration(
                  labelText: 'Figyelt webcím',
                  labelStyle: TextStyle(color: Colors.green),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () => {
                        Workmanager().registerPeriodicTask(
                            "1", myController.text,
                            initialDelay: Duration(seconds: 3),
                            existingWorkPolicy: ExistingWorkPolicy.replace)
                      },
                  child: Text('Figyelés inditása')),
            ],
          ),
        ),
      ),
    );
  }
}
