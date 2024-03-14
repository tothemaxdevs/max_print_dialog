import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Function()? press;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? heigth;
  final double? borderRadius;
  final double? textSize;
  final EdgeInsetsGeometry? padding;

  const MyButton(
      {Key? key,
      required this.text,
      required this.press,
      this.color,
      this.padding,
      this.textColor,
      this.width,
      this.heigth,
      this.borderRadius,
      this.borderColor,
      this.textSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: heigth,
      width: width,
      child: ElevatedButton(
          onPressed: press,
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(0),
              padding: MaterialStateProperty.all(
                  padding ?? const EdgeInsets.all(16.0)),
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Color(0xFFDCDEE0);
                  } else if (states.contains(MaterialState.disabled)) {
                    return Color(0xFFF2F2F5);
                  } else if (states.contains(MaterialState.focused)) {
                    return Color(0xFFFFC700);
                  }
                  return color ??
                      Color(0xFFFFC700); // Use the component's default.
                },
              ),
              textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(color: textColor ?? Color(0xFF242632))),
              shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
                  (states) {
                return RoundedRectangleBorder(
                    side: !(states.contains(MaterialState.pressed))
                        ? BorderSide(color: borderColor ?? Colors.transparent)
                        : const BorderSide(color: Colors.transparent),
                    borderRadius:
                        BorderRadius.circular(borderRadius ?? 1000.0));
              })),
          child: Text(
            text,
            style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: textSize,
                fontWeight: FontWeight.w600),
          )),
    );
  }
}
