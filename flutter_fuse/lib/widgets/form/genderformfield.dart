import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// Selector to select the gender in a form.
///
class GenderFormField extends FormField<Gender> {
  /// Constructor.
  GenderFormField({
    @required Gender initialValue,
    Key key,
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<Gender> onFieldSubmitted,
    FormFieldSetter<Gender> onSaved,
    FormFieldValidator<Gender> validator,
  })  : assert(initialValue != null),
        super(
          key: key ?? Key('GENDER'),
          initialValue: initialValue ?? Gender.Female,
          onSaved: onSaved,
          validator: validator,
          builder: (var field) {
            var state = field as _GenderFormFieldState;

            var effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return InputDecorator(
              decoration:
                  effectiveDecoration.copyWith(errorText: field.errorText),
              child: DropdownButton<Gender>(
                hint: Text(Messages.of(state.context).genderselect),
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
          },
        );

  @override
  _GenderFormFieldState createState() => _GenderFormFieldState();
}

class _GenderFormFieldState extends FormFieldState<Gender> {
  @override
  GenderFormField get widget {
    var field = super.widget as GenderFormField;
    return field;
  }

  void updateValue(Gender str) {
    setValue(str);
  }

  List<DropdownMenuItem<Gender>> _buildItems(BuildContext context) {
    var ret = <DropdownMenuItem<Gender>>[];
    ret.add(DropdownMenuItem<Gender>(
      value: Gender.Female,
      child: Text(Messages.of(context).genderfemale),
    ));

    ret.add(DropdownMenuItem<Gender>(
      value: Gender.Male,
      child: Text(Messages.of(context).gendermale),
    ));

    ret.add(DropdownMenuItem<Gender>(
      value: Gender.Coed,
      child: Text(Messages.of(context).gendercoed),
    ));

    ret.add(DropdownMenuItem<Gender>(
      value: Gender.NA,
      child: Text(Messages.of(context).genderna),
    ));

    return ret;
  }
}
