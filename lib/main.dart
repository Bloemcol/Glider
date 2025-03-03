import 'dart:async';

import 'package:glider/app/bootstrap/bootstrap.dart';
import 'package:glider/app/view/app.dart';

Future<void> main() async => bootstrap(
      (appContainer, appRouter) => App(
        appContainer.settingsCubit,
        appRouter.config,
      ),
    );
