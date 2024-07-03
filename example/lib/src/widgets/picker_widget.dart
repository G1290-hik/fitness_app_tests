// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';

class PickerWidget extends StatefulWidget {
  PickerWidget({
    super.key,
    required this.start,
    required this.max,
    required this.min,
    required this.step,
    required this.fontsize,
    this.color = AppColors.contentColorWhite,
    this.change = 0,
    required this.onChange,
  });

  final double start;
  final double max;
  final double min;
  final double step;
  final double fontsize;
  final Color color;
  final int change;
  final ValueChanged<double> onChange;

  @override
  State<PickerWidget> createState() => _PickerWidgetState();
}

class _PickerWidgetState extends State<PickerWidget> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.start;
  }

  void _increment() {
    setState(() {
      if (_currentValue + widget.step <= widget.max) {
        _currentValue += widget.step;
        widget.onChange(_currentValue);
      }
    });
  }

  void _decrement() {
    setState(() {
      if (_currentValue - widget.step >= widget.min) {
        _currentValue -= widget.step;
        widget.onChange(_currentValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: _decrement,
          icon: Icon(
            Icons.remove_circle,
            color: widget.color,
            size: 40,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.contentColorBlack.withOpacity(0.3),
            ),
          ),
          child: Text(
            _currentValue.toStringAsFixed(widget.change),
            style: TextStyle(
                fontSize: widget.fontsize,
                color: widget.color,
                fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: _increment,
          icon: Icon(
            Icons.add_circle,
            color: widget.color,
            size: 40,
          ),
        ),
      ],
    );
  }
}
