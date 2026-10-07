import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'photo_field.dart';

/// "Krótkie odcinki" - reporting, from inside a task, that what is being
/// brought is remnants rather than a full drum (wpsApi's
/// short_length_reports).
///
/// **A report, not a stock movement.** It moves nothing and does not touch
/// the order's own progress - it is the record the office reads in wps.
class ShortLengthsApi {
  ShortLengthsApi(this._dio);
  final Dio _dio;

  /// Creates the report and returns its id. The photo goes up separately,
  /// under that id - the same two-step the order photo upload uses, because
  /// wpsApi keys an attachment by the row it belongs to and there is
  /// nothing to attach it to until the row exists.
  Future<String> create({
    required String orderId,
    required String itemNo,
    required String itemName,
    required String quantity,
    required String reportedBy,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/short-lengths',
      data: {
        'orderId': orderId,
        'itemNo': itemNo,
        'itemName': itemName,
        'quantity': quantity,
        'reportedBy': reportedBy,
      },
    );
    return res.data!['id'] as String;
  }

  Future<void> uploadPhoto({required String reportId, required PickedPhoto photo, required String uploadedBy}) async {
    final form = FormData.fromMap({
      'uploadedBy': uploadedBy,
      'photo': MultipartFile.fromBytes(
        photo.bytes,
        filename: photo.filename,
        // DioMediaType, not http_parser own MediaType: dio re-exports it, so
        // this needs no dependency of its own - same as smOrder uploadPhoto.
        contentType: DioMediaType('image', photo.contentType.split('/').last),
      ),
    });
    await _dio.post<Map<String, dynamic>>('/short-lengths/$reportId/photo', data: form);
  }
}

final shortLengthsApiProvider = Provider<ShortLengthsApi>((ref) => ShortLengthsApi(ref.watch(authedDioProvider)));
