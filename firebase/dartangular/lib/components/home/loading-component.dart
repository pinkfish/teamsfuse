import 'package:angular/angular.dart';

@Component(
  selector: 'loading-page',
  directives: const [],
  template: '''
  <h1>Connecting to firebase...</h1>
  ''',
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class LoadingComponent {}
