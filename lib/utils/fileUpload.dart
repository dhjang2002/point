// ignore_for_file: file_names, invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:point/utils/mediaView.dart';
import 'package:point/utils/utils.dart';
import 'package:point/utils/mediaViewer.dart';
import 'package:point/common/dialogbox.dart';
import 'package:point/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transition/transition.dart';

class UploadTest extends StatefulWidget {
  const UploadTest({Key? key}) : super(key: key);

  @override
  State<UploadTest> createState() => _UploadTestState();
}

class _UploadTestState extends State<UploadTest> {
  bool _isVideo = false;
  bool _upLoading = false;
  String _sourceUrl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("File Upload"),
          actions: [
            Visibility(
              visible: true,
              child: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    fromCameraVideo();
                  }),
            ),
            Visibility(
              visible: true,
              child: IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () {
                    fromGallery();
                  }),
            ),
            Visibility(
              visible: true,
              child: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    _showDetail();
                  }),
            ),
          ],
        ),
        body: _showPhoto());
  }

  Widget _showPhoto() {
    if (_upLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sourceUrl.isNotEmpty) {
      return SizedBox(
        width: 200,
        height: 80,
        child: MediaView(
          isMovie: _isVideo,
          sourceUrl: _sourceUrl,),
      );
    }
    return Container();
  }

  void _showDetail() {
    Navigator.push(
        context,
        Transition(
            child: MediaViewer(isMovie: _isVideo, sourceUrl: _sourceUrl),
            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
  }

  Future<void> fromCamera() async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.camera);
    if (image != null) {
      File pick = File(image.path);

      // cropImage
      CroppedFile? crop = await cropImage(pick);
      if (crop != null) {
        pick = File(crop.path);
        showToastMessage("파일이 준비되었습니다.");
        upLoad(true, pick.path);
      }
    }
  }

  Future<void> fromCameraVideo() async {
    var pickedMovie = await ImagePicker.platform.getVideo(
        source: ImageSource.camera, maxDuration: const Duration(seconds: 15));
    if (pickedMovie != null) {
      File pick = File(pickedMovie.path);

      // cropImage
      //File? crop = await cropImage(pick);
      //if (crop != null)
      {
        //showToastMessage("파일이 준비되었습니다.");
        upLoad(false, pick.path);
      }
    }
  }

  Future<void> fromGallery() async {
    File? pick = await pickupImage();
    if (pick != null) {
      String ext = getExtFromPath(pick.path);
      if (ext == "png" || ext == "jpg" || ext == "jpeg") {
        CroppedFile? crop = await cropImage(pick);
        if (crop != null) {
          pick = File(crop.path);
          showToastMessage("파일이 준비되었습니다.");
          upLoad(true, pick.path);
        }
      }
    }
  }

  Future<void> upLoad(bool isPicture, String filePath) async {
    setState(() {
      _isVideo = !isPicture;
      _sourceUrl = "";
      _upLoading = true;
    });

    await Remote.upLoad(
        method: "api/fup",
        token: "abcdef",
        filePath: filePath,
        params: {"target": "user_movie"},
        onResult: (dynamic params) {
          Map<String, dynamic> data = params;
          _sourceUrl = data["path"];
          showToastMessage("처리되었습니다.");
        },
        onError: (String error) {});
    setState(() {
      _upLoading = false;
    });
  }
}
