import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class RelationshipFormField extends FormField<Relationship> {
  RelationshipFormField({
    @required Relationship initialValue,
    Key key,
    InputDecoration decoration: const InputDecoration(),
    ValueChanged<Relationship> onFieldSubmitted,
    FormFieldSetter<Relationship> onSaved,
    FormFieldValidator<Relationship> validator,
  })  : assert(initialValue != null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<Relationship> field) {
            final RelationshipFormFieldState state = field;

            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return new InputDecorator(
              decoration:
                  effectiveDecoration.copyWith(errorText: field.errorText),
              child: new DropdownButton<Relationship>(
                hint: new Text(Messages.of(state.context).relationshipselect),
                items: state._buildItems(state.context),
                value: state.value,
                onChanged: (Relationship val) {
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
  RelationshipFormFieldState createState() => new RelationshipFormFieldState();
}

class RelationshipFormFieldState extends FormFieldState<Relationship> {
  void updateValue(Relationship val) {
    setValue(val);
  }

  List<DropdownMenuItem<Relationship>> _buildItems(BuildContext context) {
    List<DropdownMenuItem<Relationship>> ret =
        <DropdownMenuItem<Relationship>>[];
    ret.add(new DropdownMenuItem<Relationship>(
      child: new Text(Messages.of(context).relationships(Relationship.Friend)),
      value: Relationship.Friend,
    ));

    ret.add(new DropdownMenuItem<Relationship>(
      child: new Text(Messages.of(context).relationships(Relationship.Parent)),
      value: Relationship.Parent,
    ));

    ret.add(new DropdownMenuItem<Relationship>(
      child:
          new Text(Messages.of(context).relationships(Relationship.Guardian)),
      value: Relationship.Guardian,
    ));

    return ret;
  }
}
