import 'package:flutter/material.dart';
import 'package:glider/app/models/app_route.dart';
import 'package:glider/auth/cubit/auth_cubit.dart';
import 'package:glider/common/interfaces/menu_item.dart';
import 'package:glider/l10n/extensions/app_localizations_extension.dart';
import 'package:go_router/go_router.dart';

enum NavigationShellAction implements MenuItem<void> {
  settings,
  account;

  const NavigationShellAction();

  @override
  bool isVisible(void _, AuthState authState) {
    return switch (this) {
      NavigationShellAction.settings => true,
      NavigationShellAction.account => true,
    };
  }

  @override
  String label(BuildContext context) {
    return switch (this) {
      NavigationShellAction.settings => context.l10n.settings,
      NavigationShellAction.account => context.l10n.account,
    };
  }

  @override
  IconData get icon {
    return switch (this) {
      NavigationShellAction.settings => Icons.settings_outlined,
      NavigationShellAction.account => Icons.account_circle_outlined,
    };
  }

  Future<void> execute(BuildContext context) async {
    switch (this) {
      case NavigationShellAction.settings:
        await context.push(AppRoute.settings.location());
      case NavigationShellAction.account:
        await context.push(AppRoute.auth.location());
    }
  }
}
