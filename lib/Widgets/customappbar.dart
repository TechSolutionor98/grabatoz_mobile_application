import '../Utils/packages.dart';

// Define your custom widget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final Widget? titleWidget;
  final Widget? actionicon;
  final Color? backgroundColor;
  final bool showLeading;
  final VoidCallback? tapaction;
  const CustomAppBar({
    super.key,
    this.titleText,
    this.actionicon,
    this.showLeading = true,
    this.backgroundColor,
    this.tapaction,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      leading: showLeading
          ? GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
                size: 20,
              ),
            )
          : null,
      centerTitle: true,
      actions: [
        if (actionicon != null)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: tapaction,
              child: actionicon,
            ),
          ),
      ],
      elevation: 0,
      backgroundColor: backgroundColor ?? kPrimaryColor,
      shadowColor: Colors.transparent,
      foregroundColor: kdefwhiteColor,
      surfaceTintColor: kdefwhiteColor,
      title: titleWidget ??
          Text(
            titleText ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
