import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';

/// One drum of FRP as it stands on the floor right now - a row of wpsApi's
/// `frp_current`, the same live table wps lists under "Stock → Aktualna
/// lista" (its own frpCurrentColumns).
///
/// Read-only here. This app never edits stock: a forklift operator opens it
/// to find out which drum to fetch and where it is standing.
class FrpStockRow {
  const FrpStockRow({
    required this.id,
    required this.itemNo,
    required this.name,
    required this.label,
    required this.lengthMeters,
    required this.type,
    required this.drumNumber,
    required this.location,
    required this.remark,
    required this.reserved,
  });

  factory FrpStockRow.fromJson(Map<String, dynamic> json) => FrpStockRow(
    id: json['id'] as String? ?? '',
    itemNo: json['frpItemNumber'] as String? ?? json['itemNumber'] as String? ?? '',
    // The catalog's full name ("2.2mmFRP/suppleness-FRP"), with the short
    // label behind it - the same fallback order wps's own mapFrpItem uses,
    // so a row is never blank.
    name: json['frpName'] as String? ?? '',
    label: json['frpLabel'] as String? ?? '',
    lengthMeters: json['length'] as String? ?? '',
    type: json['type'] as String? ?? '',
    drumNumber: json['drumNumber'] as String? ?? '',
    location: json['location'] as String? ?? '',
    remark: json['remark'] as String? ?? '',
    reserved: json['reservedForOrder'] as bool? ?? false,
  );

  final String id;
  final String itemNo;
  final String name;
  final String label;

  /// As stored: metres, as free text. wps shows kilometres, so this app
  /// does too - see [lengthKmLabel].
  final String lengthMeters;
  final String type;
  final String drumNumber;
  final String location;
  final String remark;

  /// Already spoken for by another order (frp_current.reserved_for_order).
  final bool reserved;

  String get displayName => name.isNotEmpty ? name : (label.isNotEmpty ? label : itemNo);

  /// Metres to kilometres, the way the dashboard shows them. Text that is
  /// not a number is passed through rather than swallowed - it is somebody's
  /// note about a real drum, not a value this app may discard.
  String get lengthKmLabel {
    final meters = double.tryParse(lengthMeters.replaceAll(',', '.'));
    if (meters == null) return lengthMeters;
    final km = meters / 1000;
    final text = km == km.roundToDouble() ? km.round().toString() : km.toStringAsFixed(2);
    return '$text km';
  }
}

class FrpStockApi {
  FrpStockApi(this._dio);
  final Dio _dio;

  /// Everything currently on the floor. The list is small (tens of drums)
  /// and has no paging server-side, so it arrives in one request.
  Future<List<FrpStockRow>> list() async {
    final res = await _dio.get<List<dynamic>>('/frp');
    return (res.data ?? [])
        .whereType<Map>()
        .map((row) => FrpStockRow.fromJson(row.cast<String, dynamic>()))
        .toList();
  }
}

final frpStockApiProvider = Provider<FrpStockApi>((ref) => FrpStockApi(ref.watch(authedDioProvider)));
