import 'package:angular/angular.dart';

/// Conditionally shows content based on authentication status with Firebase.
///
/// ```html
/// <div *ifFirebaseAuth="true">
///   Logged in!
/// </div>
/// <div *ifFirebaseAuth="false">
///   Logged out!
/// </div>
/// ````
///
/// **NOTE**: Only a static value of "true" or "false" is supported.
///
/// You can get a handle to the logged in user:
///
/// ```html
/// <div *ifFirebaseAuth="true; let currentUser = currentUser">
///   Logged in as {{currentUser.displayName}}!
/// </div>
/// ```
@Directive(
  selector: '[ifFirebaseAuth]',
)
class IfFirebaseAuthDirective implements OnDestroy, OnInit {
  final TemplateRef _templateRef;
  final ViewContainerRef _viewContainerRef;

  bool _checkCondition;
  bool _lastCondition;

  IfFirebaseAuthDirective(
    this._templateRef,
    this._viewContainerRef,
  );

  @Input()
  set ifFirebaseAuth(bool newCondition) {
    print('Here ${UserDatabaseData.instance.userAuth.currentUserNoWait()}');
    _checkCondition = newCondition;
    _toggle(_checkCondition
        ? UserDatabaseData.instance.userAuth.currentUserNoWait() != null
        : UserDatabaseData.instance.userAuth.currentUserNoWait() == null);
  }

  @override
  void ngOnDestroy() {}

  @override
  void ngOnInit() {}

  void _toggle(bool show) {
    if (!show) {
      _signedOut();
    } else {
      _signedIn();
    }
  }

  void _signedIn() {
    if (_lastCondition == true) {
      return;
    }
    _viewContainerRef.createEmbeddedView(_templateRef).setLocal(
        'currentUser', UserDatabaseData.instance.userAuth.currentUserNoWait());
    _lastCondition = true;
  }

  void _signedOut() {
    if (_lastCondition == false) {
      return;
    }
    _viewContainerRef.clear();
    _lastCondition = false;
  }
}
