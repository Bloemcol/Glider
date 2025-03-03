import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:glider/app/bootstrap/app_bloc_observer.dart';
import 'package:glider/app/container/app_container.dart';
import 'package:glider/app/router/app_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> bootstrap(
  FutureOr<Widget> Function(AppContainer, AppRouter) builder,
) async {
  await runZonedGuarded(
    () async {
      FlutterError.onError = (details) =>
          log(details.exceptionAsString(), stackTrace: details.stack);

      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
        ),
      );
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      if (Platform.isAndroid) await FlutterDisplayMode.setHighRefreshRate();

      Bloc.observer = const AppBlocObserver();
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getApplicationCacheDirectory(),
      );

      final appContainer = await AppContainer.create();
      unawaited(appContainer.authCubit.init());
      final appRouter = AppRouter.create(appContainer);

      runApp(await builder(appContainer, appRouter));
    },
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
