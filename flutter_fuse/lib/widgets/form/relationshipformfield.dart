import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// The relationship form field to track the current relationship.
///
class RelationshipFormField extends FormField<Relationship> {
  /// Constructor.
  RelationshipFormField({
    @required Relationship initialValue,
    Key key,
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<Relationship> onFieldSubmitted,
    FormFieldSetter<Relationship> onSaved,
    FormFieldValidator<Relationship> validator,
  })  : assert(initialValue != null),
        super(
          key: key ?? Key("RELATIONSHIP"),
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (field) {
            var state = field as RelationshipFormFieldState;

            var effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return InputDecorator(
              decoration:
                  effectiveDecoration.copyWith(errorText: field.errorText),
              child: DropdownButton<Relationship>(
                hint: Text(Messages.of(state.context).relationshipselect),
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
  RelationshipFormFieldState createState() => RelationshipFormFieldState();
}

///
/// The state to deal with the relationship for the form field.
///
class RelationshipFormFieldState extends FormFieldState<Relationship> {
  /// Update the value for the relationship.
  void updateValue(Relationship val) {
    setValue(val);
  }

  List<DropdownMenuItem<Relationship>> _buildItems(BuildContext context) {
    var ret = <DropdownMenuItem<Relationship>>[];
    ret.add(DropdownMenuItem<Relationship>(
      child: Text(Messages.of(context).relationships(Relationship.Friend)),
      value: Relationship.Friend,
    ));

    ret.add(DropdownMenuItem<Relationship>(
      child: Text(Messages.of(context).relationships(Relationship.Parent)),
      value: Relationship.Parent,
    ));

    ret.add(DropdownMenuItem<Relationship>(
      child: Text(Messages.of(context).relationships(Relationship.Guardian)),
      value: Relationship.Guardian,
    ));

    return ret;
  }
}
