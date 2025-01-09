import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LinkedTextField extends StatefulWidget{
  const LinkedTextField({ super.key,
    required this.textController,
    required this.inputFilter,
    this.prefixText,
    this.suffixText,
    required this.submitFunction,
  });

  final TextEditingController textController;
  final RegExp inputFilter;
  final String? prefixText;
  final String? suffixText;
  final void Function(String) submitFunction;

  @override
  State<LinkedTextField> createState() => _LinkedTextFieldState();
}

class _LinkedTextFieldState extends State<LinkedTextField>{
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(widget.inputFilter)],
        controller: widget.textController,
        decoration: InputDecoration(
          prefixText: widget.prefixText ?? '',
          suffixText: widget.suffixText ?? '',
          border: UnderlineInputBorder(),
          isCollapsed: true,
        ),
        onSubmitted: widget.submitFunction,
      ),
    );
  }
}