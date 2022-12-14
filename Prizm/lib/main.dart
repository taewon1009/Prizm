import 'dart:convert';
import 'dart:io';
import 'package:Prizm/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:Prizm/vmidc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:package_info/package_info.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Chart.dart';
import 'History.dart';
import 'Home.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /*--------------------------- firebase --------------------------------
  final RemoteConfig remoteConfig = await RemoteConfig.instance;
  remoteConfig.setDefaults({"version" : "person['ARTIST']"});
  await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
         fetchTimeout: const Duration(seconds: 30),
         minimumFetchInterval: const Duration(seconds: 30)
      )
  );

  await remoteConfig.fetchAndActivate();

  String title = remoteConfig.getString("version");
  print('version > $title');
  --------------------------------------------------------------------*/
  runApp(
     MyApp(),
  );
}
class MyApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
   MyApp({Key? key}) : super(key: key);

  // static var history;
  // static var rank;
  // static var programs;
  // static var search;

  static var Uri;
  static var fixed;
  static var appVersion;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ko', ''),
            ],
            debugShowCheckedModeBanner: false,            // ?????? ????????? ??? ??????
            navigatorKey: VMIDC.navigatorState,           // ?????? ????????? ?????? navigator
            theme: ThemeData(
                primarySwatch: generateMaterialColor(color: Colors.white)
            ),
            darkTheme: ThemeData.dark(),
            themeMode: currentMode,
            home: TabPage(),
          );
        });
  }
}

class TabPage extends StatefulWidget {
  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {

  int _selectedIndex = 1;// ????????? ?????? ?????? ??????

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  var deviceData;
  var _deviceData;

  Future<void> initPlatformState() async {
    String? deviceId;
    try {  //?????? uid
      deviceId = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      deviceId = 'Failed to get Id';
    }
    if (!mounted) return;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDevice = await deviceInfoPlugin.androidInfo;
      deviceData = androidDevice.displayMetrics.widthPx;
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await deviceInfoPlugin.iosInfo;
    }
    setState(() {
      _deviceData = deviceData;
    });
    // setState(() {
      // _deviceId = deviceId;
      // uid = _deviceId;
    // });
  }
/*----------------------------------------------------------------------------------------------------*/


  Future _launchUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var packageVersion = packageInfo.version;
    MyApp.appVersion = packageVersion;

// print(_versionCheck.checkUpdatable(version));

    // _versionCheck.checkUpdatable(version);
// ????????? ????????? ??? ?????? ?????? ?????????

// if (version == version) {
//
// showDefaultDialog();
//
// } else {}
  }

  void showDefaultDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {

          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          double c_height = MediaQuery.of(context).size.height;
          double c_width = MediaQuery.of(context).size.width;
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                height: c_height * 0.18,
                width: c_width * 0.8,
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                color: isDarkMode ? const Color.fromRGBO(66, 66, 66, 1) : Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: c_height * 0.115,
                      child: const Center(
                        child: Text('??????????????? ?????? ???????????? ???????????????.', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: isDarkMode
                                      ? const Color.fromRGBO(94, 94, 94, 1)
                                      : Colors.black.withOpacity(0.1))
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              margin: const EdgeInsets.only(right: 20),
                              color: isDarkMode ? const Color.fromRGBO(66, 66, 66, 1) : Colors.white,
                              width: c_width * 0.345,
                              height: c_height * 0.08,
                              child: TextButton(
                                onPressed: () {
                                  Uri _url = Uri.parse('');
                                  if (Platform.isAndroid) {
                                    showDefaultDialog();
                                    updateToast();
// _url = Uri.parse('http://www.naver.com');
// _url = Uri.parse('http://www.oneidlab.kr/app_check.html');
// ?????????????????? ?????? ??????
                                  } else if (Platform.isIOS) {
                                    print('ios platform');
                                  }
                                  try {
                                    launchUrl(_url);
                                    print('launching $_url');
                                    canLaunchUrl(_url);
                                  } catch (e) {
                                    print('$_url ????????????');
                                    print(e);
                                  }
                                },
                                child: Text(
                                  '??????',
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
        });
  }

/*-----------------------------------------------------------------------------------------*/

  final List _pages = [History(), Home(), Chart()];

  List url = [];

  fetchData() async {       // ?????? URL ????????? ??????
    try {
      http.Response response = await http.get(Uri.parse('http://dev.przm.kr/przm_api/'));
      String jsonData = response.body;
      Map<String, dynamic> url = jsonDecode(jsonData.toString());
      setState(() {});
      MyApp.fixed = url[''];
      MyApp.Uri = MyApp.fixed.toString();
    } catch (e) {
      print('error >> $e');
    }
  }

  @override
  void initState() {
    // fetchData();   ??????url ????????? ?????????
    _launchUpdate();
    initPlatformState();
    // MyApp.history  = Uri.parse('http://dev.przm.kr/przm_api/get_song_history/json?uid=');
    // MyApp.rank = Uri.parse('http://dev.przm.kr/przm_api/get_song_ranks');
    MyApp.Uri = Uri.parse('http://dev.przm.kr/przm_api/');

    super.initState();
  }

  PageController pageController = PageController(
    initialPage: 1,
  );

/*--------------------------------------------------------------------*/
  Widget buildPageView() {
    return PageView(
      controller: pageController,
      children: <Widget>[_pages[0], _pages[1], _pages[2]],
    );
  }

  void pageChanged(int index) {
    setState(() {
      _selectedIndex = index;
      pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
      pageController.jumpToPage(_selectedIndex);
    });
  }

/*--------------------------------------------------------------------*/

// flutter build apk ???release ???no-sound-null-safety
  @override
  Widget build(BuildContext context) {

    SystemChrome.setEnabledSystemUIMode(    // ?????? ????????? ??????
        SystemUiMode.manual,
        overlays: [
          SystemUiOverlay.bottom
        ]
    );
    // SystemChrome.setEnabledSystemUIMode(    // ?????? ????????? ??????
    //     SystemUiMode.manual,
    //     overlays: [
    //       SystemUiOverlay.top
    //     ]
    // );
    return WillPopScope(
        onWillPop: () {
          if (_selectedIndex == 1 && pageController.offset == _deviceData / 3) {
            return _onBackKey();
          } else {
            print(pageController.offset);
            print(_deviceData);
            return _backToHome();
          }
        },
        child: Scaffold(
          body: buildPageView(),
          bottomNavigationBar: StyleProvider(
              style: MyApp.themeNotifier.value == ThemeMode.dark ? Style_dark() : Style(),
              child: ConvexAppBar(
// type: BottomNavigationBarType.fixed, // bottomNavigationBar item??? 4??? ????????? ??????
                items: [
                  TabItem(
                    icon: Image.asset('assets/history.png'),
                    title: '????????????',
                  ),
                  TabItem(
                    icon: MyApp.themeNotifier.value == ThemeMode.dark
                        ? Image.asset('assets/search_dark.png')
                        : Image.asset('assets/search.png'),
                  ),
                  TabItem(
                    title: '??????',
                    icon: Image.asset('assets/chart.png', width: 50),
                  ),
                ],
                onTap: pageChanged,
                height: 80,
                style: TabStyle.fixedCircle,
                curveSize: 100,
                elevation: 2.0,
                backgroundColor: MyApp.themeNotifier.value == ThemeMode.dark ? Colors.black : Colors.white,
              )
          ),
        )
    );
  }

/* =======================================================*/

  Future<bool> _onBackKey() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return await showDialog(
      context: context,
      barrierDismissible: false, //??????????????? ????????? ?????? ?????? ???????????? ????????? ?????? (true: ??????)
      builder: (BuildContext context) {
        double c_height = MediaQuery.of(context).size.height;
        double c_width = MediaQuery.of(context).size.width;
        return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              height: c_height * 0.18,
              width: c_width * 0.8,
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              color: isDarkMode ? const Color.fromRGBO(66, 66, 66, 1) : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: c_height * 0.115,
                    child: const Center(
                      child: Text('?????? ???????????????????', style: TextStyle(fontSize: 18)),
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
                          width: c_width * 0.4,
                          height: c_height * 0.08,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: isDarkMode ? const Color.fromRGBO(66, 66, 66, 1) : Colors.white,
                                  border: Border(
                                      right: BorderSide(
                                          color: isDarkMode
                                              ? const Color.fromRGBO(94, 94, 94, 1)
                                              : Colors.black.withOpacity(0.1))
                                  )
                              ),
                              margin: const EdgeInsets.only(left: 20),
                              child: TextButton(
                                  onPressed: () {
                                    exit(0);
                                  },
                                  child: const Text('??????', style: TextStyle(fontSize: 20, color: Colors.red))
                              )
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(right: 20),
                            color: isDarkMode ? const Color.fromRGBO(66, 66, 66, 1) : Colors.white,
                            width: c_width * 0.345,
                            height: c_height * 0.08,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('??????',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.3),
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
        );
      },
    );
  }

  Future<bool> _backToHome() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TabPage();
        });
  }

/* ========================================================*/

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // index??? item ????????? 0, 1, 2??? ??????
    });
  }
}

void updateToast() {
  Fluttertoast.showToast(
      msg: '??????????????? ?????? ???????????? ???????????????.',
      backgroundColor: Colors.grey,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER);
}

class Style_dark extends StyleHook {
  @override
  double get activeIconMargin => 10;

  @override
  double get activeIconSize => 30;

  @override
  double? get iconSize => 40;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return const TextStyle(fontSize: 14, color: Colors.white);
  }
}

class Style extends StyleHook {
  @override
  double get activeIconMargin => 10;

  @override
  double get activeIconSize => 30;

  @override
  double? get iconSize => 40;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return const TextStyle(fontSize: 14, color: Colors.black);
  }
}
