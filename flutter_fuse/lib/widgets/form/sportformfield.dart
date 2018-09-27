import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class SportFormField extends FormField<Sport> {
  SportFormField({
    Key key,
    Sport initialValue: Sport.Other,
    InputDecoration decoration: const InputDecoration(),
    ValueChanged<Sport> onFieldSubmitted,
    FormFieldSetter<Sport> onSaved,
    FormFieldValidator<Sport> validator,
  })  : assert(initialValue != null),
        super(
            key: key,
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            builder: (FormFieldState<Sport> field) {
              final SportFormFieldState state = field;

              final InputDecoration effectiveDecoration = (decoration ??
                      const InputDecoration())
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return new InputDecorator(
                  decoration:
                      effectiveDecoration.copyWith(errorText: field.errorText),
                  child: new DropdownButton<Sport>(
                      hint: new Text(Messages.of(state.context).opponentselect),
                      items: state._buildItems(state.context),
                      value: state.value,
                      onChanged: (Sport val) {
                        state.updateValue(val);
                        field.didChange(val);
                        if (onFieldSubmitted != null) {
                          onFieldSubmitted(val);
                        }
                      }));
            });

  @override
  SportFormFieldState createState() => new SportFormFieldState();
}

class SportFormFieldState extends FormFieldState<Sport> {
  void updateValue(Sport val) {
    setValue(val);
  }

  List<DropdownMenuItem<Sport>> _buildItems(BuildContext context) {
    List<DropdownMenuItem<Sport>> ret = <DropdownMenuItem<Sport>>[];

    Sport.values.forEach((Sport sport) {
      ret.add(new DropdownMenuItem<Sport>(
        child: new Text(Messages.of(context).sportname(sport)),
        value: sport,
      ));
    });

    return ret;
  }
}
