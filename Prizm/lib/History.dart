// ignore_for_file: avoid_print, prefer_const_constructors, curly_braces_in_flow_control_structures, avoid_single_cascade_in_expression_statements, slash_for_doc_comments
import 'dart:async';
import 'package:darkmode/Settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'History_Bottom.dart';
import 'Home.dart';
import 'PlayInfo.dart';
import 'main.dart';

class History extends StatefulWidget {
  @override
  _History createState() =>  _History();

// const History({Key? key}) : super(key: key);
}

class _History extends State<History> {
  TextEditingController txtQuery = TextEditingController();

  String? _deviceId;
  String? uid;

  // final uid = _deviceId;

  Future<void> initPlatformState() async {
    String? deviceId;

    try {
      deviceId = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      deviceId = 'Failed to get Id';
    }

    if (!mounted) return;

    setState(() {
      _deviceId = deviceId;
      uid = _deviceId;
    });
  }

  static RegExp basicReg = (
      // RegExp(
      // r'[a-z|A-Z|0-9|ㄱ-ㅎ|ㅏ-ㅣ|가-힣]'));
      RegExp(r'[a-z|A-Z|0-9|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ|ㆍ|ᆢ|ᄀᆞ|ᄂᆞ|ᄃᆞ|ᄅᆞ|ᄆᆞ|ᄇᆞ|ᄉᆞ|ᄋᆞ|ᄌᆞ|ᄎᆞ|ᄏᆞ|ᄐᆞ|ᄑᆞ|ᄒᆞ|\s|~!@#$%^&*()_+=:`,./><?{}*|-]'));

  List persons = [];
  List original = [];
  List person = [];
  List song_id = [];
  String _songid = '';

  fetchData() async {
    _deviceId = await PlatformDeviceId.getDeviceId;

    print('deviceId : $_deviceId');
    try {
      http.Response response = await http.get(Uri.parse(
          'http://dev.przm.kr/przm_api/get_song_history/json?uid=$uid'));
      String jsonData = response.body;
      persons = jsonDecode(jsonData.toString());
      original = persons;
      setState(() {});
    } catch (e) {
      NetworkToast();
      print('실패');
      print(e);
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      persons = original;
      setState(() {});
      return;
    } else {
      persons = original;
      setState(() {});
    }

    //for (var p in persons)
    query = query.toLowerCase();
    print(query);
    List result = [];
    for (var p in persons) {
      // print('검색결과  : ' + p['TITLE']);
      var title = p["TITLE"].toString().toLowerCase();
      var artist = p["ARTIST"].toString().toLowerCase();
      var album = p['ALBUM'].toString().toLowerCase();
      if (title.contains(query)) {
        result.add(p);
      } else if (artist.contains(query)) {
        result.add(p);
      } else if (album.contains(query)) {
        result.add(p);
      }
    }

    persons = result;
    print('검색결과 : $result');
    setState(() {});
  }

  /* ----------------------------------------------------- */

  final duplicateItems = List<String>.generate(10000, (i) => "Item $i");

  var items = <String>[];

  _printLatestValue() {
    print('마지막 입력값 : ${txtQuery.text}');
    List<String> SearchList = <String>[];
    SearchList.addAll(duplicateItems);
  }

  @override
  void initState() {
    items.addAll(duplicateItems);
    txtQuery.addListener(_printLatestValue);
    initPlatformState();
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void filterSearchResults(String query) {
    List<String> SearchList = <String>[];
    SearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<String> ListData = <String>[];
      SearchList.forEach((item) {
        if (item.contains(query)) {
          ListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(ListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  /* ----------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    int len = persons.length;
    final isExist = len == 0;

    return WillPopScope(
        onWillPop: () async {
          return _onBackKey();
        },
        child: Scaffold(
            appBar: AppBar(
              shape: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.3))),
              title: Text(
                '히스토리',
                style: (isDarkMode
                    ? const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)
                    : const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              centerTitle: true,
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
              toolbarHeight: 80,
              elevation: 0.0,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: ImageIcon(Image.asset('assets/settings.png').image),
                  color: isDarkMode ? Colors.white : Colors.black,
                  onPressed: () {
                    print("settings");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Settings()));
                  },
                )
              ],
            ),
            body: Container(
              color: isDarkMode ? Colors.black : Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: isDarkMode ? Colors.black : Colors.white,
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                const Text(
                                  '발견한 노래 ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                Text(
                                  // '$persons.length',
                                  '$len',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                const Text(
                                  ' 곡',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ],
                            )),
                        TextFormField(
                            // autofocus: true,
                            controller: txtQuery,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(basicReg),
                            ],
                            onChanged: search,
                            // onChanged: change,
                            textInputAction: TextInputAction.search,
                            onFieldSubmitted: (value) {
                              print('text : ' + txtQuery.text);
                            },
                            decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                labelText: '곡/가수/앨범명으로 검색해주세요',
                                labelStyle: TextStyle(
                                    color: isDarkMode
                                        ? Colors.grey.withOpacity(0.8)
                                        : Colors.black.withOpacity(0.2),
                                    // color: Colors.black.withOpacity(0.2),
                                    fontSize: 15),
                                enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                      color: Colors.greenAccent,
                                    )),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.greenAccent)),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.greenAccent,
                                ),
                                suffixIcon: txtQuery.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: isDarkMode
                                              ? Colors.grey.withOpacity(0.8)
                                              : Colors.black.withOpacity(0.2),
                                        ),
                                        onPressed: () {
                                          txtQuery.text = '';
                                          search(txtQuery.text);
                                        },
                                      )
                                    : null)),
                      ],
                    ),
                  ),
                  isExist
                      ? Container(
                          // height: c_height*0.4,
                          margin: EdgeInsets.only(top: 100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  '최근 검색 기록이 없습니다.',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                              )
                            ],
                          ),
                        )
                      : _listView(persons, person)
                ],
              ),
            )));
  }

  Future<bool> _onBackKey() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TabPage();
        });
  }

  Widget _listView(persons, person) {
    return Expanded(
        child: ListView.builder(
            itemCount: persons == null ? 0 : persons.length,
            itemBuilder: (context, index) {
              double c_width = MediaQuery.of(context).size.width;

              final person = persons[index];
              final isDarkMode =
                  Theme.of(context).brightness == Brightness.dark;

              // final isAsset = person['IMAGE'] == 'assets/no_image.png';
              final isArtistNull = person['ARTIST'] == null;
              final isAlbumNull = person['ALBUM'] == null;

              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (BuildContext context) {
                        var person = persons[index];
                        final deviceId = _deviceId;
                        return SizedBox(
                            height: 300,
                            child: ListView.builder(
                                itemCount: 1,
                                itemBuilder: (context, index) {
                                  String Id = deviceId!;
                                  String title = person['TITLE'];
                                  String image = person['IMAGE'];
                                  String artist = isArtistNull
                                      ? 'Various Artists'
                                      : person['ARTIST'];
                                  String song_id = person['SONG_ID'];
                                  _songid = song_id;
                                  double c_width =
                                      MediaQuery.of(context).size.width;
                                  final isDarkMode =
                                      MyApp.themeNotifier.value == ThemeMode.dark;
                                  return Container(
                                    width: c_width,
                                    padding: const EdgeInsets.only(top: 14),
                                    decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? const Color.fromRGBO(36, 36, 36, 1)
                                            : const Color.fromRGBO(250, 250, 250, 2),
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10)
                                        )
                                    ),
// height: 300,
                                    child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: c_width,
                                            padding: const EdgeInsets.all(13),
                                            color: isDarkMode
                                                ? const Color.fromRGBO(
                                                36, 36, 36, 1)
                                                : const Color.fromRGBO(
                                                250, 250, 250, 2),
                                            child: Row(
                                              children: [
                                                Container(
                                                    margin : EdgeInsets.only(left: 10, bottom: 10),
                                                    padding: EdgeInsets.all(1),
                                                    decoration: BoxDecoration(
                                                      color: isDarkMode
                                                          ? const Color
                                                          .fromRGBO(
                                                          189, 189, 189, 1)
                                                      : Colors.black.withOpacity(0.3),
                                                          // : const Color
                                                          // .fromRGBO(
                                                          // 228, 228, 228, 1),
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8),
                                                    ),
                                                    child: ClipRRect(
                                                        borderRadius:
                                                        BorderRadius.circular(8),
                                                        child:
                                                        SizedBox.fromSize(
                                                          child: Image.network(
                                                            person['IMAGE'],
                                                            width: 90,
                                                            height: 90,
                                                            errorBuilder:
                                                                (context, error,
                                                                stackTrace) {
                                                              return SizedBox(
                                                                width: 90,
                                                                height: 90,
                                                                child:
                                                                Image.asset(
                                                                  'assets/no_image.png',
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ))),
                                                Flexible(
                                                    child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                            width: c_width * 0.61,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 15),
                                                                  child: Text(
                                                                    person['TITLE'],
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 20,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        color: isDarkMode
                                                                            ? Colors.white
                                                                            : Colors.black
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                  const EdgeInsets.fromLTRB(20, 10, 0, 0),
                                                                  child: isArtistNull
                                                                              ? Text('Various Artists',
                                                                                style: TextStyle(color: isDarkMode ? Colors.grey.withOpacity(0.8) : Colors.black.withOpacity(0.4)
                                                                                )
                                                                  )
                                                                              : Text(person['ARTIST'],
                                                                                style: TextStyle(color: isDarkMode ? Colors.grey.withOpacity(0.8) : Colors.black.withOpacity(0.4)), overflow: TextOverflow.ellipsis
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: c_width * 0.05,
                                                            child: IconButton(
                                                                padding:
                                                                const EdgeInsets.only(bottom: 80, right: 10),
                                                                icon: ImageIcon(
                                                                    Image.asset('assets/x_icon.png').image,
                                                                    size: 15
                                                                ),
                                                                color: isDarkMode
                                                                    ? Colors.white
                                                                    : Colors.grey,
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                }),
                                                          )
                                                        ])),
// ],
// ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            color: isDarkMode
                                                ? Colors.black
                                                : Colors.white,
                                            height: 156,
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
// post();
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                  PlayInfo(
                                                                    deviceId:
                                                                    Id,
                                                                    title:
                                                                    title,
                                                                    image:
                                                                    image,
                                                                    artist:
                                                                    artist,
                                                                    song_id:
                                                                    song_id,
                                                                  )));
                                                    },
                                                    child: Column(children: [
                                                      Container(
                                                          color: isDarkMode
                                                              ? Colors.black
                                                              : Colors.white,
                                                          child: Row(
                                                            children: [
                                                              IconButton(
                                                                padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right:
                                                                    20),
                                                                icon: ImageIcon(
                                                                    Image.asset(
                                                                        'assets/list.png')
                                                                        .image,
                                                                    size: 30),
                                                                color: const Color
                                                                    .fromRGBO(
                                                                    64,
                                                                    220,
                                                                    196,
                                                                    1),
                                                                onPressed: () {
// post();
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => PlayInfo(
                                                                            deviceId: Id,
                                                                            title: title,
                                                                            image: image,
                                                                            artist: artist,
                                                                            song_id: song_id,
                                                                          )));
// PlayInfo(title : person['title'])));
                                                                },
                                                              ),
                                                              Text(
                                                                '프리즘 방송 재생정보',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                    20,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                    color: isDarkMode
                                                                        ? Colors
                                                                        .white
                                                                        : Colors
                                                                        .black),
                                                              )
                                                            ],
                                                          )),
                                                    ])),
                                                GestureDetector(
                                                    onTap: () {
                                                      showDialogPop();
                                                    },
                                                    child: Container(
                                                      color: isDarkMode
                                                          ? Colors.black
                                                          : Colors.white,
                                                      padding:
                                                      const EdgeInsets.only(
                                                          top: 20),
                                                      child: Row(
                                                        children: [
                                                          IconButton(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 30),
                                                            icon: ImageIcon(
                                                                Image.asset(
                                                                    'assets/trash.png')
                                                                    .image,
                                                                size: 40),
                                                            color: const Color
                                                                .fromRGBO(
                                                                64,
                                                                220,
                                                                196,
                                                                1),
                                                            onPressed: () {
// showDialogPop();
                                                            },
                                                          ),
                                                          Text(
                                                            '히스토리에서 삭제',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w300,
                                                                color: isDarkMode
                                                                    ? Colors
                                                                    .white
                                                                    : Colors
                                                                    .black),
                                                          )
                                                        ],
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          )
                                        ]),
                                  );
                                }));
                      });
                },
                child: Container(
                  color: isDarkMode ? Colors.black : Colors.white,
                  width: c_width,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(1),
                        margin: EdgeInsets.only(right: 30, left: 30),
                        height: 100,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color.fromRGBO(189, 189, 189, 1)
                          : Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox.fromSize(
                              size: Size.fromRadius(48),
                              child: Image.network(
                                person['IMAGE'],
                                errorBuilder: (context, error, stackTrace) {
                                  return SizedBox(
                                    child: Image.asset(
                                      'assets/no_image.png',
                                    ),
                                  );
                                },
                              ),
                            )),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: c_width * 0.5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    person['TITLE'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(
// width: c_width * 0.8,
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: isArtistNull
                                            ? Text('Various Artists',
                                            style: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.grey
                                                    .withOpacity(0.8)
                                                    : Colors.black
                                                    .withOpacity(0.4)))
                                            : Text(
                                          person['ARTIST'],
                                          style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.grey
                                                  .withOpacity(0.8)
                                                  : Colors.black
                                                  .withOpacity(0.4)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                  isAlbumNull
                                      ? Text(
                                    'Various Album',
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey.withOpacity(0.8)
                                            : Colors.black
                                            .withOpacity(0.4),
                                        overflow: TextOverflow.ellipsis),
                                  )
                                      : Text(
// person['F_ALBUM_TITLE'],
                                    person['ALBUM'],
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey.withOpacity(0.8)
                                            : Colors.black
                                            .withOpacity(0.4),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(
                                    person['SCH_DATE'],
// person['F_REGDATE'],
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.greenAccent.withOpacity(0.8)
                                          : Colors.greenAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                width: c_width * 0.09,
                                child: const Icon(Icons.more_vert_sharp,
                                    color: Colors.grey, size: 30))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  void showDialogPop() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double c_width = MediaQuery.of(context).size.width;
    double c_height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      barrierDismissible:
          false, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              // width: 400,
              // height: 140,
              width: c_width * 0.8,
              height: c_height * 0.18,
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              // padding: const EdgeInsets.only(top:20),
              color: isDarkMode
                  ? const Color.fromRGBO(66, 66, 66, 1)
                  : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    // height: 90,
                    height: c_height * 0.115,
                    child: Center(
                      child: Text(
                        '이 항목을 삭제하시겠습니까?',
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
                                      : Colors.black.withOpacity(0.1)))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            // width: 200,
                            // height: 68,
                            width: c_width * 0.4,
                            height: c_height * 0.08,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? const Color.fromRGBO(66, 66, 66, 1)
                                        : Colors.white,
                                    border: Border(
                                        right: BorderSide(
                                            color: isDarkMode
                                                ? const Color.fromRGBO(
                                                    94, 94, 94, 1)
                                                : Colors.black
                                                    .withOpacity(0.1)))),
                                margin: const EdgeInsets.only(left: 20),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    '취소',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: isDarkMode
                                          // ? Colors.white.withOpacity(0.8)
                                          ? Color.fromRGBO(151, 151, 151, 1)
                                          : Colors.black.withOpacity(0.3),
                                    ),
                                  ),
                                )),
                          ),
                          Container(
                            // width: 180,
                            // height: 68,
                            width: c_width * 0.345,
                            height: c_height * 0.08,
                            margin: const EdgeInsets.only(right: 20),
                            color: isDarkMode
                                ? const Color.fromRGBO(66, 66, 66, 1)
                                : Colors.white,
                            child: TextButton(
                              onPressed: () async {
                                Response response = await http.get(Uri.parse(
                                    'http://dev.przm.kr/przm_api/get_song_history?uid=$uid&id=$_songid&proc=del'));
                                if (response.statusCode == 200) {
                                  print(response.statusCode);
                                  showToast();
                                } else {
                                  print(response.statusCode);
                                  throw "failed to delete history";
                                }
                                setState(() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Bottom()));
                                });
                              },
                              child: const Text(
                                '삭제',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromRGBO(64, 220, 196, 1)),
                              ),
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ));
      },
    );
  }
}

  void showToast() {
    Fluttertoast.showToast(
        msg: '검색내역 삭제 완료',
        backgroundColor: Colors.grey,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER);
  }
