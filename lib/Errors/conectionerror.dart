import 'package:graba2z/Utils/appextensions.dart';
import '../Utils/packages.dart';

class NoconnectionScreen extends StatelessWidget {
  const NoconnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: defaultPadding(vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // const Spacer(flex: 2),
            children: [
              // const Spacer(flex: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(AppImages.nowifi, fit: BoxFit.scaleDown),
                ),
              ),
              // const Spacer(flex: 2),
              const ErrorInfo(
                title: "Oops!....",
                description:
                    "Something wrong with your connection, Please connect to internet.",
                // press: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorInfo extends StatelessWidget {
  const ErrorInfo({
    super.key,
    required this.title,
    required this.description,
    this.button,
    this.btnText,
    // required this.press,
  });

  final String title;
  final String description;
  final Widget? button;
  final String? btnText;

  // final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            16.0.heightbox,
            Text(
              description,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
