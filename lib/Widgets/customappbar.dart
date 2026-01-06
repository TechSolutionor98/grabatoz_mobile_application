import '../Utils/packages.dart';

// Define your custom widget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final Widget? titleWidget;
  final Widget? actionicon;
  final Color? backgroundColor;
  final bool showLeading;
  final VoidCallback? tapaction;
  final Widget? leadingWidget; 
  const CustomAppBar({
    super.key,
    this.titleText,
    this.actionicon,
    this.showLeading = true,
    this.backgroundColor,
    this.tapaction,
    this.titleWidget,
     this.leadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      
      automaticallyImplyLeading: false,
  leading: leadingWidget ??
    (showLeading
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
          )
        : null),
      
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
