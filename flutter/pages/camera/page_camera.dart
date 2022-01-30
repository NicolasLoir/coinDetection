import 'package:coco/pages/camera/page_image.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PageCamera extends StatefulWidget {
  const PageCamera({Key? key}) : super(key: key);
  @override
  _PageCameraState createState() => _PageCameraState();
}

class _PageCameraState extends State<PageCamera> {
  CameraController? _controleur;
  List<CameraDescription>? cameras;
  CameraDescription? camera;
  Widget? apercuCamera;
  Image? image;
  Future definirCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      camera = cameras!.first;
    }
  }

  @override
  void initState() {
    definirCamera().then((_) {
      _controleur = CameraController(camera!, ResolutionPreset.medium);
      _controleur!.initialize().then((snapshot) {
        apercuCamera = Center(child: CameraPreview(_controleur!));
        setState(() {
          apercuCamera = apercuCamera;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controleur!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prendre une photo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () async {
              final nomFichierImage = join(
                (await getTemporaryDirectory()).path,
                '${DateTime.now()}.png',
              );
              await _controleur!.takePicture().then((XFile file) {
                file.saveTo(nomFichierImage);
                MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => PageImage(nomFichierImage));
                Navigator.push(context, route);
              });
            },
          ),
        ],
      ),
      body: Container(
        child: apercuCamera,
      ),
    );
  }
}
