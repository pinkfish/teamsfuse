import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class RoleInTeamFormField extends FormField<String> {
  RoleInTeamFormField({
    Key key,
    String initialValue: 'none',
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
              final RoleInTeamFormFieldState state = field;

              final InputDecoration effectiveDecoration = (decoration ??
                      const InputDecoration())
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return new InputDecorator(
                decoration:
                    effectiveDecoration.copyWith(errorText: field.errorText),
                child: new DropdownButton<String>(
                  hint: new Text(Messages.of(state.context).opponentselect),
                  items: state._buildItems(state.context),
                  value: state.value,
                  onChanged: (String val) {
                    state.updateValue(val);
                    field.didChange(val);
                    if (onFieldSubmitted != null) {
                      onFieldSubmitted(val);
                    }
                  },
                ),
              );
            });

  @override
  RoleInTeamFormFieldState createState() => new RoleInTeamFormFieldState();
}

class RoleInTeamFormFieldState extends FormFieldState<String> {
  void updateValue(String val) {
    setValue(val);
  }

  List<DropdownMenuItem<String>> _buildItems(BuildContext context) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    ret.add(new DropdownMenuItem<String>(
      child: new Text(Messages.of(context).roleselect),
      value: 'none',
    ));

    RoleInTeam.values.forEach((RoleInTeam role) {
      ret.add(new DropdownMenuItem<String>(
        child: new Text(Messages.of(context).roleingame(role)),
        value: role.toString(),
      ));
    });

    return ret;
  }
}
