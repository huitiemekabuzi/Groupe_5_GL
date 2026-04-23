import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ismgl/app/routes/app_routes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String  title;
  final bool    showBack;
  final bool    showNotification;
  final bool    showProfile;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack         = false,
    this.showNotification = true,
    this.showProfile      = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: showBack ? 0 : 16,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: Get.back,
            )
          : null,
      automaticallyImplyLeading: showBack,
      actions: [
        if (showProfile)
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}