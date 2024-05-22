import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';

//////////////////////variable space////////////////////////////////////////////
//푸쉬알림 컨트롤러
late FlutterLocalNotificationsPlugin notiController;
//푸쉬알림 리스너. 핸들러 등록용.
late StreamController<String?> streamForSelectedNoti;
//푸쉬알림 채널 컨트롤러
late AndroidNotificationChannel notiChannel;
//개별 푸쉬알림 인스턴스(코드짤때는 안쓸꺼임. 걍 어떤 클래스의 객체인지 기록해두려고)
late AndroidNotificationDetails thisIsNotificationDetailForAndroid;
late NotificationDetails thisIsNotificationDetail;
//ID
const int notiId = 1; //개별 푸쉬알림 ID
const String notiChId = 'ntCh'; //알림 채널 ID
const String notiStreamId = 'ntStream'; //알림스트림(리스너) ID

//fcm token
late String fcmToken;

//////////////////////function space////////////////////////////////////////////
//단일 푸쉬알림 띄우기
Future<void> showNoti() async {
  //notification의 detail들을 설정 후 show함수에 파라미터로 넘겨줌.
  var notiDetailForAnd = const AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  var notiDetail = NotificationDetails(android: notiDetailForAnd);

  await notiController.show(
    notiId,
    'plain title',
    'plain body',
    notiDetail,
    payload: 'item x',
  );
  debugPrint('[log] notified');
}

Future<void> showNotiWithMessage({required RemoteMessage message}) async {
  //notification의 detail들을 설정 후 show함수에 파라미터로 넘겨줌.
  var notiDetailForAnd = const AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  var notiDetail = NotificationDetails(android: notiDetailForAnd);

  await notiController.show(
    notiId,
    message.notification!.title,
    message.notification!.body,
    notiDetail,
    payload: 'item x',
  );
  debugPrint('[log] notified');
}

//알림을 클릭했을 때
void onNotiTapped(NotificationResponse notificationResponse) {
  debugPrint('[log] notification tapped');
  //리스너 대기열(스트림)에 추가
  streamForSelectedNoti.add(notificationResponse.payload);
}

//클릭 이외의 다른 동작에 대한 핸들러
// @pragma('vm:entry-point')
// void interactNotiWithoutTap(NotificationResponse notificationResponse) {
//   debugPrint('[log] interact with Notification(exclude tap) in background');
// }

//get notify permission
void getNotiPermission() {
  notiController
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .requestNotificationsPermission();
  debugPrint('[log] User granted notification permission');
}

//get fcm permission
Future<void> getFcmPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  debugPrint('[log] User granted fcm permission');
  debugPrint('[log] ${settings.authorizationStatus}');
}

@pragma('vm:entry-point')
Future<void> _setFcmListenerInBackground(RemoteMessage message) async {
  debugPrint("[log] got a message in background");

  if (message.notification != null) {
    debugPrint('[log] Got a notification in message');
    final backNotiController = FlutterLocalNotificationsPlugin();
    var notiDetailForAnd = const AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var notiDetail = NotificationDetails(android: notiDetailForAnd);

    await backNotiController.show(
      notiId,
      message.notification!.title,
      message.notification!.body,
      notiDetail,
      payload: 'item x',
    );
  }
}

//////////////////////main//////////////////////////////////////////////////////
Future<void> main() async {
  //init flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  //init variable
  streamForSelectedNoti = StreamController<String?>.broadcast(); //listener
  notiChannel = const AndroidNotificationChannel(
    notiChId, // id
    'MY FOREGROUND SERVICE', // title
    description: 'notification ch',
    importance: Importance.low,
  ); //channel
  notiController = FlutterLocalNotificationsPlugin(); //controller
  await notiController.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
    ),
    onDidReceiveNotificationResponse: onNotiTapped,
    //onDidReceiveBackgroundNotificationResponse: interactNotiWithoutTap,
  );

  //fcm init

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  fcmToken = (await FirebaseMessaging.instance.getToken())!; //fcmtoken 받아오기.
  debugPrint('[log] $fcmToken');
  FirebaseMessaging.instance.onTokenRefresh
      .listen((fcmToken) {})
      .onError((err) {});
  FirebaseMessaging.onBackgroundMessage(_setFcmListenerInBackground);

  //run
  runApp(const MaterialApp(home: TestApp()));
}

//App class
class TestApp extends StatefulWidget {
  const TestApp({super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

//App레벨에서 listener 등록해야 전체 앱에서 작동할듯?
class _TestAppState extends State<TestApp> {
  Future<void> _notifyEachTime() async {
    //timer 자체가 백그라운드상태에서 isolate하게 동작하는 비동기 작업
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      debugPrint('[log] Timer tick : $timer');
      await showNoti();
    });
  }

  //리스너로 받은 신호 핸들링
  void _setNotiListener() {
    streamForSelectedNoti.stream.listen((String? payload) async {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => SubPage(payload),
      ));
    });
  }

  void _setFcmListenerInForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[log] Got a message in the foreground');

      if (message.notification != null) {
        debugPrint('[log] Got a notification in message');
        showNotiWithMessage(message: message);
      }
    });
  }

  Future<void> _setFcmListenerInTerminated() async {
    //app이 terminate 상태로부터 열리도록 하는 메시지를 가져온다.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => SubPage(''),
    ));
  }

  @override
  void initState() {
    super.initState();
    _setNotiListener();
    _setFcmListenerInForeground();

    //_setFcmListenerInTerminated();

    //_notifyEachTime();
  }

  @override
  Widget build(BuildContext context) {
    return const MainPage();
  }
}

//main stf page
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const Spacer(),
          const Text('hi'),
          const ElevatedButton(
            onPressed: showNoti,
            child: Text('show'),
          ),
          const ElevatedButton(
            onPressed: getNotiPermission,
            child: Text('get notify permission'),
          ),
          ElevatedButton(
            onPressed: () async => getFcmPermission(),
            child: const Text('get fcm permission'),
          ),
          const Spacer(),
        ],
      )),
    );
  }
}

//sub stl page. when notification tapped
class SubPage extends StatelessWidget {
  var payload; //알람으로부터 넘겨받은 데이터

  SubPage(this.payload, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('back'),
        ),
      ),
    );
  }
}
