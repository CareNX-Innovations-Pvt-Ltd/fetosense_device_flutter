import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reusable text field widget that displays a date picker dialog on tap.
///
/// `DatePickerTextField` shows a read-only text field with a calendar icon.
/// When tapped, it opens a date picker dialog, allowing the user to select a date.
/// The selected date is formatted as `dd-MM-yyyy` and displayed in the text field.
/// An optional callback [onDateSelected] is triggered when a date is picked.
///
/// Example usage:
/// ```dart
/// DatePickerTextField(
///   controller: myController,
///   label: "Birth Date",
///   onDateSelected: (date) => print(date),
/// )
/// ```

class DatePickerTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Function(DateTime)? onDateSelected;

  const DatePickerTextField({
    super.key,
    required this.controller,
    this.label = "Select Date",
    this.onDateSelected,
  });

  @override
  _DatePickerTextFieldState createState() => _DatePickerTextFieldState();
}

class _DatePickerTextFieldState extends State<DatePickerTextField> {
  /// Opens a date picker and updates the text field
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        widget.controller.text = DateFormat('dd-MM-yyyy').format(picked);
      });

      if (widget.onDateSelected != null) {
        widget.onDateSelected!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true, // Prevents manual input
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () => _selectDate(context), // Open calendar on tap
    );
  }
}
