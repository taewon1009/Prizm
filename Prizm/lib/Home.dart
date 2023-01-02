import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:darkmode/vmidc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:darkmode/PermissionManage.dart';
import 'Settings.dart';
import 'main.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

final TabPage _tabPage = TabPage();

class _Home extends State<Home> {
  static final GlobalKey<NavigatorState> navigator =
  GlobalKey<NavigatorState>();

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final double _size = 220;

  final VMIDC _vmidc = VMIDC();
  // final PermissionManage _permissionManager = PermissionManage();
  final _ctrl = StreamController<List>();
  String _id = '';

  final Image _icon = MyApp.themeNotifier.value == ThemeMode.light
      ? Image.asset('assets/_prizm.png')
      : Image.asset('assets/_prizm_dark.png');

  late dynamic _background =
  const ColorFilter.mode(Colors.transparent, BlendMode.clear);

  late TextSpan _textSpan = MyApp.themeNotifier.value == ThemeMode.light
      ? const TextSpan(children: [
    TextSpan(
      text: '지금 이 곡을 찾으려면 ',
      style: TextStyle(fontSize: 17, color: Colors.black),
    ),
    TextSpan(
      text: '프리즘 ',
      style: TextStyle(
          color: Color.fromRGBO(43, 226, 193, 1),
          fontSize: 17,
          fontWeight: FontWeight.bold),
    ),
    TextSpan(
      text: '을 눌러주세요!',
      style: TextStyle(fontSize: 17, color: Colors.black),
    ),
  ])
      : const TextSpan(children: [
    TextSpan(
      text: '지금 이 곡을 찾으려면 ',
      style: TextStyle(fontSize: 17, color: Colors.white),
    ),
    TextSpan(
      text: '프리즘 ',
      style: TextStyle(
          color: Color.fromRGBO(43, 226, 193, 1),
          fontSize: 17,
          fontWeight: FontWeight.bold),
    ),
    TextSpan(
      text: '을 눌러주세요!',
      style: TextStyle(fontSize: 17, color: Colors.white),
    ),
  ]);

/*--------------------------------------------------------------*/

  @override
  void initState() {
    // getPermission();
    // _permissionManager.requestMicPermission(context);
    Permission.microphone.request();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _vmidc
        .init(ip: '222.122.131.220', port: 8551, sink: _ctrl.sink)
        .then((ret) {
      if (!ret) {
        print('server error');
      } else {
        _ctrl.stream.listen((data) async {
          if (data.length == 2) {
            _id = '${data[0]} (${data[1]})';
          } else {
            _id = 'error';
          }
          await _vmidc.stop();
          print('_vmidc.isRuning() : ${_vmidc.isRunning()}');
          setState(() {});
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _vmidc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double c_height = MediaQuery.of(context).size.height;
    double c_width = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isPad = c_width > 550;
    // final request = _permissionManager.requestMicPermission(context);
    return WillPopScope(
        onWillPop: () async {
          return _onBackKey();
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: isDarkMode
                ? const Color.fromRGBO(47, 47, 47, 1)
                : const Color.fromRGBO(244, 245, 247, 1),
            title: Image.asset(
              isDarkMode ? 'assets/logo_dark.png' : 'assets/logo_light.png',
              height: 25,
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: ImageIcon(Image.asset('assets/settings.png').image),
                visualDensity: const VisualDensity(horizontal: 4.0),
                color: isDarkMode ? Colors.white : Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Settings()),
                  );
                },
              )
            ],
            centerTitle: true,
            toolbarHeight: 90,
            elevation: 0.0,
          ),
          body: Container(
            width: double.infinity,
              color: isDarkMode
                  ? const Color.fromRGBO(47, 47, 47, 1)
                  : const Color.fromRGBO(244, 245, 247, 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      height: c_height * 0.55,
                      padding: const EdgeInsets.only(bottom: 50),
                      decoration:  isPad
                        ? BoxDecoration(
                          image: DecorationImage(
                              image: const AssetImage('assets/background.png'),
                              fit: BoxFit.fill,
                              colorFilter: _background
                          )
                      )
                      : BoxDecoration(
                          image: DecorationImage(
                              image: const AssetImage('assets/background.png'),
                              alignment: const Alignment(0,1),
                              colorFilter: _background
                          )
                      ),
                      child: Center(
                          child: Column(children: <Widget>[
                            Center(
                          child : Container(
                            margin : const EdgeInsets.only(bottom: 20),
                              child: RichText(text: _textSpan),
                            )),
                            IconButton(
                                  icon: _icon,
                                  padding: const EdgeInsets.only(bottom: 30),
                                  iconSize: _size,
                                  onPressed: () async {
                                    var status = await Permission.microphone.status;
                                    // print(status);
                                    if(status == PermissionStatus.permanentlyDenied) {
                                      PermissionToast();
                                      // request;
                                      requestMicPermission(context);
                                      print('status >> $status');
                                      return;
                                    } else if(status == PermissionStatus.denied) {
                                      // request;
                                      PermissionToast();
                                      requestMicPermission(context);
                                      print('status >> $status');
                                      Permission.microphone.request();
                                      // openAppSettings();
                                      return;
                                    }
                                    print(_connectionStatus);
                                    if(_connectionStatus.endsWith('none') == true){
                                      NetworkToast();
                                      return;
                                    // }
                                    // else if(await Permission.microphone.status.isDenied){
                                    //   // getPermission();
                                    //   // Permission.microphone.request();
                                    //   PermissionToast();
                                    //   openAppSettings();
                                    //   // openAppSettings();
                                    //   return;
                                    } else if(await Permission.microphone.status.isGranted && _connectionStatus.endsWith('none') == false){
                                      _vmidc.start();
                                      setState(() {
                                        _textSpan = const TextSpan(
                                          text: '노래 분석중',
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  43, 226, 193, 1),
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        );

                                        _background = const ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.color);
                                      });
                                      if (_vmidc.isRunning() == true) {
                                        _vmidc.stop();
                                      }
                                    }
                                  }
                                  ),
                          ])
                      )
                  ),
                ],
              )),
        ));
  }
  Future<bool> _onBackKey() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return await showDialog(
      context: context,
      barrierDismissible: false, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: 400,
// margin: const EdgeInsets.only(top: 20, bottom: 20),
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              height: 150,
              color: isDarkMode
                  ? const Color.fromRGBO(66, 66, 66, 1)
                  : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
// width: 200,
                    height: 90,
                    child: Center(
                      child: Text(
                        '종료?',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: isDarkMode
                                    ? const Color.fromRGBO(94, 94, 94, 1)
                                    : Colors.black.withOpacity(0.1)
                            )
                        )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 78,
// child: Center(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color.fromRGBO(66, 66, 66, 1)
                                      : Colors.white,
                                  border: Border(
                                      right: BorderSide(
                                          color: isDarkMode
                                              ? const Color.fromRGBO(94, 94, 94, 1)
                                              : Colors.black.withOpacity(0.1)
                                      )
                                  )
                              ),
                              margin: const EdgeInsets.only(left: 20),
                              child: TextButton(
                                  onPressed: () {
                                    exit(0);
                                  },
                                  child: const Text(
                                    '종료',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.red),
// ),
                                  ))),
                        ),
                        Container(
                            margin: const EdgeInsets.only(right: 20),
                            color: isDarkMode
                                ? const Color.fromRGBO(66, 66, 66, 1)
                                : Colors.white,
                            width: 180,
                            height: 78,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                '취소',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.black.withOpacity(0.3),
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ));
      },
    );
  }

  Future<bool> requestMicPermission(BuildContext context) async {
    print('aaaa');
    PermissionStatus status = await Permission.microphone.request();
    print('permission manage >> $status');

    if(!status.isGranted) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            print('status => $status');
            return _showDialog(context);
          });
      return false;
    }
    return true;
  }

  _showDialog(BuildContext context) {
    return AlertDialog(
      content: const Text('마이크 권한을 확인해주세요'),
      actions: [
        TextButton(
          onPressed: () {
            openAppSettings();
          },
          child: const Text('설정하기',
            style: TextStyle(
                color: Colors.blue
            ),
          ),
        )
      ],
    );
  }

  Future <void> _updateConnectionStatus(ConnectivityResult result) async {
    switch(result) {
      case ConnectivityResult.wifi :
      case ConnectivityResult.mobile:
      case ConnectivityResult.none :
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(()=> _connectionStatus = '네트워크 연결을 확인 해주세요.');
    }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    try{
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if(!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }
}

// getPermission() async {
//   var status = await Permission.microphone.status;
//
//   if(status.isGranted){
//     print('status => $status');
//     print('confirm');
//   }else if(status.isLimited){
//     print('status => $status');
//     print('limited');
//     Permission.microphone.request();
//   }else if(status.isDenied) {
//     print('denied');
//     print('status => $status');
//     openAppSettings();
//     Permission.microphone.request();
//     return;
//   }else if(await Permission.microphone.isPermanentlyDenied) {
//     print('status => $status');
//     openAppSettings();
//   }
// }

void NetworkToast(){
  Fluttertoast.showToast(
    msg: '네트워크 연결을 확인 해주세요.',
    backgroundColor: Colors.grey,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER
  );
}

void PermissionToast() {
  Fluttertoast.showToast(
    msg: '마이크 권한을 허용해주세요.',
    backgroundColor: Colors.grey,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER
  );
}
