import 'dart:developer';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:kazakhi_auto_admin/constants/app_constants.dart';
import 'package:kazakhi_auto_admin/utils/local_utils.dart';

class ApiClient {
  static Future<dynamic> get(String endpoint) async {
    log('GET ' + AppConstant.baseUrl.toString() + endpoint);
    String localLang = await LocalUtils.getLanguage();
    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
    Future<http.Response> makeGetRequest() async {
      String token = await LocalUtils.getAccessToken() ?? '';

      return await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'appLanguage': localLang,
          'Authorization': 'Bearer $token',
        },
      );
    }

    http.Response response = await makeGetRequest();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
        'status': response.statusCode.toString(),
      };
    }

    if (response.statusCode == 401) {
      await LocalUtils.logout();

      // await _refreshToken(response);
      // response = await makeGetRequest();

      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   return {
      //     'success': true,
      //     'data': jsonDecode(response.body),
      //     'status': response.statusCode.toString(),
      //   };
      // } else {
      //   return {
      //     'success': false,
      //     'data': jsonDecode(response.body),
      //     'status': response.statusCode.toString(),
      //   };
      // }
    }

    return {
      'success': false,
      'data': jsonDecode(response.body),
      'status': response.statusCode.toString(),
    };
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      String localLang = await LocalUtils.getLanguage();

      final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
      Future<http.Response> makePostRequest() async {
        String token = await LocalUtils.getAccessToken() ?? '';
        log('POST ' + AppConstant.baseUrl.toString() + endpoint);
        return await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'appLanguage': localLang,
            'Authorization': 'Bearer $token',
            // 'Mobapp-Version': mbVer
          },
          body: jsonEncode(data),
        );
      }

      http.Response response = await makePostRequest();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      if (response.statusCode == 401) {
        response = await makePostRequest();
        if (response.statusCode == 200 || response.statusCode == 201) {
          return {'success': true, 'data': jsonDecode(response.body)};
        } else {
          return {'success': false, 'data': jsonDecode(response.body)};
        }
      }
      log(response.body.toString());
      return {'success': false, 'data': jsonDecode(response.body)};
    } catch (e) {
      return {
        'success': false,
        'data': {'message': e.toString()},
      };
    }
  }

  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool unAuth = false,
  }) async {
    String localLang = await LocalUtils.getLanguage();

    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
    Future<http.Response> makePostRequest() async {
      String token = await LocalUtils.getAccessToken() ?? '';

      return await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'appLanguage': localLang,
          if (!unAuth) 'Authorization': 'Bearer $token',

          // 'Mobapp-Version': mbVer
        },
        body: jsonEncode(data),
      );
    }

    http.Response response = await makePostRequest();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    if (response.statusCode == 401) {
      response = await makePostRequest();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'data': jsonDecode(response.body)};
      }
    }
    return {'success': false, 'data': jsonDecode(response.body)};
  }

  static Future<dynamic> postUnAuth(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    String localLang = await LocalUtils.getLanguage();
    // String mbVer = await AuthUtils.getIndexMobileVersion();
    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'appLanguage': localLang,

        // 'Mobapp-Version': mbVer
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'data': jsonDecode(response.body)};
    }
  }

  static Future<dynamic> getUnAuth(String endpoint) async {
    String localLang = await LocalUtils.getLanguage();
    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'appLanguage': localLang,

        // 'Mobapp-Version': mbVer
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'data': jsonDecode(response.body)};
    }
  }

  static Future<void> _refreshToken(http.Response response) async {
    final refreshToken = await LocalUtils.getRefreshToken();
    final url = Uri.parse(AppConstant.baseUrl + 'api/auth/refreshAccessToken');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await LocalUtils.setAccessToken(data['accessToken']);
    } else {
      print('Failed to refresh token');
    }
  }

  static Future<dynamic> getBinary(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    String token = await LocalUtils.getAccessToken() ?? '';
    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
    String localLang = await LocalUtils.getLanguage();
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/pdf', // Expecting PDF response
        'Content-Type': 'application/json', // Indicating JSON content
        'appLanguage': localLang,
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'data': response.bodyBytes, // Return binary content
        'status': response.statusCode.toString(),
      };
    } else if (response.statusCode == 401) {
      await _refreshToken(response);

      return await getBinary(endpoint, data);
    } else {
      return {
        'success': false,
        'data': response.bodyBytes,
        'status': response.statusCode.toString(),
      };
    }
  }

  static Future<dynamic> getBinaryDownload(String endpoint) async {
    String token = await LocalUtils.getAccessToken() ?? '';
    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
    String localLang = await LocalUtils.getLanguage();

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/pdf', // Expecting PDF response
        'Content-Type': 'application/json', // Indicating JSON content
        'appLanguage': localLang,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'data': response.bodyBytes, // Return binary content
        'status': response.statusCode.toString(),
      };
    } else if (response.statusCode == 401) {
      await _refreshToken(response);
      return await getBinaryDownload(endpoint);
    } else {
      return {
        'success': false,
        'data': response.bodyBytes,
        'status': response.statusCode.toString(),
      };
    }
  }
}
