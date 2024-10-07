import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project1/cubit/auth/authCubit.dart';
import 'package:project1/data/model/chatModel.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/api.dart';
import 'package:project1/utils/constants.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/string.dart';
import 'package:project1/ui/screen/settings/no_internet_screen.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:project1/utils/internetConnectivity.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:open_filex/open_filex.dart';
//import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ChatScreen extends StatefulWidget {
  final String? id, status;

  const ChatScreen({Key? key, this.id, this.status}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

StreamController<String>? chatScreenstreamdata;

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController msgController = TextEditingController();
  List<File> files = [];
  List<ChatModel> chatList = [];
  late Map<String?, String> downloadlist;
  String _filePath = "";
  double? width, height;

  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final ScrollController _scrollController = ScrollController();
  Future<List<Directory>?>? _externalStorageDirectories;

  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
/*    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });*/
    _externalStorageDirectories = getExternalStorageDirectories(type: StorageDirectory.downloads);
    downloadlist = <String?, String>{};
    //CUR_TICK_ID = widget.id;
    FlutterDownloader.registerCallback(downloadCallback);
    setupChannel();

    getMsg();
  }

  @override
  void dispose() {
    msgController.dispose();
    _connectivitySubscription.cancel();
    //CUR_TICK_ID = '';
    if (chatScreenstreamdata != null) chatScreenstreamdata!.sink.close();

    super.dispose();
  }

  //String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  static void downloadCallback(String id, int status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Future<void> refreshList() async {
    getMsg();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: /*_connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          :*/ Scaffold(
              appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, chatLabel), const PreferredSize(
                                preferredSize: Size.zero,child:SizedBox())),
              body: RefreshIndicator(
                onRefresh: ()=> refreshList(),
                color: Theme.of(context).colorScheme.primary, 
                child: Container(
                  margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                  decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                  width: width,
                  child: Container(
                    margin: EdgeInsetsDirectional.only(start: width! / 25.0, end: width! / 25.0, top: height! / 60.0),
                    child: Column(
                      children: <Widget>[buildListMessage(), msgRow()],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void setupChannel() {
    chatScreenstreamdata = StreamController<String>(); //.broadcast();
    chatScreenstreamdata!.stream.listen((response) {
      setState(() {
        final res = json.decode(response);
        ChatModel message;
        //String mid;

        message = ChatModel.fromJson(res["data"]);

        chatList.insert(0, message);
        files.clear();
      });
    });
  }

  void insertItem(String response) {
    if (chatScreenstreamdata != null) chatScreenstreamdata!.sink.add(response);
    _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Widget buildListMessage() {
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemBuilder: (context, index) => msgItem(index, chatList[index]),
        itemCount: chatList.length,
        reverse: true,
        controller: _scrollController,
      ),
    );
  }

  Widget msgItem(int index, ChatModel message) {
    if (message.userId == context.read<AuthCubit>().getId()) {
      //Own message
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(),
          ),
          Flexible(
            flex: 2,
            child: MsgContent(index, message),
          ),
        ],
      );
    } else {
      //Other's message
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: MsgContent(index, message),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          ),
        ],
      );
    }
  }

  Widget MsgContent(int index, ChatModel message) {
    //String filetype = message.attachment_mime_type.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: message.userId == context.read<AuthCubit>().getId() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        message.userId == context.read<AuthCubit>().getId()
            ? Container()
            : Padding(
                padding: const EdgeInsetsDirectional.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(message.name!, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12)),
                    )
                  ],
                ),
              ),
        ListView.builder(
            itemBuilder: (context, index) {
              return attachItem(message.attachments!, index, message);
            },
            itemCount: message.attachments!.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true),
        message.message != null && message.message!.isNotEmpty
            ? Card(
                elevation: 0.0,
                color: message.userId == context.read<AuthCubit>().getId() ? Theme.of(context).colorScheme.secondary.withOpacity(0.1) : Theme.of(context).colorScheme.secondary.withOpacity(0.20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: Column(
                    crossAxisAlignment: message.userId == context.read<AuthCubit>().getId() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${message.message}", style: const TextStyle(color: black)),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 5),
                        child: Text(message.dateCreated!, style: const TextStyle(color: lightFontColor, fontSize: 9)),
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  void _requestDownload(String? url, String? mid, AsyncSnapshot snapshot) async {
    bool checkpermission = await checkPermission(snapshot);
    if (checkpermission) {
      if (Platform.isIOS) {
        Directory target = await getApplicationDocumentsDirectory();
        _filePath = target.path.toString();
      } else {
        if (snapshot.hasData) {
          _filePath = snapshot.data!.map((Directory d) => d.path).join(', ');

          print("dir path****$_filePath");
        }
      }

      String fileName = url!.substring(url.lastIndexOf("/") + 1);
      File file = File("$_filePath/$fileName");
      bool hasExisted = await file.exists();

      if (downloadlist.containsKey(mid)) {
        final tasks = await FlutterDownloader.loadTasksWithRawQuery(query: "SELECT status FROM task WHERE task_id=${downloadlist[mid]}");

        if (tasks == 4 || tasks == 5) downloadlist.remove(mid);
      }

      if (hasExisted) {
        /* final openFile =  */await OpenFilex.open("$_filePath/$fileName");
      } else if (downloadlist.containsKey(mid)) {
        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, downloadLabel), StringsRes.downloading, context, false, type: "1");
      } else {
        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, downloadLabel), StringsRes.downloading, context, false, type: "1");
        final taskid = await FlutterDownloader.enqueue(
            url: url, savedDir: _filePath, headers: {"auth": "test_for_sql_encoding"}, showNotification: true, openFileFromNotification: true);

        setState(() {
          downloadlist[mid] = taskid.toString();
        });
      }
    }
  }

  Future<bool> checkPermission(AsyncSnapshot snapshot) async {
    var status = await Permission.storage.status;

    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage] == PermissionStatus.granted) {
        fileDirectoryPrepare(snapshot);
        return true;
      }
    } else {
      fileDirectoryPrepare(snapshot);
      return true;
    }
    return false;
  }

  Future<void> fileDirectoryPrepare(AsyncSnapshot snapshot) async {
    if (Platform.isIOS) {
      Directory target = await getApplicationDocumentsDirectory();
      _filePath = target.path.toString();
    } else {
      if (snapshot.hasData) {
        _filePath = snapshot.data!.map((Directory d) => d.path).join(', ');

        print("dir path****$_filePath");
      }
    }
  }

  _imgFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      files = result.paths.map((path) => File(path!)).toList();
      if (mounted) setState(() {});
    } else {
      // User canceled the picker
    }
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      msgController.text = "";
    });
    var request = http.MultipartRequest("POST", Uri.parse(Api.sendMessageUrl));
    request.headers.addAll(Api.getHeaders());
    request.fields[userIdKey] = context.read<AuthCubit>().getId();
    request.fields[ticketIdKey] = widget.id!;
    request.fields[userTypeKey] = userKey;
    request.fields[messageKey] = message;

    for (int i = 0; i < files.length; i++) {
      final mimeType = lookupMimeType(files[i].path);

      var extension = mimeType!.split("/");
      var pic = await http.MultipartFile.fromPath(
        attachmentsKey,
        files[i].path,
        contentType: MediaType('image', extension[1]),
      );
      request.files.add(pic);
    }

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var getdata = json.decode(responseString);
    bool error = getdata["error"];
    //String? msg = getdata['message'];
    //var data = getdata["data"];
    if (!error) {
      insertItem(responseString);
    }
  }

  Future<void> getMsg() async {
    try {
      var data = {
        ticketIdKey: widget.id,
      };

      Response response = await post(Uri.parse(Api.getMessagesUrl), body: data, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          var data = getdata["data"];
          chatList = (data as List).map((data) => ChatModel.fromJson(data)).toList();
        } else {
          if (msg != "Ticket Message(s) does not exist") UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, messageLabel), msg!, context, false, type: "2");
        }
        if (mounted) setState(() {});
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, messageLabel), StringsRes.somethingMsg, context, false, type: "2");
    }
  }

  msgRow() {
    return widget.status != "4"
        ? Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsetsDirectional.all(5.0),
              width: double.infinity,
              color: Theme.of(context).colorScheme.onSurface,
              child: Row(
                children: <Widget>[
                  FloatingActionButton(
                        mini: true,
                        onPressed: () {
                          _imgFromGallery();
                        },
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        elevation: 0,
                        child: Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 30,
                        ),
                  ),
                  /* const SizedBox(
                    width: 15,
                  ), */
                  Expanded(
                    child: Container(decoration: DesignConfig.boxDecorationContainer(black, 100),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: msgController,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(color: white),
                              maxLines: null,
                              decoration: InputDecoration(contentPadding: EdgeInsetsDirectional.only(start: width!/20.0),
                                  hintText: UiUtils.getTranslatedLabel(context, writeMessageLabel), hintStyle: const TextStyle(color: white), border: InputBorder.none),
                            ),
                          ),
                          const SizedBox(
                        width: 15,
                      ),
                      FloatingActionButton(
                        mini: true,
                        onPressed: () {
                          if (msgController.text.trim().isNotEmpty || files.isNotEmpty) {
                            sendMessage(msgController.text.trim());
                          }
                        },
                        backgroundColor: Theme.of(context).colorScheme.onSurface,
                        elevation: 0,
                        child: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.onSecondary,
                          size: 18,
                        ),
                      ),
                        ],
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          )
        : Container();
  }

  Widget attachItem(List<Attachments> attach, int index, ChatModel message) {
    String? file = attach[index].media;
    String? type = attach[index].type;
    String icon;
    if (type == "video") {
      icon = "assets/images/video.png";
    } else if (type == "document") {
      icon = "assets/images/doc.png";
    } else if (type == "spreadsheet") {
      icon = "assets/images/sheet.png";
    } else {
      icon = "assets/images/zip.png";
    }
    return FutureBuilder<List<Directory>?>(
        future: _externalStorageDirectories,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return file == null
              ? Container()
              : Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    Card(
                      //margin: EdgeInsetsDirectional.only(end: message.sender_id == myid ? 10 : 50, start: message.sender_id == myid ? 50 : 10, bottom: 10),
                      elevation: 0.0,
                      color:
                          message.userId == context.read<AuthCubit>().getId() ? Theme.of(context).colorScheme.secondary.withOpacity(0.1) : Theme.of(context).colorScheme.secondary.withOpacity(0.20),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: message.userId == context.read<AuthCubit>().getId() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: <Widget>[
                            //_messages[index].issend ? Container() : Center(child: SizedBox(height:20,width: 20,child: new CircularProgressIndicator(backgroundColor: ColorsRes.secondgradientcolor,))),

                            InkWell(
                              onTap: () {
                                _requestDownload(attach[index].media, message.id, snapshot);
                              },
                              child: type == "image"
                                  ? Image.network(file,
                                      width: 250,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Image.asset(DesignConfig.setPngPath('placeholder_square'), height: 150, width: 150))
                                  : Image.asset(
                                      icon,
                                      width: 100,
                                      height: 100,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(message.dateCreated!, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 9)),
                      ),
                    ),
                  ],
                );
        });
  }
}
