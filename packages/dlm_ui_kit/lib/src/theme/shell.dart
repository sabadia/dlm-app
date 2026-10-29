import 'token_value.dart';

/// How the window's title bar is built.
enum DlmTitleBarStyle {
  /// macOS: transparent title bar, content extends under it, traffic lights.
  unifiedTransparent,

  /// Windows: Flutter-drawn title bar with caption buttons and snap layouts.
  customCaption,

  /// GNOME: client-side header bar that is the title bar.
  headerBar,

  /// KDE: the window manager draws the title bar.
  system,
}

/// How the sidebar is presented.
enum DlmSidebarStyle {
  /// macOS: translucent sidebar with the glass/vibrancy material.
  translucentSource,

  /// Windows: NavigationView pane.
  navigationPane,

  /// GNOME: split-view sidebar with its own header bar.
  splitView,

  /// KDE: flat list pane beside the content.
  listPane,
}

/// Where the toolbar sits and what it looks like.
enum DlmToolbarStyle {
  /// macOS: unified with the title bar.
  unified,

  /// Windows: CommandBar above the content.
  commandBar,

  /// GNOME: actions live in the header bar.
  headerBarActions,

  /// KDE: tool bar below the title bar.
  toolBar,
}

/// How settings pages are laid out.
enum DlmSettingsStyle {
  /// macOS: inset grouped forms.
  insetGroups,

  /// Windows: settings cards in a navigation page.
  settingsCards,

  /// GNOME: preferences groups made of rows.
  preferencesRows,

  /// KDE: System Settings pages with a sidebar of categories.
  systemSettingsPages,
}

/// How transient messages are shown.
enum DlmFeedbackStyle {
  /// macOS: floating banner at the top right.
  floatingBanner,

  /// Windows: InfoBar inline plus teaching tips.
  infoBar,

  /// GNOME: toast overlay at the bottom of the content.
  toastOverlay,

  /// KDE: inline message boxes and passive notifications.
  inlineMessage,
}

/// The arrangement of the window: how sidebar, toolbar, content and inspector
/// are laid out and what the window chrome looks like. The information
/// architecture is identical on every OS; this is presentation only.
class DlmShellPattern extends DlmTokenValue {
  /// Creates a [DlmShellPattern].
  const DlmShellPattern({
    required this.titleBar,
    required this.sidebar,
    required this.toolbar,
    required this.settings,
    required this.feedback,
    required this.inspectorOnTrailingEdge,
    required this.contentUnderTitleBar,
  });

  /// Title bar.
  final DlmTitleBarStyle titleBar;

  /// Sidebar.
  final DlmSidebarStyle sidebar;

  /// Toolbar.
  final DlmToolbarStyle toolbar;

  /// Settings.
  final DlmSettingsStyle settings;

  /// Feedback.
  final DlmFeedbackStyle feedback;

  /// The inspector pane opens on the trailing edge (all skins today).
  final bool inspectorOnTrailingEdge;

  /// Content scrolls under a translucent title bar / toolbar.
  final bool contentUnderTitleBar;

  @override
  List<Object?> get props => [
    titleBar,
    sidebar,
    toolbar,
    settings,
    feedback,
    inspectorOnTrailingEdge,
    contentUnderTitleBar,
  ];
}
