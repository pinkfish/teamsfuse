import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';

class PlayerFormField extends FormField<String> {
  PlayerFormField({
    Key key,
    String initialValue: '',
    InputDecoration decoration: const InputDecoration(),
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
  })  : assert(initialValue != null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<String> field) {
            final PlayerFormFieldState state = field;

            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return new InputDecorator(
              decoration: effectiveDecoration.copyWith(
                errorText: field.errorText,
              ),
              child: new DropdownButton(
                hint: new Text(Messages.of(state.context).opponentselect),
                items: state._buildItems(state.context),
                value: state.value,
                onChanged: (dynamic val) {
                  state.setValue(val);
                  field.didChange(val);
                  if (onFieldSubmitted != null) {
                    onFieldSubmitted(val);
                  }
                },
              ),
            );
          },
        );

  @override
  PlayerFormFieldState createState() => new PlayerFormFieldState();
}

class PlayerFormFieldState extends FormFieldState<String> {
  @override
  PlayerFormField get widget => super.widget;

  StreamSubscription<UpdateReason> playerSubscription;

  void setTeamUid(String teamUid) {
    setState(() {
      if (playerSubscription != null) {
        playerSubscription.cancel();
      }
      playerSubscription =
          UserDatabaseData.instance.playerStream.listen((UpdateReason value) {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (playerSubscription != null) {
      playerSubscription.cancel();
      playerSubscription = null;
    }
  }

  List<DropdownMenuItem> _buildItems(BuildContext context) {
    List<DropdownMenuItem> ret = new List<DropdownMenuItem>();
    ret.add(
      new DropdownMenuItem(
        child: new Text(Messages.of(context).opponentselect),
        value: 'none',
      ),
    );

    ret.add(new DropdownMenuItem(
        child: new Text(Messages.of(context).addplayer), value: 'add'));

    UserDatabaseData.instance.players.forEach((String key, Player player) {
      if (player.name != null) {
        ret.add(
          new DropdownMenuItem(
            child: new Text(player.name),
            value: player.uid,
          ),
        );
      }
    });

    return ret;
  }
}
