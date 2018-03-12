import 'package:flutter_fuse/Routes.dart';
import 'package:flutter_fuse/cache/cachemanager.dart';

void main() {
  CacheManager.getInstance().then((CacheManager man) {
    print('got manager');
  }).catchError((Exception error) {
    print('Got error $error');
  });
  new Routes();
}
