import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'orders_api.dart';

/// The order list, held **outside** the screens that show it.
///
/// It used to be plain widget state, which meant the list was thrown away
/// and re-fetched from nothing every time the page was left: opening an
/// order and coming back, or switching tabs, blanked the screen to
/// "Wczytywanie..." until the network answered. On warehouse Wi-Fi that is
/// seconds of staring at nothing for data the device already had.
///
/// Providers here are **not** auto-disposed (`isAutoDispose` defaults to
/// false in riverpod 3.x), so the last good list survives the page being
/// unmounted and is on screen the instant it mounts again.
///
/// [refresh] is the only way it updates after the first load: it replaces
/// the data in place, never returning to a loading state and **keeping the
/// previous list when a fetch fails**. That is what makes a bad connection
/// survivable - a failed poll leaves the last known orders visible instead
/// of an error screen. The screens decide *when* to refresh (their own
/// timer, and on returning from an order); this only owns the data.
class OrdersNotifier extends AsyncNotifier<List<TransportOrder>> {
  OrdersNotifier(this.scope);

  /// "active" (new + in_progress + delivered) or "history" (done +
  /// cancelled) - wpsApi's own STATUS_SETS. Passed to the constructor
  /// rather than being a provider family: `AsyncNotifier.build()` takes no
  /// argument in riverpod 3 without codegen, and there are exactly two
  /// scopes, so two providers are plainer than generating a family.
  final String scope;

  @override
  Future<List<TransportOrder>> build() => ref.read(ordersApiProvider).list(scope);

  /// Silent on failure by design - see the class comment. Returns whether
  /// fresh data actually arrived, for a caller that wants to know.
  Future<bool> refresh() async {
    try {
      state = AsyncData(await ref.read(ordersApiProvider).list(scope));
      return true;
    } catch (_) {
      // Deliberately swallowed: whatever is in `state` stays on screen.
      return false;
    }
  }
}

/// The working queue - what OrdersPage shows.
final activeOrdersProvider = AsyncNotifierProvider<OrdersNotifier, List<TransportOrder>>(
  () => OrdersNotifier('active'),
);

/// Finished orders - what HistoryPage shows.
final historyOrdersProvider = AsyncNotifierProvider<OrdersNotifier, List<TransportOrder>>(
  () => OrdersNotifier('history'),
);
