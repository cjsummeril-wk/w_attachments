import 'dart:async';

import 'package:frugal/frugal.dart' as frugal;
import 'package:mockito/mockito.dart';

import 'package:w_annotations_api/annotations_api_v1.dart' as t_annotations_api_v1;
import 'package:w_annotations_api/annotations_api_v1/f_w_annotations_service_service.dart';

import '../service_mock_proxy.dart';

class _FAnnotationsClientMock extends Mock implements FWAnnotationsService {}

class FAnnotationsClientMock extends ServiceMockProxy<_FAnnotationsClientMock> implements FWAnnotationsService {
  FAnnotationsClientMock() : super(new _FAnnotationsClientMock());

  @override
  Future<t_annotations_api_v1.FGetAttachmentsByIdsResponse> getAttachmentsByIds(
          frugal.FContext ctx, t_annotations_api_v1.FGetAttachmentsByIdsRequest request) =>
      new Future.value(mock.getAttachmentsByIds(ctx, request));
}
