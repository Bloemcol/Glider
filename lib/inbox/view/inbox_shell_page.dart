import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glider/app/container/app_container.dart';
import 'package:glider/app/models/app_route.dart';
import 'package:glider/auth/cubit/auth_cubit.dart';
import 'package:glider/common/mixins/data_mixin.dart';
import 'package:glider/common/widgets/app_bar_progress_indicator.dart';
import 'package:glider/common/widgets/refreshable_scroll_view.dart';
import 'package:glider/inbox/cubit/inbox_cubit.dart';
import 'package:glider/item/widgets/indented_widget.dart';
import 'package:glider/item/widgets/item_loading_tile.dart';
import 'package:glider/item/widgets/item_tile.dart';
import 'package:glider/l10n/extensions/app_localizations_extension.dart';
import 'package:glider/navigation_shell/models/navigation_shell_action.dart';
import 'package:glider/settings/cubit/settings_cubit.dart';
import 'package:glider_domain/glider_domain.dart';
import 'package:go_router/go_router.dart';

class InboxShellPage extends StatefulWidget {
  const InboxShellPage(
    this._inboxCubit,
    this._itemCubitFactory,
    this._authCubit,
    this._settingsCubit, {
    super.key,
  });

  final InboxCubit _inboxCubit;
  final ItemCubitFactory _itemCubitFactory;
  final AuthCubit _authCubit;
  final SettingsCubit _settingsCubit;

  @override
  State<InboxShellPage> createState() => _InboxShellPageState();
}

class _InboxShellPageState extends State<InboxShellPage> {
  @override
  void initState() {
    unawaited(widget._inboxCubit.load());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: RefreshableScrollView(
        onRefresh: () async => unawaited(widget._inboxCubit.load()),
        slivers: [
          _SliverInboxAppBar(
            widget._inboxCubit,
            widget._authCubit,
          ),
          SliverSafeArea(
            top: false,
            sliver: _SliverInboxBody(
              widget._inboxCubit,
              widget._itemCubitFactory,
              widget._authCubit,
              widget._settingsCubit,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverInboxAppBar extends StatelessWidget {
  const _SliverInboxAppBar(this._inboxCubit, this._authCubit);

  final InboxCubit _inboxCubit;
  final AuthCubit _authCubit;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(context.l10n.inbox),
      flexibleSpace: AppBarProgressIndicator(_inboxCubit),
      actions: [
        BlocBuilder<AuthCubit, AuthState>(
          bloc: _authCubit,
          buildWhen: (previous, current) =>
              previous.isLoggedIn != current.isLoggedIn,
          builder: (context, authState) => MenuAnchor(
            menuChildren: [
              for (final action in NavigationShellAction.values)
                if (action.isVisible(null, authState))
                  MenuItemButton(
                    onPressed: () async => action.execute(context),
                    child: Text(action.label(context)),
                  ),
            ],
            builder: (context, controller, child) => IconButton(
              icon: Icon(Icons.adaptive.more_outlined),
              tooltip: MaterialLocalizations.of(context).showMenuTooltip,
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
            ),
          ),
        ),
      ],
      floating: true,
    );
  }
}

class _SliverInboxBody extends StatelessWidget {
  const _SliverInboxBody(
    this._inboxCubit,
    this._itemCubitFactory,
    this._authCubit,
    this._settingsCubit,
  );

  final InboxCubit _inboxCubit;
  final ItemCubitFactory _itemCubitFactory;
  final AuthCubit _authCubit;
  final SettingsCubit _settingsCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InboxCubit, InboxState>(
      bloc: _inboxCubit,
      builder: (context, state) => BlocBuilder<SettingsCubit, SettingsState>(
        bloc: _settingsCubit,
        buildWhen: (previous, current) =>
            previous.useLargeStoryStyle != current.useLargeStoryStyle ||
            previous.showStoryMetadata != current.showStoryMetadata,
        builder: (context, settingsState) => state.whenOrDefaultSlivers(
          loading: () => SliverList.builder(
            itemBuilder: (context, index) =>
                const ItemLoadingTile(type: ItemType.comment),
          ),
          nonEmpty: () => SliverList.list(
            children: [
              for (final (parentId, id) in state.data!) ...[
                ItemTile.create(
                  _itemCubitFactory,
                  _authCubit,
                  key: ValueKey<int>(parentId),
                  id: parentId,
                  loadingType: ItemType.story,
                  useLargeStoryStyle: settingsState.useLargeStoryStyle,
                  onTap: (context, item) async => context.push(
                    AppRoute.item.location(parameters: {'id': id}),
                  ),
                ),
                IndentedWidget(
                  depth: 1,
                  child: ItemTile.create(
                    _itemCubitFactory,
                    _authCubit,
                    key: ValueKey<int>(id),
                    id: id,
                    loadingType: ItemType.comment,
                    useLargeStoryStyle: settingsState.useLargeStoryStyle,
                    onTap: (context, item) async => context.push(
                      AppRoute.item.location(parameters: {'id': id}),
                    ),
                  ),
                ),
              ],
            ],
          ),
          onRetry: () async => _inboxCubit.load(),
        ),
      ),
    );
  }
}
