import 'package:dlm_api/dlm_api.dart';

/// The events a webhook can subscribe to, as the daemon names them.
const List<String> webhookEvents = [
  'task.created',
  'task.updated',
  'task.status',
  'task.deleted',
  'task.refresh',
  'queue.created',
  'queue.updated',
  'queue.deleted',
  'queue.completed',
  'queue.action_cancelled',
  'settings.updated',
  'quota.exhausted',
  'quota.reset',
];

/// A webhook being added or edited, as typed.
class WebhookDraft {
  /// Creates a draft; [from] fills it from an existing webhook (its secret is
  /// never known to the app).
  WebhookDraft({Webhook? from})
    : url = from?.url ?? '',
      events = {...?from?.events},
      enabled = from?.enabled ?? true,
      hadSecret = from?.hasSecret ?? false,
      isNew = from == null;

  /// Whether this webhook does not exist yet.
  final bool isNew;

  /// Whether the stored webhook has a secret (so it can be removed).
  final bool hadSecret;

  /// The address deliveries are posted to.
  String url;

  /// The subscribed events; empty means every event.
  final Set<String> events;

  /// Whether deliveries are sent.
  bool enabled;

  /// A new secret that signs the deliveries; empty keeps the stored one.
  String secret = '';

  /// Whether to remove the stored secret (deliveries are then unsigned).
  bool removeSecret = false;

  /// Whether [url] is an http or https address.
  bool get urlValid {
    final uri = Uri.tryParse(url.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  /// Whether the draft can be saved.
  bool get valid => urlValid;

  /// The events in the order the daemon lists them.
  List<String> get orderedEvents => [
    for (final e in webhookEvents)
      if (events.contains(e)) e,
  ];

  /// The body of a new webhook.
  CreateWebhookBody toCreate() => CreateWebhookBody(
    url: url.trim(),
    events: orderedEvents,
    secret: secret.isEmpty ? null : secret,
    disabled: enabled ? null : true,
  );

  /// The body that turns [old] into the draft; only what changed is sent. An
  /// empty `secret` removes the stored one.
  UpdateWebhookBody toUpdate(Webhook old) => UpdateWebhookBody(
    url: url.trim() == old.url ? null : url.trim(),
    events: _sameEvents(old) ? null : orderedEvents,
    enabled: enabled == old.enabled ? null : enabled,
    secret: removeSecret
        ? ''
        : secret.isEmpty
        ? null
        : secret,
  );

  bool _sameEvents(Webhook old) {
    final before = {...?old.events};
    return before.length == events.length && before.containsAll(events);
  }
}
