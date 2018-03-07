import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';

class SportFormField extends FormField<String> {
  SportFormField({
    Key key,
    String initialValue: '',
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
              final SportFormFieldState state = field;

              final InputDecoration effectiveDecoration = (decoration ??
                      const InputDecoration())
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return new InputDecorator(
                  decoration:
                      effectiveDecoration.copyWith(errorText: field.errorText),
                  child: new DropdownButton(
                      hint: new Text(Messages.of(state.context).opponentselect),
                      items: state._buildItems(state.context),
                      value: state.value,
                      onChanged: (dynamic val) {
                        state.setValue(val);
                        field.onChanged(val);
                        if (onFieldSubmitted != null) {
                          onFieldSubmitted(val);
                        }
                      }));
            });

  @override
  SportFormFieldState createState() => new SportFormFieldState();
}

class SportFormFieldState extends FormFieldState<String> {
  @override
  SportFormField get widget => super.widget;

  List<DropdownMenuItem> _buildItems(BuildContext context) {
    List<DropdownMenuItem> ret = new List<DropdownMenuItem>();
    ret.add(new DropdownMenuItem(
      child: new Text(Messages.of(context).sportselect),
      value: 'none',
    ));

    ret.add(new DropdownMenuItem(
      child: new Text(Messages.of(context).sportbasketball),
      value: Sport.Basketball.toString(),
    ));

    ret.add(new DropdownMenuItem(
      child: new Text(Messages.of(context).sportsoftball),
      value: Sport.Softball.toString(),
    ));

    ret.add(new DropdownMenuItem(
      child: new Text(Messages.of(context).sportsoccer),
      value: Sport.Soccer.toString(),
    ));

    ret.add(new DropdownMenuItem(
      child: new Text(Messages.of(context).sportother),
      value: Sport.Other.toString(),
    ));

    return ret;
  }
}
