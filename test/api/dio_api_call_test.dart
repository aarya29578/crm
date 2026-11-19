import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/constants.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Dio dio;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocalStorage.sharedPreferences = await SharedPreferences.getInstance();
    dio = Dio();
    DioUtil.dio = dio;
  });

  tearDown(() {
    dio.close(force: true);
  });

  test('sends the idempotency key and returns a successful response', () async {
    final requestIdempotencyKeys = <String?>[];
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestIdempotencyKeys.add(
            options.headers['Idempotency-Key'] as String?,
          );
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 201,
              data: {'success': true},
            ),
          );
        },
      ),
    );

    final response = await DioApi().postPhoneCall({
      'lead_id': 'lead-1',
    }, idempotencyKey: 'session-123');
    await DioApi().postPhoneCall({
      'lead_id': 'lead-1',
    }, idempotencyKey: 'session-123');

    expect(requestIdempotencyKeys, ['session-123', 'session-123']);
    expect(response, {'success': true});
  });

  test(
    'throws on an HTTP error instead of returning it as success data',
    () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 503,
                data: {'success': false},
              ),
            );
          },
        ),
      );

      await expectLater(
        DioApi().postPhoneCall({'lead_id': 'lead-1'}),
        throwsA(isA<Exception>()),
      );
    },
  );

  test('throws when the API body explicitly reports failure', () async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': false},
            ),
          );
        },
      ),
    );

    await expectLater(
      DioApi().postPhoneCall({'lead_id': 'lead-1'}),
      throwsA(isA<StateError>()),
    );
  });

  test('propagates network failures to the caller', () async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionTimeout,
            ),
          );
        },
      ),
    );

    await expectLater(
      DioApi().postPhoneCall({'lead_id': 'lead-1'}),
      throwsA(isA<DioException>()),
    );
  });

  test('posts calls to the existing call endpoint', () async {
    String? requestPath;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestPath = options.uri.path;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true},
            ),
          );
        },
      ),
    );

    await DioApi().postPhoneCall({'lead_id': 'lead-1'});

    expect(requestPath, '${Uri.parse(link).path}/call/dial');
  });

  test('sends the current user as assignedTo for missed follow-ups', () async {
    final preferences = LocalStorage.sharedPreferences!;
    final requestedUris = <Uri>[];
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestedUris.add(options.uri);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true, 'data': []},
            ),
          );
        },
      ),
    );

    await preferences.setString('user_Id', 'user-1');
    await DioApi().getMissedFUps(
      currentDateTime: '2026-11-12T11:11:39.025Z',
      page: 1,
      limit: 50,
      search: 'first search',
    );

    await preferences.setString('user_Id', 'user-2');
    await DioApi().getMissedFUps(
      currentDateTime: '2026-11-12T11:11:39.025Z',
      page: 2,
      limit: 50,
      search: 'second search',
    );

    expect(
      requestedUris.map((uri) => uri.queryParameters['assignedTo']),
      ['user-1', 'user-2'],
    );
    expect(requestedUris.first.queryParameters, {
      'page': '1',
      'limit': '50',
      'search': 'first search',
      'currentTime': '2026-11-12T11:11:39.025Z',
      'assignedTo': 'user-1',
    });
    expect(requestedUris.last.queryParameters['page'], '2');
    expect(requestedUris.last.queryParameters['search'], 'second search');
  });

  test(
    'does not request missed follow-ups without a logged-in user ID',
    () async {
      var requestCount = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestCount++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
              ),
            );
          },
        ),
      );

      await expectLater(
        DioApi().getMissedFUps(),
        throwsA(isA<Exception>()),
      );
      expect(requestCount, 0);
    },
  );
}
