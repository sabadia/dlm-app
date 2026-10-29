import 'dart:async';
import 'dart:io' show Platform;

import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'appearance.dart';
import 'connection/connection_gate.dart';
import 'manage/manage_screen.dart';
import 'platform/integration_binder.dart';
import 'prefs/pref_providers.dart';
import 'routing/app_routes.dart';
import 'screens/downloads_screen.dart';
import 'screens/queue_screen.dart';
import 'settings/settings_screen.dart';
import 'shell/app_shell.dart';
import 'skin_registry.dart';

/// The reader of the system accent and accessibility options.
final systemAppearanceProvider = Provider<SystemAppearanceReader>(
  (ref) => const UnsupportedSystemAppearance(),
);

/// Whether the window currently shows a backdrop effect. Translucent
/// materials fall back to opaque until it does.
final windowEffectActiveProvider = Provider<ValueNotifier<bool>>((ref) {
  final notifier = ValueNotifier<bool>(false);
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// What the platform says about brightness, accent and accessibility, gated by
/// whether the window can draw translucent materials.
final appearanceSourceProvider = Provider<AppearanceSource>((ref) {
  final source = _EffectGatedSource(
    PlatformAppearanceSource(
      flutter: FlutterAppearanceSource(),
      system: ref.watch(systemAppearanceProvider),
    ),
    ref.watch(windowEffectActiveProvider),
  );
  ref.onDispose(source.dispose);
  return source;
});

/// The skin in use: the user's override or the platform's.
final skinProvider = Provider<DlmSkin>(
  (ref) => pickSkin(
    ref.watch(skinOverrideProvider),
    defaultTargetPlatform,
    desktops: (Platform.environment['XDG_CURRENT_DESKTOP'] ?? '').split(':'),
  ),
);

/// The router: one shell around the downloads and queue pages.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: homePath,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri, child: child),
        routes: [
          GoRoute(
            path: '/downloads/:filter',
            redirect: (context, state) =>
                DownloadsFilter.fromSegment(state.pathParameters['filter']) ==
                    null
                ? homePath
                : null,
            pageBuilder: (context, state) => NoTransitionPage(
              key: ValueKey(state.uri.path),
              child: DownloadsScreen(
                filter: DownloadsFilter.fromSegment(
                  state.pathParameters['filter'],
                )!,
              ),
            ),
          ),
          GoRoute(
            path: '/manage/:page',
            redirect: (context, state) =>
                managePages.contains(state.pathParameters['page'])
                ? null
                : homePath,
            pageBuilder: (context, state) => NoTransitionPage(
              key: ValueKey(state.uri.path),
              child: ManageScreen(page: state.pathParameters['page']!),
            ),
          ),
          GoRoute(
            path: '/settings/:group',
            pageBuilder: (context, state) => NoTransitionPage(
              key: ValueKey(state.uri.path),
              child: SettingsScreen(group: state.pathParameters['group']!),
            ),
          ),
          GoRoute(
            path: '/categories/:id',
            pageBuilder: (context, state) => NoTransitionPage(
              key: ValueKey(state.uri.path),
              child: DownloadsScreen(
                filter: DownloadsFilter.all,
                categoryId: state.pathParameters['id'],
              ),
            ),
          ),
          GoRoute(
            path: '/queues/:id',
            pageBuilder: (context, state) => NoTransitionPage(
              key: ValueKey(state.uri.path),
              child: QueueScreen(queueId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),
    ],
    redirect: (context, state) => state.uri.path == '/' ? homePath : null,
  );
  ref.onDispose(router.dispose);
  return router;
});

/// The root widget: router, localisation, skin and theme, connection gate.
class DlmApp extends ConsumerWidget {
  /// Creates the app.
  const DlmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentProvider);
    return WidgetsApp.router(
      routerConfig: ref.watch(routerProvider),
      color: const Color(0xFF000000),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context).app_name,
      builder: (context, child) => DlmThemeScope(
        skin: ref.watch(skinProvider),
        source: ref.watch(appearanceSourceProvider),
        userOverride: appearanceOverrideFor(
          theme: ref.watch(themeChoiceProvider),
          density: ref.watch(densityProvider),
          accent: accent == null ? null : Color(accent),
        ),
        child: _WindowChromeBinder(
          child: IntegrationBinder(child: ConnectionGate(child: child!)),
        ),
      ),
    );
  }
}

/// Applies the skin's window chrome (transparent title bar, glass or vibrancy
/// backdrop) once the window exists and whenever the look changes, and tells
/// the appearance source whether a backdrop is in force.
class _WindowChromeBinder extends ConsumerStatefulWidget {
  const _WindowChromeBinder({required this.child});

  final Widget child;

  @override
  ConsumerState<_WindowChromeBinder> createState() =>
      _WindowChromeBinderState();
}

class _WindowChromeBinderState extends ConsumerState<_WindowChromeBinder> {
  DlmThemeData? _applied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _apply());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = DlmTheme.of(context);
    final before = _applied;
    if (before != null &&
        (before.brightness != theme.brightness ||
            before.skinId != theme.skinId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _apply());
    }
  }

  Future<void> _apply() async {
    if (!mounted) return;
    final theme = DlmTheme.of(context);
    _applied = theme;
    final translucent =
        theme.materials.all.any((m) => m.isTranslucent) ||
        theme.skinId == 'macos';
    try {
      final result = await ref
          .read(windowChromeProvider)
          .apply(
            WindowChromeConfig(
              transparentTitleBar:
                  theme.shell.titleBar == DlmTitleBarStyle.unifiedTransparent,
              effect: translucent ? WindowEffect.glass : WindowEffect.none,
              brightness: theme.brightness,
            ),
          );
      if (!mounted) return;
      ref.read(windowEffectActiveProvider).value =
          result.effect != WindowEffect.none;
    } on WindowChromeException {
      // The window was not ready; materials stay opaque.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Adds "reduce transparency" to the platform appearance until the window
/// confirms it can draw a backdrop.
class _EffectGatedSource implements AppearanceSource {
  _EffectGatedSource(this._inner, this._effect) {
    _sub = _inner.changes.listen((_) => _emit());
    _effect.addListener(_emit);
  }

  final AppearanceSource _inner;
  final ValueNotifier<bool> _effect;
  final ManualAppearanceSource _out = ManualAppearanceSource();
  late final StreamSubscription<DlmAppearance> _sub;

  DlmAppearance _gated() => _inner.current.copyWith(
    reduceTransparency: _inner.current.reduceTransparency || !_effect.value,
  );

  void _emit() => _out.update(_gated());

  @override
  DlmAppearance get current => _gated();

  @override
  Stream<DlmAppearance> get changes => _out.changes;

  @override
  void dispose() {
    _effect.removeListener(_emit);
    unawaited(_sub.cancel());
    _out.dispose();
    _inner.dispose();
  }
}
