import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class GenderFormField extends FormField<String> {
  GenderFormField({
    Key key,
    String initialValue,
    InputDecoration decoration: const InputDecoration(),
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
  })
      : assert(initialValue != null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<String> field) {
            final GenderFormFieldState state = field;

            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return new InputDecorator(
              decoration:
                  effectiveDecoration.copyWith(errorText: field.errorText),
              child: new DropdownButton(
                hint: new Text(Messages.of(state.context).genderselect),
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

  @override
  GenderFormFieldState createState() => new GenderFormFieldState();
}

class GenderFormFieldState extends FormFieldState<String> {
  @override
  GenderFormField get widget => super.widget;

  void updateValue(String str) {
    setValue(str);
  }

  List<DropdownMenuItem> _buildItems(BuildContext context) {
    List<DropdownMenuItem> ret = new List<DropdownMenuItem>();
    ret.add(new DropdownMenuItem(
      child: new Text(Messages.of(context).genderfemale),
      value: Gender.Female.toString(),
    ));

    ret.add(new DropdownMenuItem(
      child: new Text(Messages.of(context).gendermale),
      value: Gender.Male.toString(),
    ));

    ret.add(new DropdownMenuItem(
      child: new Text(Messages.of(context).gendercoed),
      value: Gender.Coed.toString(),
    ));

    ret.add(new DropdownMenuItem(
      child: new Text(Messages.of(context).genderna),
      value: Gender.NA.toString(),
    ));

    return ret;
  }
}
