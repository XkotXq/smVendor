import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';

/// One line of a transport order, with how much of it has been issued so
/// far - see wpsapi's schema.sql `order_items_progress` view and
/// orders.js's own orderRowToApi. `issuedQuantity >= quantity` is "done" -
/// left for the caller to compare (see [isFulfilled]) rather than a
/// boolean from the server, same as smpda's own OrderItem.
class OrderItem {
  const OrderItem({
    required this.itemNo,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.issuedQuantity,
    this.issueCount = 0,
    required this.ruleNote,
    this.category = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    itemNo: json['itemNo'] as String,
    itemName: json['itemName'] as String? ?? '',
    quantity: json['quantity'] as String? ?? '0',
    unit: json['unit'] as String? ?? '',
    issuedQuantity: json['issuedQuantity'] as String? ?? '0',
    issueCount: (json['issueCount'] as num?)?.toInt() ?? 0,
    ruleNote: json['ruleNote'] as String? ?? '',
    category: json['category'] as String? ?? '',
  );

  final String itemNo;
  final String itemName;
  final String quantity;
  final String unit;
  final String issuedQuantity;

  /// How many times something was issued against this line (wpsApi's
  /// issue_count) - the signal for "done", because [quantity] is a piece
  /// count while [issuedQuantity] is the catalog's own amount in its own
  /// unit, so comparing the two compared pieces with kilograms.
  final int issueCount;

  /// The standing instruction for this material on the destination line -
  /// "Wytyczne do transportów", resolved server-side (see wpsApi's
  /// order_items_progress). Empty for the ordinary case.
  final String ruleNote;

  /// The catalog's own category for this material ('FRP', 'Drum',
  /// 'GLYCL', ...), resolved server-side in order_items_progress and sent
  /// with every line. What tells this app an order involves FRP, which has
  /// its own live stock list worth opening next to the order.
  final String category;

  bool get isFrp => category.toUpperCase() == 'FRP';

  bool get isFulfilled => issueCount > 0;
}

/// One transport order - shapes wpsApi's own orders/order_items (see
/// wpsapi's schema.sql + AGENTS.md "Transport orders"), the same JSON shape
/// wps's OrdersCipListTable.js already consumes via lib/ordersApi.js.
class TransportOrder {
  const TransportOrder({
    required this.id,
    required this.orderNo,
    required this.type,
    required this.status,
    required this.from,
    required this.to,
    required this.employeeNo,
    required this.fulfilledBy,
    required this.takenBy,
    required this.deliveredBy,
    required this.createdAt,
    required this.lineRuleNote,
    required this.completedAt,
    required this.cancelledAt,
    required this.problemNote,
    required this.problemReportedFrom,
    this.messageCount = 0,
    this.editing = false,
    this.unreadCount = 0,
    this.deliverableInSeconds,
    required this.problemResolvedBy,
    required this.problemResolvedAt,
    required this.note,
    this.priority = 'normal',
    required this.details,
    required this.items,
  });

  factory TransportOrder.fromJson(Map<String, dynamic> json) => TransportOrder(
    id: json['id'] as String,
    orderNo: json['orderNo'] as String? ?? '',
    type: json['type'] as String? ?? '',
    // "new" | "inProgress" | "delivered" | "done" | "cancelled" - see
    // wpsapi's orders.js STATUS_TO_API.
    status: json['status'] as String? ?? 'new',
    from: json['from'] as String?,
    to: json['to'] as String?,
    employeeNo: json['employeeNo'] as String? ?? '',
    fulfilledBy: json['fulfilledBy'] as String? ?? '-',
    takenBy: json['takenBy'] as String?,
    deliveredBy: json['deliveredBy'] as String?,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    lineRuleNote: json['lineRuleNote'] as String? ?? '',
    completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'] as String) : null,
    cancelledAt: json['cancelledAt'] != null ? DateTime.tryParse(json['cancelledAt'] as String) : null,
    problemNote: json['problemNote'] as String? ?? '',
    // "inProgress" = this operator reported it and the requester answers;
    // "delivered" = the requester rejected the delivery and **this operator
    // answers**. "" when no problem is open. See wpsApi's
    // problem_reported_from.
    problemReportedFrom: json['problemReportedFrom'] as String? ?? '',
    messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
    editing: json['editing'] as bool? ?? false,
    unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    deliverableInSeconds: (json['deliverableInSeconds'] as num?)?.toInt(),
    problemResolvedBy: json['problemResolvedBy'] as String?,
    problemResolvedAt: json['problemResolvedAt'] != null ? DateTime.tryParse(json['problemResolvedAt'] as String) : null,
    note: json['note'] as String? ?? '-',
    priority: json['priority'] as String? ?? 'normal',
    details: (json['details'] as Map?)?.cast<String, dynamic>() ?? const {},
    items: (json['items'] as List? ?? const []).map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList(),
  );

  final String id;
  final String orderNo;
  final String type;
  final String status;
  final String? from;
  final String? to;
  final String employeeNo;
  final String fulfilledBy;
  /// The forklift operator who took it - whose order this is, which the
  /// list card uses to say "already yours" rather than naming someone else.
  final String? takenBy;

  final String? deliveredBy;
  final DateTime createdAt;

  /// The standing instruction for the destination line itself, whatever is
  /// being brought - a guideline saved with no material (see wpsApi). Empty
  /// when the line has none.
  final String lineRuleNote;

  /// When the order was closed, either way - null while it is still open.
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  /// What is blocking this order right now (status 'problem') - empty once
  /// the requester has resolved it. Every episode, resolved ones included,
  /// is in GET /orders/:id/events.
  final String problemNote;

  /// Which status the open problem was reported from, and so **whose turn
  /// it is to answer it** - see [awaitingMyAnswer]. Empty when nothing is
  /// pending.
  final String problemReportedFrom;

  /// How many chat messages this order has - what the "Czat" button shows,
  /// so there is no need to open a thread to find out it is empty.
  final int messageCount;

  /// The person who placed it has it open for editing right now, so it is
  /// kept out of this queue and cannot be taken (wpsApi refuses that too) -
  /// nobody should start hauling a transport whose contents are being
  /// rewritten. Clears by itself if their app dies mid-edit: the lock
  /// expires server-side.
  final bool editing;

  /// How many of them are new for the person looking - 0 unless the request
  /// named a viewer. This, not [messageCount], is what a badge should show.
  final int unreadCount;

  /// Seconds this transport still has to run before it can be marked
  /// delivered, straight from the server (null = no wait applies; see
  /// wpsApi's deliverableInSeconds). Only "Transport półproduktów" has one:
  /// it has nothing to issue and a real distance to cover, so without it the
  /// order is takeable and deliverable in the same second. **Measured on the
  /// server clock on purpose** - the screen ticks it down locally between
  /// polls and re-syncs on each one.
  final int? deliverableInSeconds;

  /// Who resolved the last problem, and when - what the operator is shown
  /// as "you can carry on" after being blocked.
  final String? problemResolvedBy;
  final DateTime? problemResolvedAt;
  final String note;

  /// How urgent the requester said it is: 'normal', 'urgent' or 'critical'
  /// (wpsApi's PRIORITIES, least to most). Read-only here - it is set in
  /// smOrder - and shown as the coloured three-bar icon on the card.
  final String priority;
  final Map<String, dynamic> details;
  final List<OrderItem> items;

  String? get productionOrderNo => details['productionOrderNo'] as String?;

  /// When this order stopped being work: completed, or cancelled, whichever
  /// happened. Falls back to [createdAt] so a row always has a day to be
  /// grouped under on the history screen - an order in `history` scope
  /// always has one of the two in practice (the status triggers fill them),
  /// so the fallback is insurance, not a case to design around.
  DateTime get closedAt => completedAt ?? cancelledAt ?? createdAt;

  /// Whether this order can be handed over now - which is what decides
  /// whether "Dostarczone" is offered (see OrderDetailPage).
  ///
  /// An order **with** items needs every one of them issued first
  /// (re-checked server-side too, see wpsApi's deliverOrder). An order
  /// **without** items - water_refill, goods_transport, waste_removal,
  /// warehouse_return - has nothing to issue, so it is deliverable as soon
  /// as it is taken. That is deliberate: every type goes through the same
  /// delivered -> the requester confirms or reports a problem path, rather
  /// than the four item-less types being closeable only from wps.
  bool get canDeliver => items.isEmpty || items.every((i) => i.isFulfilled);

  /// There is an open problem, whichever side reported it.
  bool get hasOpenProblem => status == 'problem';

  /// The open problem is **this operator's to answer**: the requester
  /// rejected what was delivered, so the operator puts it right, marks it
  /// corrected, and delivers again. A problem the operator reported
  /// themselves waits on the requester instead.
  bool get awaitingMyAnswer => hasOpenProblem && problemReportedFrom == 'delivered';


  /// "skąd → dokąd" when both are set, else the one place this order
  /// concerns - same fallback as wps's own routeLabel() in
  /// OrdersCipListTable.js.
  String route() {
    if (from != null && to != null) return '$from → $to';
    return to ?? from ?? '-';
  }
}

/// A refusal from wpsApi, with the Polish message it sent - e.g.
/// "Zamówienie przyjął już 4601270." when two operators pressed
/// "Rozpocznij realizację" at the same moment, which the server settles by
/// letting exactly one of them win.
///
/// Worth showing verbatim, unlike a dropped connection: it says what
/// happened and what the order's state now is. Anything that is not a
/// refusal (no connection, a 500) is left as the original DioException.
/// One chat message on an order - see wpsApi's order_messages.
class OrderMessage {
  const OrderMessage({required this.id, required this.author, required this.body, required this.at});

  factory OrderMessage.fromJson(Map<String, dynamic> json) => OrderMessage(
    id: json['id'] as String,
    author: json['author'] as String? ?? '',
    body: json['body'] as String? ?? '',
    at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
  );

  final String id;

  /// The employee number that wrote it - asserted by the client that sent
  /// it, like taken_by/delivered_by everywhere else in this API.
  final String author;
  final String body;
  final DateTime at;
}

class OrderActionFailure implements Exception {
  const OrderActionFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// GET /orders (list + one), take/deliver actions (see wpsapi's
/// routes/orders.js) - client-side, same direct-to-wpsapi pattern as
/// auth_api.dart, using the shared bearer token (authedDioProvider) every
/// route but /auth/login needs.
class OrdersApi {
  OrdersApi(this._dio);
  final Dio _dio;

  /// One page when [limit] is given, the whole list otherwise.
  ///
  /// [before] is the last order already held: the server returns only what
  /// is **older than that exact row**, not "skip N" - orders close while
  /// somebody is scrolling, and an offset would then repeat or skip a row at
  /// every page boundary (see wpsApi's listOrders).
  /// [viewer] is the logged-in employee number: the server counts each
  /// order's unread messages **for that person** and sends it as
  /// `unreadCount` (see wpsApi's unreadCountsByOrderIds). Without it every
  /// unread count comes back 0 - there is no per-user auth, so the caller
  /// has to say who is asking.
  Future<List<TransportOrder>> list(String scope, {int? limit, TransportOrder? before, String? viewer}) async {
    final res = await _dio.get<List<dynamic>>(
      '/orders',
      queryParameters: {
        'scope': scope,
        'limit': ?limit,
        'beforeCreatedAt': ?before?.createdAt.toUtc().toIso8601String(),
        'beforeId': ?before?.id,
        'viewer': ?viewer,
      },
    );
    return (res.data ?? []).map((e) => TransportOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TransportOrder> get(String id, {String? viewer}) async {
    final res = await _dio.get<Map<String, dynamic>>('/orders/$id', queryParameters: {'viewer': ?viewer});
    return TransportOrder.fromJson(res.data!);
  }

  /// "Rozpocznij realizację" - new -> in_progress (see wpsapi's takeOrder).
  Future<TransportOrder> take(String id, String takenBy) => _act(() async {
    final res = await _dio.post<Map<String, dynamic>>('/orders/$id/take', data: {'takenBy': takenBy});
    return TransportOrder.fromJson(res.data!);
  });

/// The chat on one order, oldest first. With [afterId] it returns **only
  /// what is newer**, which is what the chat screen polls with every second
  /// - the answer is an empty list almost every time (see OrderChatPage).
  Future<List<OrderMessage>> messages(String orderId, {String? afterId}) async {
    final res = await _dio.get<List<dynamic>>(
      '/orders/$orderId/messages',
      queryParameters: {'afterId': ?afterId},
    );
    return (res.data ?? []).map((e) => OrderMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// "I have read up to here" - sent by the chat screen as it shows
  /// messages, which is what makes [TransportOrder.unreadCount] mean
  /// anything. Fire-and-forget: failing to record it only leaves a badge up
  /// a moment longer, so it must never interrupt reading.
  Future<void> markRead(String orderId, {required String employeeNo, required String lastReadId}) async {
    await _dio.post<Map<String, dynamic>>(
      '/orders/$orderId/messages/read',
      data: {'employeeNo': employeeNo, 'lastReadId': lastReadId},
    );
  }

  Future<OrderMessage> sendMessage(String orderId, {required String author, required String body}) => _act(() async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/orders/$orderId/messages',
      data: {'author': author, 'body': body},
    );
    return OrderMessage.fromJson(res.data!);
  });

  /// Unwraps wpsApi's own `{ "error": "..." }` into an [OrderActionFailure],
  /// so every action below can be written once and still report a refusal
  /// in the words the server chose.
  Future<T> _act<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['error'] as String? : null;
      if (message != null && message.isNotEmpty) throw OrderActionFailure(message);
      rethrow;
    }
  }

  /// "Dostarczone" - in_progress -> delivered, refused server-side unless
  /// every item is actually fully issued (see wpsapi's deliverOrder) even
  /// if this client's own checklist happens to already agree.
  Future<TransportOrder> deliver(String id, String deliveredBy) => _act(() async {
    final res = await _dio.post<Map<String, dynamic>>('/orders/$id/deliver', data: {'deliveredBy': deliveredBy});
    return TransportOrder.fromJson(res.data!);
  });

  /// "Zgłoś problem" - in_progress -> **problem** (see wpsApi's
  /// reportOrderProblem). The order is deliberately *not* cancelled: it
  /// stays open and waits for the requester to deal with whatever is wrong
  /// and mark it resolved, which puts it back to in_progress and lets the
  /// operator either deliver it or report again. It can loop, and every
  /// episode is kept in GET /orders/:id/events.
  ///
  /// A description is required - server-side too - because a problem
  /// nobody can read is not a report, and the requester is being asked to
  /// act on it.
  Future<TransportOrder> reportProblem(String id, {required String reportedBy, required String note}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/orders/$id/problem',
      data: {'reportedBy': reportedBy, 'note': note},
    );
    return TransportOrder.fromJson(res.data!);
  }

  /// "Problem rozwiązany" - the operator's answer to a delivery the
  /// requester rejected (`problem -> in_progress`, see wpsApi's
  /// resolveOrderProblem). The rejection un-delivered the order, so this
  /// puts the work back where it was and "Dostarczone" has to be pressed
  /// again - which is the point: the handover happens properly the second
  /// time.
  Future<TransportOrder> resolveProblem(String id, {required String resolvedBy, String note = ''}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/orders/$id/problem/resolve',
      data: {'resolvedBy': resolvedBy, 'note': note},
    );
    return TransportOrder.fromJson(res.data!);
  }
}

final ordersApiProvider = Provider<OrdersApi>((ref) => OrdersApi(ref.watch(authedDioProvider)));
