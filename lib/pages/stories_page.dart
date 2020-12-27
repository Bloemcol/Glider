import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:glider/models/story_type.dart';
import 'package:glider/pages/account_page.dart';
import 'package:glider/pages/favorites_page.dart';
import 'package:glider/providers/item_provider.dart';
import 'package:glider/providers/persistence_provider.dart';
import 'package:glider/utils/app_bar_util.dart';
import 'package:glider/utils/uni_links_handler.dart';
import 'package:glider/widgets/common/smooth_animated_switcher.dart';
import 'package:glider/widgets/items/stories_body.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final AutoDisposeStateProvider<StoryType> navigationItemStateProvider =
    StateProvider.autoDispose<StoryType>(
        (ProviderReference ref) => StoryType.topStories);

class StoriesPage extends HookWidget {
  const StoriesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useMemoized(() => UniLinksHandler.init(context));
    useEffect(
      () => UniLinksHandler.dispose,
      <Object>[UniLinksHandler.uriSubscription],
    );

    final ValueNotifier<bool> speedDialVisibleState = useState(true);
    final ScrollController scrollController = useScrollController();
    useEffect(
      () {
        void onScrollForwardListener() => speedDialVisibleState.value =
            scrollController.position.userScrollDirection ==
                ScrollDirection.forward;
        scrollController.addListener(onScrollForwardListener);
        return () => scrollController.removeListener(onScrollForwardListener);
      },
      <Object>[scrollController],
    );

    final StateController<StoryType> storyTypeStateController =
        useProvider(navigationItemStateProvider);

    final AsyncValue<Iterable<int>> favoritesValue =
        useProvider(favoriteIdsProvider);
    Widget favoritesIcon() => IconButton(
          icon: const Icon(FluentIcons.star_line_horizontal_3_24_filled),
          tooltip: 'Favorites',
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => const FavoritesPage(),
            ),
          ),
        );

    final AsyncValue<bool> loggedInValue = useProvider(loggedInProvider);
    Widget accountIcon({bool loggedIn = false}) => IconButton(
          key: ValueKey<bool>(loggedIn),
          icon: Icon(loggedIn
              ? FluentIcons.person_available_24_filled
              : FluentIcons.person_24_filled),
          tooltip: 'Account',
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => const AccountPage(),
            ),
          ),
        );

    return Scaffold(
      body: NestedScrollView(
        controller: scrollController,
        floatHeaderSlivers: true,
        headerSliverBuilder: (_, bool innerBoxIsScrolled) => <Widget>[
          SliverAppBar(
            leading: AppBarUtil.buildFluentIconsLeading(context),
            title: const Text('Glider'),
            actions: <Widget>[
              favoritesValue.maybeWhen(
                data: (Iterable<int> favorites) => SmoothAnimatedSwitcher(
                  transitionBuilder:
                      SmoothAnimatedSwitcher.fadeTransitionBuilder,
                  condition: favorites.isNotEmpty,
                  trueChild: favoritesIcon(),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              loggedInValue.maybeWhen(
                data: (bool loggedIn) => SmoothAnimatedSwitcher(
                  transitionBuilder:
                      SmoothAnimatedSwitcher.fadeTransitionBuilder,
                  condition: loggedIn,
                  trueChild: accountIcon(loggedIn: true),
                  falseChild: accountIcon(),
                ),
                orElse: accountIcon,
              ),
            ],
            forceElevated: innerBoxIsScrolled,
            floating: true,
          ),
        ],
        body: const StoriesBody(),
      ),
      floatingActionButton: SpeedDial(
        children: <SpeedDialChild>[
          for (StoryType storyType in StoryType.values)
            SpeedDialChild(
              label: storyType.title,
              child: Icon(storyType.icon),
              onTap: () => storyTypeStateController.state = storyType,
            ),
        ],
        visible: speedDialVisibleState.value,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        animationSpeed: 100,
        child: Icon(storyTypeStateController.state.icon),
      ),
    );
  }
}
