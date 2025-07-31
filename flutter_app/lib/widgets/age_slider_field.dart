import 'package:flutter/material.dart';

class AgeSliderField extends StatefulWidget {
  final String label;
  final IconData icon;
  final int? initialAge;
  final Function(int) onChanged;

  const AgeSliderField({
    super.key,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.initialAge,
  });

  @override
  State<AgeSliderField> createState() => _AgeSliderFieldState();
}

class _AgeSliderFieldState extends State<AgeSliderField> {
  late double _currentAge;

  @override
  void initState() {
    super.initState();
    _currentAge = (widget.initialAge ?? 25).toDouble();
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
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentAge.round()}歳',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.withOpacity(0.05),
          ),
          child: Column(
            children: [
              Slider(
                value: _currentAge,
                min: 10,
                max: 80,
                divisions: 70,
                activeColor: Theme.of(context).primaryColor,
                inactiveColor: Theme.of(context).primaryColor.withOpacity(0.3),
                onChanged: (double value) {
                  setState(() {
                    _currentAge = value;
                  });
                  widget.onChanged(value.round());
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '10歳',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '80歳',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}