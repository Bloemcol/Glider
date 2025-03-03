import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:glider/app/container/app_container.dart';
import 'package:glider/app/models/app_route.dart';
import 'package:glider/auth/cubit/auth_cubit.dart';
import 'package:glider/common/constants/app_spacing.dart';
import 'package:glider/common/extensions/uri_extension.dart';
import 'package:glider/common/widgets/decorated_card.dart';
import 'package:glider/l10n/extensions/app_localizations_extension.dart';
import 'package:glider/user/view/user_page.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatefulWidget {
  const AuthPage(
    this._authCubit,
    this._userCubitFactory,
    this._itemCubitFactory,
    this._userItemSearchBlocFactory, {
    super.key,
  });

  final AuthCubit _authCubit;
  final UserCubitFactory _userCubitFactory;
  final ItemCubitFactory _itemCubitFactory;
  final UserItemSearchBlocFactory _userItemSearchBlocFactory;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    unawaited(widget._authCubit.init());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => current.isLoggedIn,
      listener: (context, state) async {
        final confirm = await context.push<bool>(
          AppRoute.confirmDialog.location(),
          extra: (
            title: context.l10n.synchronize,
            text: context.l10n.synchronizeDescription,
          ),
        );
        if (confirm ?? false) {
          await widget._userCubitFactory(state.username!).synchronize();
        }
      },
      bloc: widget._authCubit,
      builder: (context, state) => state.isLoggedIn
          ? UserPage(
              widget._userCubitFactory,
              widget._itemCubitFactory,
              widget._userItemSearchBlocFactory,
              widget._authCubit,
              username: state.username!,
            )
          : Scaffold(
              body: CustomScrollView(
                slivers: [
                  const _SliverAuthAppBar(),
                  SliverSafeArea(
                    top: false,
                    sliver: _SliverAuthBody(widget._authCubit),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SliverAuthAppBar extends StatelessWidget {
  const _SliverAuthAppBar();

  @override
  Widget build(BuildContext context) {
    return const SliverAppBar();
  }
}

class _SliverAuthBody extends StatelessWidget {
  const _SliverAuthBody(this._authCubit);

  final AuthCubit _authCubit;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: AppSpacing.defaultTilePadding,
          sliver: SliverToBoxAdapter(
            child: DecoratedCard.outlined(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.l10n.authDescription),
                  TextButtonTheme(
                    data: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async => Uri.https(
                            'github.com',
                            'Mosc/Glider/blob/master/PRIVACY.md',
                          ).tryLaunch(),
                          child: Text(context.l10n.privacyPolicy),
                        ),
                        TextButton(
                          onPressed: () async => Uri.https(
                            'www.ycombinator.com',
                            'legal',
                          ).replace(fragment: 'privacy').tryLaunch(),
                          child: Text(context.l10n.privacyPolicyYc),
                        ),
                        TextButton(
                          onPressed: () async => Uri.https(
                            'www.ycombinator.com',
                            'legal',
                          ).replace(fragment: 'tou').tryLaunch(),
                          child: Text(context.l10n.termsOfUseYc),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(
                Uri.https('news.ycombinator.com', 'login').toString(),
              ),
            ),
            onPageCommitVisible: (controller, url) async => _authCubit.login(),
          ),
        ),
      ],
    );
  }
}
