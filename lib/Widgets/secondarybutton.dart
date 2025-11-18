import '../Utils/packages.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.buttonText,
    required this.onPressFunction,
    this.buttonColor,
    this.textColor,
    this.borderColor,
  });

  final Color? buttonColor;
  final Color? borderColor;
  final Color? textColor;
  final String buttonText;
  final VoidCallback? onPressFunction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressFunction,
      child: Container(
        width: 100,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? kPrimaryColor),
          borderRadius: BorderRadius.circular(60),
          color: buttonColor ?? kdefwhiteColor,
        ),
        child: Center(
          child: Text(
            buttonText.toUpperCase(),
            style: TextStyle(
              color: textColor ?? kPrimaryColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
