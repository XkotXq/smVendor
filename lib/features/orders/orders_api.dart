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
    required this.ruleNote,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    itemNo: json['itemNo'] as String,
    itemName: json['itemName'] as String? ?? '',
    quantity: json['quantity'] as String? ?? '0',
    unit: json['unit'] as String? ?? '',
    issuedQuantity: json['issuedQuantity'] as String? ?? '0',
    ruleNote: json['ruleNote'] as String? ?? '',
  );

  final String itemNo;
  final String itemName;
  final String quantity;
  final String unit;
  final String issuedQuantity;

  /// The standing instruction for this material on the destination line -
  /// "Wytyczne do transportów", resolved server-side (see wpsApi's
  /// order_items_progress). Empty for the ordinary case.
  final String ruleNote;

  bool get isFulfilled => (double.tryParse(issuedQuantity) ?? 0) >= (double.tryParse(quantity) ?? 0);
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
    required this.problemResolvedBy,
    required this.problemResolvedAt,
    required this.note,
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
    problemResolvedBy: json['problemResolvedBy'] as String?,
    problemResolvedAt: json['problemResolvedAt'] != null ? DateTime.tryParse(json['problemResolvedAt'] as String) : null,
    note: json['note'] as String? ?? '-',
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

  /// Who resolved the last problem, and when - what the operator is shown
  /// as "you can carry on" after being blocked.
  final String? problemResolvedBy;
  final DateTime? problemResolvedAt;
  final String note;
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

/// GET /orders (list + one), take/deliver actions (see wpsapi's
/// routes/orders.js) - client-side, same direct-to-wpsapi pattern as
/// auth_api.dart, using the shared bearer token (authedDioProvider) every
/// route but /auth/login needs.
class OrdersApi {
  OrdersApi(this._dio);
  final Dio _dio;

  Future<List<TransportOrder>> list(String scope) async {
    final res = await _dio.get<List<dynamic>>('/orders', queryParameters: {'scope': scope});
    return (res.data ?? []).map((e) => TransportOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TransportOrder> get(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/orders/$id');
    return TransportOrder.fromJson(res.data!);
  }

  /// "Rozpocznij realizację" - new -> in_progress (see wpsapi's takeOrder).
  Future<TransportOrder> take(String id, String takenBy) async {
    final res = await _dio.post<Map<String, dynamic>>('/orders/$id/take', data: {'takenBy': takenBy});
    return TransportOrder.fromJson(res.data!);
  }

  /// "Dostarczone" - in_progress -> delivered, refused server-side unless
  /// every item is actually fully issued (see wpsapi's deliverOrder) even
  /// if this client's own checklist happens to already agree.
  Future<TransportOrder> deliver(String id, String deliveredBy) async {
    final res = await _dio.post<Map<String, dynamic>>('/orders/$id/deliver', data: {'deliveredBy': deliveredBy});
    return TransportOrder.fromJson(res.data!);
  }

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
