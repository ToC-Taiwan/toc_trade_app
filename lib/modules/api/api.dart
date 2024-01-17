import 'dart:convert';
import 'dart:io';

import 'package:candlesticks/candlesticks.dart';
import 'package:cronet_http/cronet_http.dart';
import 'package:cupertino_http/cupertino_http.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:trade_agent/entity/entity.dart';

const String backendHost = 'tocraw.com';

const String backendURLPrefix = 'https://$backendHost/tmt/v1';
const String backendWSURLPrefix = 'wss://$backendHost/tmt/v1/stream/ws/pick-stock';
const String backendFutureWSURLPrefix = 'wss://$backendHost/tmt/v1/stream/ws/future';

class API {
  static final client = httpClient();

  static String _apiToken = '';

  static Client httpClient() {
    if (Platform.isAndroid) {
      final engine = CronetEngine.build(
        cacheMode: CacheMode.memory,
        cacheMaxSize: 32 * 1024 * 1024,
      );
      return CronetClient.fromCronetEngine(engine);
    }
    if (Platform.isIOS) {
      final config = URLSessionConfiguration.ephemeralSessionConfiguration()..cache = URLCache.withCapacity(memoryCapacity: 32 * 1024 * 1024);
      return CupertinoClient.fromSessionConfiguration(config);
    }
    return IOClient();
  }

  static set setAuthKey(String token) {
    _apiToken = token;
  }

  static String get authKey {
    return _apiToken;
  }

  static Future<void> login(String userName, String password) async {
    var loginBody = {
      'username': userName,
      'password': password,
    };
    final response = await client.post(
      Uri.parse('$backendURLPrefix/login'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(loginBody),
    );
    final result = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      _apiToken = result['token'];
    } else {
      throw result['code'] as int;
    }
  }

  static Future<void> refreshToken() async {
    final response = await client.get(
      Uri.parse('$backendURLPrefix/refresh'),
      headers: {
        "Authorization": _apiToken,
      },
    );
    final result = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw result['code'] as int;
    }
    _apiToken = result['token'];
  }

  static Future<void> register(String userName, String password, String email) async {
    var registerBody = {
      'username': userName,
      'password': password,
      'email': email,
    };
    final response = await client.post(
      Uri.parse('$backendURLPrefix/user'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(registerBody),
    );
    if (response.statusCode != 200) {
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      throw result['code'] as int;
    }
  }

  static Future<void> sendToken(bool enabled, String pushToken) async {
    final response = await client.put(
      Uri.parse('$backendURLPrefix/user/push-token'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": _apiToken,
      },
      body: jsonEncode({
        "push_token": pushToken,
        "enabled": enabled,
      }),
    );

    if (response.statusCode != 200) {
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      throw result['code'] as int;
    }
  }

  static Future<bool> checkTokenStatus(String pushToken) async {
    final response = await client.get(
      Uri.parse('$backendURLPrefix/user/push-token'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": _apiToken,
        "token": pushToken,
      },
    );

    final result = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw result['code'] as int;
    }
    return result['enabled'];
  }

  static Future<Balance> fetchBalance() async {
    final response = await client.get(
      Uri.parse('$backendURLPrefix/order/balance'),
      headers: {
        "Authorization": _apiToken,
      },
    );
    final result = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return Balance.fromJson(result);
    } else {
      throw result['code'] as int;
    }
  }

  static Future<List<Candle>> fetchCandles(String stockNum, String startDate, String interval) async {
    final response = await client.get(
      Uri.parse('$backendURLPrefix/history/day-kbar/$stockNum/$startDate/$interval'),
      headers: {
        "Authorization": _apiToken,
      },
    );
    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      var candleArr = <Candle>[];
      for (final i in result as List<dynamic>? ?? <dynamic>[]) {
        final tmp = KbarData.fromJson(i as Map<String, dynamic>);
        final time = DateTime.parse(tmp.kbarTime!);
        candleArr.add(
          Candle(
            date: time.add(const Duration(hours: 8)),
            high: tmp.high!.toDouble(),
            low: tmp.low!.toDouble(),
            open: tmp.open!.toDouble(),
            close: tmp.close!.toDouble(),
            volume: tmp.volume!.toDouble(),
          ),
        );
      }
      return candleArr;
    } else {
      throw (result as Map<String, dynamic>)['code'] as int;
    }
  }

  static Future<void> recalculateBalance(String date) async {
    final response = await client.put(
      Uri.parse('$backendURLPrefix/order/date/$date'),
      headers: {
        "Authorization": _apiToken,
      },
    );
    if (response.statusCode != 200) {
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      throw result['code'] as int;
    }
  }

  static Future<void> moveOrderToLatestTradeday(String orderID) async {
    final response = await client.patch(
      Uri.parse('$backendURLPrefix/order/future/$orderID'),
      headers: {
        "Authorization": _apiToken,
      },
    );
    if (response.statusCode != 200) {
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      throw result['code'] as int;
    }
  }

  static Future<FutureOrderArr> fetchOrders(String date) async {
    final response = await client.get(
      Uri.parse('$backendURLPrefix/order/date/$date'),
      headers: {
        "Authorization": _apiToken,
      },
    );
    final result = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return FutureOrderArr.fromJson(result);
    } else {
      throw result['code'] as int;
    }
  }

  static Future<List<Strategy>> fetchStrategy() async {
    final straregyArr = <Strategy>[];
    final response = await client.get(
      Uri.parse('$backendURLPrefix/analyze/reborn'),
      headers: {
        "Authorization": _apiToken,
      },
    );
    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      for (final i in result as List<dynamic>) {
        straregyArr.add(Strategy.fromJson(i as Map<String, dynamic>));
      }
      return straregyArr;
    } else {
      throw (result as Map<String, dynamic>)['code'] as int;
    }
  }

  static Future<List<Target>> fetchTargets(List<Target> current, num opt) async {
    final targetArr = <Target>[];
    if (opt == -1) {
      final response = await client.get(
        Uri.parse('$backendURLPrefix/targets'),
        headers: {
          "Authorization": _apiToken,
        },
      );
      final result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        for (final i in result as List<dynamic>) {
          targetArr.add(Target.fromJson(i as Map<String, dynamic>));
        }
        return targetArr;
      } else {
        throw (result as Map<String, dynamic>)['code'] as int;
      }
    } else {
      for (final i in current) {
        if (i.stock!.number!.substring(0, opt.toString().length) == opt.toString()) {
          targetArr.add(i);
        }
      }
    }
    return targetArr;
  }

  static Future<Config> fetchConfig() async {
    final response = await client.get(
      Uri.parse('$backendURLPrefix/basic/config'),
      headers: {
        "Authorization": _apiToken,
      },
    );
    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Config.fromJson(result as Map<String, dynamic>);
    } else {
      throw (result as Map<String, dynamic>)['code'] as int;
    }
  }
}
