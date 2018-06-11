import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class SportFormField extends FormField<String> {
  SportFormField({
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
              final SportFormFieldState state = field;

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
                      }));
            });

  @override
  SportFormFieldState createState() => new SportFormFieldState();
}

class SportFormFieldState extends FormFieldState<String> {
  void updateValue(String val) {
    setValue(val);
  }

  List<DropdownMenuItem<String>> _buildItems(BuildContext context) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    ret.add(new DropdownMenuItem<String>(
      child: new Text(Messages.of(context).sportselect),
      value: 'none',
    ));

    Sport.values.forEach((Sport sport) {
      ret.add(new DropdownMenuItem<String>(
        child: new Text(Messages.of(context).sportname(sport)),
        value: sport.toString(),
      ));
    });

    return ret;
  }
}
