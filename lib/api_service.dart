
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
static final Dio dio = Dio(
BaseOptions(
baseUrl: 'http://192.168.100.22:8000',
headers: {'Content-Type': 'application/json'},
),
);

static PersistCookieJar? cookieJar;
static Future<void>? _setupFuture;

static Future<void> setupSession() {
return _setupFuture ??= _initializeSession();
}

static Future<void> _initializeSession() async {
final directory = await getApplicationDocumentsDirectory();

cookieJar = PersistCookieJar(
storage: FileStorage('${directory.path}/cookies'),
);

dio.interceptors.add(CookieManager(cookieJar!));
}

static Future<bool> checkSession() async {
try {
final response = await dio.get('/api/check-session/');

print('Session status: ${response.statusCode}');
print('Session response: ${response.data}');

return response.data['logged_in'] == true;
} on DioException catch (e) {
print('Session HTTP error: ${e.response?.statusCode}');
print('Session error response: ${e.response?.data}');
print('Session connection error: ${e.message}');

return false;
} catch (e) {
print('Session error: $e');
return false;
}
}
}
