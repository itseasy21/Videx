import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

downloadFile(String url) async {
  Map<PermissionGroup, PermissionStatus> permissionsReq = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  PermissionStatus permissionCheck = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  if(permissionCheck.toString().contains("granted")) {
    String filename = url
        .split('/')
        .last;
    filename = filename.replaceAll("%20", " ");
    Dio dio = new Dio();
    dio.interceptors.add(LogInterceptor());
    Directory dir =
    await getExternalStorageDirectory();
    String path = dir.path;

    Fluttertoast.showToast(
        msg: "Download Started for " + filename +
            "\n Its been downloaded in background, you'll be notified once its done.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );

    await download1(dio, url, path + '/' + filename);
  }else{
    Fluttertoast.showToast(
        msg: "Storage Permission Denied! Enable from Settings > App > Videx.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}

Future download1(Dio dio, String url, savePath) async {
  CancelToken cancelToken = CancelToken();
  try {
    await dio.download(url, savePath,
        onReceiveProgress: showDownloadProgress, cancelToken: cancelToken);
  } catch (e) {
    print(e);
  }
}

void showDownloadProgress(received, total) {
  if (total != -1) {
    String downloadPer = (received / total * 100).toStringAsFixed(0) + "%";
    if(downloadPer.contains("99")){
      Fluttertoast.showToast(
          msg: "Download Completed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }else if(downloadPer.contains("100")) {
      Fluttertoast.cancel();
    }
    print(downloadPer);
  }
}