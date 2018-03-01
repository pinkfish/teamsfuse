import 'package:flutter_fuse/Routes.dart';
import 'package:firebase_core/firebase_core.dart';


void main() {
  FirebaseApp.allApps().then((apps) {
    print(apps);
  });
  new Routes();
}

