import 'package:flutter/material.dart';
import 'package:kazakhi_auto_admin/constants/app_colors.dart';

class CustomTextfield extends StatefulWidget {
  final String hintText;
  final IconData? rightIcon;
  final TextEditingController controller;
  final bool isPassword; // Flag to determine if it's a password field
  final bool? isLoading;
  final int? maxLength;

  const CustomTextfield({
    super.key,
    required this.hintText,
    this.rightIcon,
    this.maxLength,
    this.isLoading = false,
    required this.controller,
    this.isPassword = false, // Default to false if it's not a password field
  });

  @override
  _CustomTextfieldState createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Toggle the visibility
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary, // Background color
        borderRadius: BorderRadius.circular(8), // Rounded corners
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ), // Border color
      ),
      child: TextField(
        enabled: widget.isLoading == true ? false : true,
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        maxLength: widget.maxLength,
        decoration: InputDecoration(
          counterText: "",
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey), // Hint text color
          border: InputBorder.none, // Removes default border
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ), // Padding inside the field
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min, // Keep content compact
            children: [
              if (widget.isPassword)
                IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off
                        : Icons.visibility, // Toggle icon
                    color: Colors.black,
                  ),
                  onPressed:
                      _togglePasswordVisibility, // Toggle password visibility
                ),
              if (widget.isLoading == true)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue, // Replace with your primary color
                  ),
                ),
              if (widget.maxLength != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8,
                  ), // Add some spacing
                  child: Text(
                    '${widget.controller.text.length}/${widget.maxLength}',
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ),
              if (widget.rightIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(widget.rightIcon),
                ),
            ],
          ),
        ),
        style: const TextStyle(color: Colors.black), // Text color
        cursorColor: Colors.black, // Cursor color
        onChanged: (value) {
          setState(() {}); // Update UI on text change
        },
      ),
    );
  }
}
