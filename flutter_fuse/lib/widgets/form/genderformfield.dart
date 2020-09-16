import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

class GenderFormField extends FormField<Gender> {
  GenderFormField({
    @required Gender initialValue,
    Key key,
    InputDecoration decoration: const InputDecoration(),
    ValueChanged<Gender> onFieldSubmitted,
    FormFieldSetter<Gender> onSaved,
    FormFieldValidator<Gender> validator,
  })  : assert(initialValue != null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<Gender> field) {
            final GenderFormFieldState state = field as GenderFormFieldState;

            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return InputDecorator(
              decoration:
                  effectiveDecoration.copyWith(errorText: field.errorText),
              child: DropdownButton<Gender>(
                hint: Text(Messages.of(state.context).genderselect),
                items: state._buildItems(state.context),
                value: state.value,
                onChanged: (Gender val) {
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
  GenderFormFieldState createState() => GenderFormFieldState();
}

class GenderFormFieldState extends FormFieldState<Gender> {
  @override
  GenderFormField get widget {
    GenderFormField field = super.widget as GenderFormField;
    return field;
  }

  void updateValue(Gender str) {
    setValue(str);
  }

  List<DropdownMenuItem<Gender>> _buildItems(BuildContext context) {
    List<DropdownMenuItem<Gender>> ret = <DropdownMenuItem<Gender>>[];
    ret.add(DropdownMenuItem<Gender>(
      child: Text(Messages.of(context).genderfemale),
      value: Gender.Female,
    ));

    ret.add(DropdownMenuItem<Gender>(
      child: Text(Messages.of(context).gendermale),
      value: Gender.Male,
    ));

    ret.add(DropdownMenuItem<Gender>(
      child: Text(Messages.of(context).gendercoed),
      value: Gender.Coed,
    ));

    ret.add(DropdownMenuItem<Gender>(
      child: Text(Messages.of(context).genderna),
      value: Gender.NA,
    ));

    return ret;
  }
}
