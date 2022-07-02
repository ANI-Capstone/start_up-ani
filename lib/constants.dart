import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

const primaryColor = Color(0xFFC6D8AF);
const textColor = Color(0xFF121212);
const backgroundColor = Color(0xFFE6EFF9);
const redColor = Color(0xFFE85050);
const borderColor = Color(0xFF121212);
const linkColor = Color(0xFF315300);

const defaultPadding = 32.0;

OutlineInputBorder textFieldBorder = OutlineInputBorder(
  borderSide: BorderSide(
    color: borderColor.withOpacity(0.1),
  ),
  borderRadius: BorderRadius.circular(15),
);

final passwordValidator = MultiValidator(
  [
    RequiredValidator(errorText: 'Password is required'),
    MinLengthValidator(8, errorText: 'Password must be at least 8 digits long'),
    PatternValidator(r'(?=.*?[#?!@$%^&*-])',
        errorText: 'Passwords must have at least one special character')
  ],
);

const double medium = 50;
const double small = 40;
