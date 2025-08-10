// lib/widgets/status_dropdown.dart
import 'package:flutter/material.dart';

class StatusDropdown extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String labelText;

  final List<String> statusEnum = const [
    'purchased',
    'in_transit_to_port',
    'at_international_port',
    'on_board',
    'in_transit_to_receiving_port',
    'at_receiving_port',
    'cleared_customs',
    'delivered',
    'cancelled',
  ];

  const StatusDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items:
            statusEnum.map((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(
                  status.replaceAll('_', ' ').toTitleCase(),
                ), // Makes it more readable
              );
            }).toList(),
        onChanged: onChanged,
        hint: Text('Select $labelText'),
      ),
    );
  }
}

// Extension to convert snake_case to Title Case for display
extension StringCasingExtension on String {
  String toTitleCase() {
    return replaceAll(RegExp('[_]+'), ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
