import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// Role in the team form field.
///
class RoleInTeamFormField extends FormField<String> {
  /// Constructor.
  RoleInTeamFormField({
    Key key,
    String initialValue = 'none',
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
  })  : assert(initialValue != null),
        super(
            key: key,
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            builder: (field) {
              var state = field as RoleInTeamFormFieldState;

              var effectiveDecoration = (decoration ?? const InputDecoration())
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return InputDecorator(
                decoration:
                    effectiveDecoration.copyWith(errorText: field.errorText),
                child: DropdownButton<String>(
                  hint: Text(Messages.of(state.context).opponentselect),
                  items: state._buildItems(state.context),
                  value: state.value,
                  onChanged: (val) {
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
  RoleInTeamFormFieldState createState() => RoleInTeamFormFieldState();
}

///
/// The internal state for the role in team form field.
///
class RoleInTeamFormFieldState extends FormFieldState<String> {
  /// Updates the role to be the new value.
  void updateValue(String val) {
    setValue(val);
  }

  List<DropdownMenuItem<String>> _buildItems(BuildContext context) {
    var ret = <DropdownMenuItem<String>>[];
    ret.add(DropdownMenuItem<String>(
      child: Text(Messages.of(context).roleselect),
      value: 'none',
    ));

    for (var role in RoleInTeam.values) {
      ret.add(DropdownMenuItem<String>(
        child: Text(Messages.of(context).roleingame(role)),
        value: role.toString(),
      ));
    }

    return ret;
  }
}
