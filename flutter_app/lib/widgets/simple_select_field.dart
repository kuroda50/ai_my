import 'package:flutter/material.dart';

class SimpleSelectField extends StatefulWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final IconData icon;
  final Function(String?) onChanged;

  const SimpleSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.icon,
    required this.onChanged,
    this.selectedValue,
  });

  @override
  State<SimpleSelectField> createState() => _SimpleSelectFieldState();
}

class _SimpleSelectFieldState extends State<SimpleSelectField> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.withOpacity(0.05),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedValue,
              isExpanded: true,
              hint: Text(
                '選択してください',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              items: widget.options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedValue = newValue;
                });
                widget.onChanged(newValue);
              },
              dropdownColor: Colors.white,
              elevation: 8,
            ),
          ),
        ),
      ],
    );
  }
}