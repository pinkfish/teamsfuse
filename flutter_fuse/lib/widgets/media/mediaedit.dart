import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/messages.dart';

///
/// Callback whenm the media is ready to save.
///
typedef MediaEditCallback = void Function(
    Uri url, String description, DateTime start);

///
/// Class top handle editing the media, does a callback whemn the
/// media is ready to save.
///
class MediaEdit extends StatefulWidget {
  final MediaInfo media;
  final MediaEditCallback onSave;
  final Function onDelete;
  final DateTime start;

  MediaEdit({this.media, this.onSave, this.onDelete, this.start});

  @override
  State<StatefulWidget> createState() {
    return _MediaEditState();
  }
}

class _MediaEditState extends State<MediaEdit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Uri _url;
  String _description;
  DateTime _start;

  void _saveForm() {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(Messages.of(context).formError)));

      return;
    }
    _formKey.currentState.save();
    widget.onSave(_url, _description, _start);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autovalidateMode: AutovalidateMode.disabled,
            decoration: InputDecoration(
              icon: Icon(Icons.local_library),
              hintText: Messages.of(context).urlTitle,
              labelText: Messages.of(context).urlTitle,
            ),
            onSaved: (String str) {
              _url = Uri.parse(str);
            },
            initialValue: widget.media?.url ?? '',
            validator: (String str) {
              try {
                if (str == null || str == '') {
                  return Messages.of(context).emptyText;
                }
                var url = Uri.parse(str);

                if (url == null) {
                  return Messages.of(context).invalidUrl;
                }
              } catch (e) {
                return Messages.of(context).invalidUrl;
              }
              return null;
            },
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.disabled,
            decoration: InputDecoration(
              icon: Icon(MdiIcons.text),
              hintText: Messages.of(context).description,
              labelText: Messages.of(context).description,
            ),
            onSaved: (String str) {
              _description = str;
            },
            initialValue: widget.media?.description ?? '',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ButtonBar(
              children: [
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel,
                      style: Theme.of(context).textTheme.button),
                ),
                FlatButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text(
                      MaterialLocalizations.of(context).deleteButtonTooltip,
                      style: Theme.of(context).textTheme.button),
                  onPressed: () => _saveForm(),
                ),
                RaisedButton.icon(
                  textTheme: ButtonTextTheme.primary,
                  elevation: 2,
                  icon: Icon(Icons.save),
                  label: Text(Messages.of(context).saveButtonText,
                      style: Theme.of(context).textTheme.button),
                  onPressed: () => _saveForm(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
