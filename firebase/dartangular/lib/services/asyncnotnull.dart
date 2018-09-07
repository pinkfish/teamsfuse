import 'package:angular/angular.dart';

/// Add the template content to the DOM if the input is not null.
///
///  If the expression assigned to `notNull` evaluates to a not null value
///  then the templated elements are removed removed from the DOM,
///  the templated elements are (re)inserted into the DOM.
///
///  <div *notNull="club" class="success">
///    Congrats! Everything is great!
///  </div>
///
///  ### Syntax
///
///  - `<div *notNull="val | async">...</div>`
///  - `<template [notNull]="val | async"><div>...</div></template>`
@Directive(selector: '[notNull]')
class AsyncNotNullDirective {
  bool _hasView = false;
  TemplateRef _templateRef;
  ViewContainerRef _viewContainer;

  AsyncNotNullDirective(this._templateRef, this._viewContainer);

  @Input()
  set notNull(dynamic obToCheck) {
    print('not null $obToCheck');
    if (obToCheck != null && !_hasView) {
      _viewContainer.createEmbeddedView(_templateRef);
      for (var i = 0, len = _viewContainer.length; i < len; i++) {
        _viewContainer.get(i).setLocal('notNullVal', obToCheck);
      }
      _hasView = true;
    } else if (obToCheck == null && _hasView) {
      _viewContainer.clear();
      _hasView = false;
    }
  }
}
