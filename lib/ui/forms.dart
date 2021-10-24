import 'package:flutter/material.dart';

class DomainFormField extends TextFormField {
  DomainFormField({
    Key? key,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
  }) : super(
          key: key,
          initialValue: initialValue,
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
  }) : super(
          key: key,
          initialValue: initialValue,
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
