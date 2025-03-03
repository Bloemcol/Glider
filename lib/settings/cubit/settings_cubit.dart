import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:glider/common/extensions/bloc_base_extension.dart';
import 'package:glider_domain/glider_domain.dart';
import 'package:material_color_utilities/scheme/variant.dart';
import 'package:share_plus/share_plus.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
    this._settingsRepository,
    this._packageRepository,
    this._itemInteractionRepository,
  ) : super(const SettingsState()) {
    unawaited(_load());
  }

  final SettingsRepository _settingsRepository;
  final PackageRepository _packageRepository;
  final ItemInteractionRepository _itemInteractionRepository;

  Future<void> _load() async {
    final useLargeStoryStyle =
        await _settingsRepository.getUseLargeStoryStyle();
    final showStoryMetadata = await _settingsRepository.getShowStoryMetadata();
    final useDynamicTheme = await _settingsRepository.getUseDynamicTheme();
    final themeColor = await _settingsRepository.getThemeColor();
    final themeVariant = await _settingsRepository.getThemeVariant();
    final usePureBackground = await _settingsRepository.getUsePureBackground();
    final useThreadNavigation =
        await _settingsRepository.getUseThreadNavigation();
    safeEmit(
      state.copyWith(
        useLargeStoryStyle:
            useLargeStoryStyle != null ? () => useLargeStoryStyle : null,
        showStoryMetadata:
            showStoryMetadata != null ? () => showStoryMetadata : null,
        useDynamicTheme: useDynamicTheme != null ? () => useDynamicTheme : null,
        themeColor: themeColor != null ? () => themeColor : null,
        themeVariant: themeVariant != null ? () => themeVariant : null,
        usePureBackground:
            usePureBackground != null ? () => usePureBackground : null,
        useThreadNavigation:
            useThreadNavigation != null ? () => useThreadNavigation : null,
        appVersion: _packageRepository.getVersion,
      ),
    );
  }

  Future<void> setUseLargeStoryStyle(bool value) async {
    await _settingsRepository.setUseLargeStoryStyle(value: value);
    final useLargeStoryStyle =
        await _settingsRepository.getUseLargeStoryStyle();

    if (useLargeStoryStyle != null) {
      safeEmit(
        state.copyWith(useLargeStoryStyle: () => useLargeStoryStyle),
      );
    }
  }

  Future<void> setShowStoryMetadata(bool value) async {
    await _settingsRepository.setShowStoryMetadata(value: value);
    final showStoryMetadata = await _settingsRepository.getShowStoryMetadata();

    if (showStoryMetadata != null) {
      safeEmit(
        state.copyWith(showStoryMetadata: () => showStoryMetadata),
      );
    }
  }

  Future<void> setUseDynamicTheme(bool value) async {
    await _settingsRepository.setUseDynamicTheme(value: value);
    final useDynamicTheme = await _settingsRepository.getUseDynamicTheme();

    if (useDynamicTheme != null) {
      safeEmit(
        state.copyWith(useDynamicTheme: () => useDynamicTheme),
      );
    }
  }

  Future<void> setThemeColor(Color value) async {
    await _settingsRepository.setThemeColor(value: value);
    final themeColor = await _settingsRepository.getThemeColor();

    if (themeColor != null) {
      safeEmit(
        state.copyWith(themeColor: () => themeColor),
      );
    }
  }

  Future<void> setThemeVariant(Variant value) async {
    await _settingsRepository.setThemeVariant(value: value);
    final themeVariant = await _settingsRepository.getThemeVariant();

    if (themeVariant != null) {
      safeEmit(
        state.copyWith(themeVariant: () => themeVariant),
      );
    }
  }

  Future<void> setUsePureBackground(bool value) async {
    await _settingsRepository.setUsePureBackground(value: value);
    final usePureBackground = await _settingsRepository.getUsePureBackground();

    if (usePureBackground != null) {
      safeEmit(
        state.copyWith(usePureBackground: () => usePureBackground),
      );
    }
  }

  Future<void> setShowJobs(bool value) async {
    await _settingsRepository.setShowJobs(value: value);
    final showJobs = await _settingsRepository.getShowJobs();

    if (showJobs != null) {
      safeEmit(
        state.copyWith(showJobs: () => showJobs),
      );
    }
  }

  Future<void> setUseThreadNavigation(bool value) async {
    await _settingsRepository.setUseThreadNavigation(value: value);
    final useThreadNavigation =
        await _settingsRepository.getUseThreadNavigation();

    if (useThreadNavigation != null) {
      safeEmit(
        state.copyWith(useThreadNavigation: () => useThreadNavigation),
      );
    }
  }

  Future<void> exportFavorites() async {
    final favorites = await _itemInteractionRepository.favoritedStream.first;
    await Share.share(jsonEncode(favorites));
  }
}
