import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class PlayerFormField extends FormField<String> {
  PlayerFormField({
    Key key,
    String initialValue: '',
    InputDecoration decoration: const InputDecoration(),
    this.addNew = true,
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
                  state.updateValue(val);
                  field.didChange(val);
                  if (onFieldSubmitted != null) {
                    onFieldSubmitted(val);
                  }
                },
              ),
            );
          },
        );

  static const String ADD = 'add';
  static const String NONE = 'none';

  final bool addNew;

  @override
  PlayerFormFieldState createState() => new PlayerFormFieldState();
}

class PlayerFormFieldState extends FormFieldState<String> {
  @override
  PlayerFormField get widget => super.widget;

  StreamSubscription<UpdateReason> playerSubscription;

  void updateValue(String val) {
    setValue(val);
  }


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
        child: new Text(Messages.of(context).playerselect),
        value: PlayerFormField.NONE,
      ),
    );

    if (widget.addNew) {
      ret.add(new DropdownMenuItem(
          child: new Text(Messages
              .of(context)
              .addplayer), value: PlayerFormField.ADD));
    }

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
