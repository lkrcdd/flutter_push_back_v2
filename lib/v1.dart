//flutter_background_service & local_notification
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

//////////////////////variable space////////////////////////////////////////////
//푸쉬알림 컨트롤러
final FlutterLocalNotificationsPlugin notiController =
    FlutterLocalNotificationsPlugin();
//푸쉬알림 리스너. 핸들러 등록용.
final StreamController<String?> streamForSelectedNoti =
    StreamController<String?>.broadcast();
//푸쉬알림 채널 컨트롤러
late AndroidNotificationChannel notiChannel;
//개별 푸쉬알림 인스턴스(코드짤때는 안쓸꺼임. 걍 어떤 클래스의 객체인지 기록해두려고)
late AndroidNotificationDetails thisIsNotificationDetailForAndroid;
late NotificationDetails thisIsNotificationDetail;
//앱 종료 시 백그라운드 서비스 컨트롤러
final FlutterBackgroundService backServiceController =
    FlutterBackgroundService();
//ID
const int notiId = 1; //개별 푸쉬알림 ID
const String notiChId = 'ntCh'; //알림 채널 ID
const String notiStreamId = 'ntStream'; //알림스트림(리스너) ID

//////////////////////function space////////////////////////////////////////////
//background service에 등록할 function.
dynamic onBackServiceStart(ServiceInstance instance) {
  Timer.periodic(const Duration(seconds: 1), (timer) {
    debugPrint('Background service is running: ${DateTime.now()}');
  });
}

//단일 푸쉬알림 띄우기
Future<void> showNoti() async {
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
}

//
@pragma('vm:entry-point')
void notifyInBackground(NotificationResponse response) {
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    debugPrint('Timer tick : $timer');
    await showNoti();
  });
}

void onNotiTapped(NotificationResponse notificationResponse) {
  streamForSelectedNoti.add(notificationResponse.payload);
}

//////////////////////main function/////////////////////////////////////////////
Future<void> main() async {
  //init flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  //init noti channel
  notiChannel = const AndroidNotificationChannel(
    notiChId, // id
    'MY FOREGROUND SERVICE', // title
    description: 'notification ch',
    importance: Importance.low,
  );

  //init background service
  await backServiceController.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onBackServiceStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: notiChId,
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: notiId,
    ),
  );

  //푸쉬알림 컨트롤러 초기화
  //TODO: IOS도 settings에 추가
  await notiController.initialize(
    const InitializationSettings(
        android: AndroidInitializationSettings('app_icon')),
    //알림을 탭하여 어플을 열 때
    onDidReceiveNotificationResponse: onNotiTapped,
    //앱이 백그라운드에서 실행중일 때 알림을 띄우는 함수. 단 종료되면 안댐.
    onDidReceiveBackgroundNotificationResponse: notifyInBackground,
  );

  //run
  runApp(const TestPush());
}

//App class
class TestPush extends StatelessWidget {
  const TestPush({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainPage());
  }
}

//main stf page
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await notiController.show(
      1,
      'plain title',
      'plain body',
      notificationDetails,
      payload: 'item x',
    );
  }

  //TODO: global로 빼보기
  Future<void> _notifyEachTime() async {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      debugPrint('[log] Timer tick : $timer');
      await _showNotification();
    });
  }

  //TODO: global로 빼보기
  void _setStream() {
    streamForSelectedNoti.stream.listen((String? payload) async {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => SubPage(payload),
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    _setStream();
    _notifyEachTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const Spacer(),
          const Text('hi'),
          ElevatedButton(
            //TODO: global func로 교체 후 테스트
            onPressed: _showNotification,
            child: const Text('show'),
          ),
          ElevatedButton(
            onPressed: _getNotiPermission,
            child: const Text('permission'),
          ),
          const Spacer(),
        ],
      )),
    );
  }

  void _getNotiPermission() {
    notiController
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
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
