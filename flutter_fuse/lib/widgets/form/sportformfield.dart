import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// The form field to select the sport.
///
class SportFormField extends FormField<Sport> {
  /// COnstructor.
  SportFormField({
    Key key,
    Sport initialValue = Sport.Other,
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<Sport> onFieldSubmitted,
    FormFieldSetter<Sport> onSaved,
    FormFieldValidator<Sport> validator,
  })  : assert(initialValue != null),
        super(
            key: key ?? Key("SPORT"),
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            builder: (field) {
              var state = field as SportFormFieldState;

              var effectiveDecoration = (decoration ?? const InputDecoration())
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return InputDecorator(
                  decoration:
                      effectiveDecoration.copyWith(errorText: field.errorText),
                  child: DropdownButton<Sport>(
                      hint: Text(Messages.of(state.context).opponentselect),
                      items: state._buildItems(state.context),
                      value: state.value,
                      onChanged: (val) {
                        state.updateValue(val);
                        field.didChange(val);
                        if (onFieldSubmitted != null) {
                          onFieldSubmitted(val);
                        }
                      }));
            });

  @override
  SportFormFieldState createState() => SportFormFieldState();
}

///
/// The internal field state for the sport form.
///
class SportFormFieldState extends FormFieldState<Sport> {
  /// The updated value to set the specific sport value.
  void updateValue(Sport val) {
    setValue(val);
  }

  List<DropdownMenuItem<Sport>> _buildItems(BuildContext context) {
    var ret = <DropdownMenuItem<Sport>>[];

    for (var sport in Sport.values) {
      ret.add(DropdownMenuItem<Sport>(
        child: Text(Messages.of(context).sportname(sport)),
        value: sport,
      ));
    }

    return ret;
  }
}
