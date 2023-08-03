import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawtracker/utils/constants.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final bool isReadOnly;
  final String hintText;
  final String labelText;
  final TextInputType textInputType;
  final TextCapitalization textCapitalization;
  const TextFieldInput({
    Key? key,
    required this.textEditingController,
    this.isReadOnly = false,
    this.isPass = false,
    required this.hintText,
    required this.labelText,
    required this.textInputType,
    required this.textCapitalization,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return TextField(
      readOnly: isReadOnly,
      controller: textEditingController,
      textCapitalization: textCapitalization,
      style: AppTextStyles.textFields,
      decoration: InputDecoration(
        fillColor: AppColors.greyAccent,
        hintText: hintText,
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.grey,
        ),
        labelText: labelText,
        labelStyle: AppTextStyles.body.copyWith(
          color: AppColors.grey,
        ),
        border: InputBorder.none,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.transparent, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
