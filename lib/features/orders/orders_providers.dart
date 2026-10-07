import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/session/session_providers.dart';
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
  Future<List<TransportOrder>> build() =>
      ref.read(ordersApiProvider).list(scope, viewer: ref.read(sessionProvider)?.userId);

  /// Silent on failure by design - see the class comment. Returns whether
  /// fresh data actually arrived, for a caller that wants to know.
  Future<bool> refresh() async {
    try {
      state = AsyncData(
        await ref.read(ordersApiProvider).list(scope, viewer: ref.read(sessionProvider)?.userId),
      );
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

/// How many finished orders one page holds. Big enough that the first
/// screenful is always full and most days need no second request, small
/// enough that opening "Historia" is one quick call rather than every order
/// this warehouse ever closed.
const historyPageSize = 25;

/// A page of history, plus whether there is more behind it.
///
/// A record of three things rather than a bare list, because the screen has
/// to know all three: what to draw, whether to ask for more when the reader
/// reaches the bottom, and whether a request is already in flight (so a
/// fling at the end does not fire five of them).
class HistoryState {
  const HistoryState({required this.orders, required this.hasMore, required this.loadingMore});

  final List<TransportOrder> orders;
  final bool hasMore;
  final bool loadingMore;

  HistoryState copyWith({List<TransportOrder>? orders, bool? hasMore, bool? loadingMore}) => HistoryState(
    orders: orders ?? this.orders,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
  );
}

/// Finished orders - what HistoryPage shows, loaded a page at a time.
///
/// The cursor is **the last order already held**, not an offset: orders
/// close while somebody is scrolling, and an offset would then repeat or
/// skip a row at every page boundary (see wpsApi's listOrders). A short page
/// that comes back means the end - the server has nothing older.
class HistoryNotifier extends AsyncNotifier<HistoryState> {
  @override
  Future<HistoryState> build() async {
    final page = await ref
        .read(ordersApiProvider)
        .list('history', limit: historyPageSize, viewer: ref.read(sessionProvider)?.userId);
    return HistoryState(orders: page, hasMore: page.length == historyPageSize, loadingMore: false);
  }

  /// Appends the next page. Silent on failure and **keeps what is on
  /// screen**, same reasoning as OrdersNotifier.refresh: a dropped request
  /// on warehouse Wi-Fi must not throw away history the operator is reading.
  /// `hasMore` is left alone on failure, so reaching the bottom again
  /// retries.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore || current.orders.isEmpty) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final page = await ref.read(ordersApiProvider).list(
        'history',
        limit: historyPageSize,
        before: current.orders.last,
        viewer: ref.read(sessionProvider)?.userId,
      );
      final known = current.orders.map((o) => o.id).toSet();
      state = AsyncData(
        HistoryState(
          orders: [...current.orders, ...page.where((o) => !known.contains(o.id))],
          hasMore: page.length == historyPageSize,
          loadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }
}

final historyOrdersProvider = AsyncNotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);
