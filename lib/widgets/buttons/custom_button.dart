import 'package:flutter/material.dart';
import 'package:kazakhi_auto_admin/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final bool? isHole;
  final bool? isLoading;
  final bool? isEnabled;
  final Color? color;
  final Color? textColor;
  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isHole,
    this.color,
    this.textColor,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          (isEnabled != null)
              ? (isEnabled == true)
                  ? onTap
                  : null
              : onTap,
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
        decoration: BoxDecoration(
          border:
              (isHole == true) ? Border.all(color: AppColors.primary) : null,
          borderRadius: BorderRadius.circular(7),
          color:
              (isEnabled == false)
                  ? AppColors.primary.withOpacity(0.5)
                  : (isHole == true)
                  ? Colors.white
                  : (color != null)
                  ? color!
                  : AppColors.primary,
        ),
        child: Center(
          child:
              (isLoading == false)
                  ? Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color:
                          (isHole == true)
                              ? AppColors.primary
                              : (textColor != null)
                              ? textColor
                              : Colors.white,
                    ),
                  )
                  : SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
        ),
      ),
    );
  }
}
