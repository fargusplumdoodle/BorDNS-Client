import 'package:flutter/material.dart';

typedef SubmitFunc = void Function(String s);

class DomainFormField extends TextFormField {
  DomainFormField({
    Key? key,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    required SubmitFunc onFieldSubmitted,
  }) : super(
          key: key,
          initialValue: initialValue,
          onFieldSubmitted: onFieldSubmitted,
          onSaved: onSaved,
          decoration: const InputDecoration(labelText: "Domain"),
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Invalid Domain';
            }
            return null;
          },
        );
}

class IPFormField extends TextFormField {
  IPFormField({
    Key? key,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    required SubmitFunc onFieldSubmitted,
  }) : super(
          key: key,
          initialValue: initialValue,
          onFieldSubmitted: onFieldSubmitted,
          onSaved: onSaved,
          decoration: const InputDecoration(labelText: "IP Address"),
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Invalid IP Address';
            }
            return null;
          },
        );
}
