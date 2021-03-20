import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../util/ensurevisiblewhenfocused.dart';
import 'clubimage.dart';

///
/// A form to edit the details of the club.
///
class EditNewsItemDetailsForm extends StatefulWidget {
  /// Constructor.
  EditNewsItemDetailsForm(
      this.club, this.newsItem, GlobalKey<EditNewsItemDetailsFormState> key)
      : super(key: key);

  /// The club the newsItem is part of.
  final Club club;

  /// The club to edit the details of.
  final NewsItem newsItem;

  @override
  EditNewsItemDetailsFormState createState() {
    return EditNewsItemDetailsFormState();
  }
}

///
/// State for editing the details of the club and doing stuff.
///
class EditNewsItemDetailsFormState extends State<EditNewsItemDetailsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool _autovalidate = false;
  final Validations _validations = Validations();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodeSubject = FocusNode();
  final FocusNode _focusNodeBody = FocusNode();
  String _newsItemSubject;
  String _newsItemBody;

  @override
  void initState() {
    super.initState();
    _newsItemSubject = widget.newsItem.subject;
    _newsItemBody = widget.newsItem.body;
  }

  /// Save the club details.
  void save() {
    _formKey.currentState.save();
  }

  /// validate the club details.
  bool validate() {
    return _formKey.currentState.validate();
  }

  /// Validate the details and create the club for saving.
  NewsItemBuilder validateAndCreate() {
    if (!_formKey.currentState.validate()) {
      return null;
    } else {
      _formKey.currentState.save();
      var newsItem = widget.newsItem.toBuilder()
        ..subject = _newsItemSubject
        ..body = _newsItemBody;

      // club, add in the default admin.
      return newsItem;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.club == null) {
      return Text('Invalid state');
    }

    var fields = <Widget>[
      EnsureVisibleWhenFocused(
        focusNode: _focusNodeSubject,
        child: TextFormField(
          decoration: InputDecoration(
            icon: const Icon(Icons.subject),
            hintText: Messages.of(context).subject,
            labelText: Messages.of(context).subject,
          ),
          focusNode: _focusNodeSubject,
          initialValue: widget.newsItem.subject,
          keyboardType: TextInputType.text,
          obscureText: false,
          validator: (value) {
            return _validations.validateSubject(context, value);
          },
          onSaved: (value) {
            _newsItemSubject = value;
          },
        ),
      ),
      EnsureVisibleWhenFocused(
        focusNode: _focusNodeBody,
        child: TextFormField(
          decoration: InputDecoration(
            icon: const Icon(Icons.info_outline),
            hintText: Messages.of(context).message,
            labelText: Messages.of(context).message,
          ),
          focusNode: _focusNodeBody,
          initialValue: widget.newsItem.body,
          keyboardType: TextInputType.text,
          maxLines: 4,
          obscureText: false,
          onSaved: (value) {
            _newsItemBody = value;
          },
        ),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ListTile(
            leading: ClubImage(clubUid: widget.club.uid),
            title: Text(
              widget.club.name,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Form(
            key: _formKey,
            autovalidateMode: _autovalidate
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: DropdownButtonHideUnderline(
              child: Column(children: fields),
            ),
          ),
        ],
      ),
    );
  }
}
