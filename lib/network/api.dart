import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:newapp/model/DisputeDetailsModel.dart';
import 'package:newapp/model/ApiResponse.dart';
import 'package:newapp/screen/honharKhiladiScreen.dart';
import 'dart:convert';
import 'dart:developer';

import '../utils/utils.dart';



class APIService {
  static const String apiUrl =
      'https://association.ssspltd.com/api';
  static const String apiKey =
      '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';


  Future<List<Map<String, dynamic>>?> generateMCQs(String difficulty) async {
    try {
      String prompt =
          '''Generate 5 random multiple-choice questions on general knowledge 
    with a $difficulty difficulty level.
    Each should have a question, 4 options (A, B, C, D), and the correct answer clearly marked.
    Return only valid JSON in this format:
    [
      {
        'question': 'What is 2+2?',
        'options': { 'A': '3', 'B': '4', 'C': '5', 'D': '6' },
        'correct_answer': 'B'
      }
    ]
    ''';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Your are a quiz generator bot that only returns valid JSON',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      //response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Success: ${jsonEncode(data)}');
        final mcqList = jsonDecode(data['choices'][0]['message']['content']);
        return List<Map<String, dynamic>>.from(mcqList);
      } else {
        showSnackBar('Error: ${response.body}');
        log('Error: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error: $e');
      return null;
    }
  }


  Future<List<Map<String, dynamic>>?> honharKhiladiList(String screen,String accountType, String token) async {
    try {

      final Uri url;

      if (screen == 'Honhar') {
        url = Uri.parse(
            'https://association.ssspltd.com/api/Account/GetAccountDetailsList?accountType=$accountType');
      } else {
        url = Uri.parse(
            'https://association.ssspltd.com/api/Account/GetAccountDetailsList');
      }
      final response = await http.post(
        url,
        headers: {
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '', // Required empty body as per your API
      );
      print('Url: ${url}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        print('Response: ${json}');
        if (json['success'] == true && json['data'] is List) {
          final List<Map<String, dynamic>> result =
          List<Map<String, dynamic>>.from(json['data']);
          return result;
        } else {
          showSnackBar(json['message'] ?? 'Unexpected response');
          return null;
        }
      } else {
        showSnackBar('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception: $e');
      showSnackBar('Something went wrong');
      return null;
    }
  }


  Future<List<Map<String, dynamic>>?> customerList(String accountType, String token) async {
    try {
      final url = Uri.parse(
          'https://association.ssspltd.com/api/Account/GetAccountNameList?accountType=$accountType');

      final response = await http.post(
        url,
        headers: {
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '', // Required empty body as per your API
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['success'] == true && json['data'] is List) {
          final List<Map<String, dynamic>> result =
          List<Map<String, dynamic>>.from(json['data']);
          return result;
        } else {
          showSnackBar(json['message'] ?? 'Unexpected response');
          return null;
        }
      } else {
        showSnackBar('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception: $e');
      showSnackBar('Something went wrong');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> suplierList(String accountType, String token) async {
    try {
      final url = Uri.parse(
          'https://association.ssspltd.com/api/Account/GetAccountDetailsList?accountType=$accountType');

      final response = await http.post(
        url,
        headers: {
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '', // Required empty body as per your API
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['success'] == true && json['data'] is List) {
          final List<Map<String, dynamic>> result =
          List<Map<String, dynamic>>.from(json['data']);
          return result;
        } else {
          showSnackBar(json['message'] ?? 'Unexpected response');
          return null;
        }
      } else {
        showSnackBar('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception: $e');
      showSnackBar('Something went wrong');
      return null;
    }
  }


  Future<List<Map<String, dynamic>>?> disputeDetailsByAccountId(String category,String id, String token) async {
    try {
      final url = Uri.parse(
          'https://association.ssspltd.com/api/Account/GetDisputeDetailsByAccountId?accountId=$id&accountType=$category');

      final response = await http.post(
        url,
        headers: {
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '', // Required empty body as per your API
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        print(response.body);
        if (json['success'] == true && json['data'] is List) {
          final List<Map<String, dynamic>> result =
          List<Map<String, dynamic>>.from(json['data']);
          return result;
        } else {
          showSnackBar(json['message'] ?? 'Unexpected response');
          return null;
        }
      } else {
        showSnackBar('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception: $e');
      showSnackBar('Something went wrong');
      return null;
    }
  }

  Future<Map<String, dynamic>?> login(String mobileNumber) async {
    try {
      final url = Uri.parse('https://association.ssspltd.com/api/Login/GetLoginDetails?mobileNo=$mobileNumber');

      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
        },
        body: '', // if server expects empty body
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Login Success: ${jsonEncode(data)}');
        return data; // Return JSON map
      } else {
        log('Login Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('Login Exception: $e');
      return null;
    }
  }

  static const String baseUrl = 'https://association.ssspltd.com/api';

  static Future<Map<String, dynamic>?> accessWithoutLogin() async {
    try {
      final url = Uri.parse('$baseUrl/Login/accessWithoutLogin');

      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('✅ Login Success: ${jsonEncode(data)}');
        return data;
      } else {
        log('❌ Login Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('🚨 Login Exception: $e');
      return null;
    }
  }


  Future<DisputeDetailsModel?> getDisputeDetailData(String customerId,String supplierId, String token) async {

        try {
        final url = Uri.parse(
            'https://association.ssspltd.com/api/Account/GetDisputeDetailData?customerId=$customerId&supplierId=$supplierId');
        print('Req: ${url}');
        final response = await http.post(
          url,
          headers: {
            'Accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: '', // required empty body
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> json = jsonDecode(response.body);
          print('Response: ${response.body}');
          print('Success flag: ${json['success']}');
          print('Data content: ${json['data']}');

          if (json['success'] == true && json['data'] != null) {
            final model = DisputeDetailsModel.fromJson(json['data']);
            print('Parsed Model: $model');
            return model;
          } else {
         //   showSnackBar(json['message'] ?? 'Unexpected response');
            return null;
          }
        }
      } catch (e) {
          log('Exception: $e');
          showSnackBar('Something went wrong');
          return null;
        }
  }


  Future<ApiResponse?> addUpdateBanner(String id,String bannerImagePath, String token,) async {
    print('token: ${token}');
    try {
      final url = Uri.parse(
          'https://association.ssspltd.com/api/Banner/SaveUpdateBannerDetails');
      print('Url: ${url}');

      final body = jsonEncode({
        "id": id,
        "bannerImagePath": bannerImagePath,
        "title": "Test  banner",

      });
      print('Req: ${body}');

      final response = await http.post(url,   headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }, body: body);


      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        print('Response: ${response.body}');
        print('Success flag: ${json['success']}');
        print('Data content: ${json['data']}');
        print('Res: ${json}');
        if (json['success'] == true) {
          final data = json['data'];
          if (data is Map<String, dynamic>) {
            final model = ApiResponse.fromJson(data);
            print('Parsed Model: $model');
            return model;
          } else {
            // It's not a model; just show success message
            showSnackBar(json['message'] ?? 'Operation successful');
            return null;
          }
        } else {
          showSnackBar(json['message'] ?? 'Unexpected response');
          return null;
        }
      }

    } catch (e) {
      log('Exception: $e');
      showSnackBar('Something went wrong');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> bannerList( String token) async {
    try {
      final url = Uri.parse(
          'https://association.ssspltd.com/api/Banner/GetBannerDetailsList');

      print('Url: ${url}');
      final response = await http.post(
        url,
        headers: {
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '', // Required empty body as per your API
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        print('Res: ${json}');
        if (json['success'] == true && json['data'] is List) {
          final List<Map<String, dynamic>> result =
          List<Map<String, dynamic>>.from(json['data']);
          return result;
        } else {
          showSnackBar(json['message'] ?? 'Unexpected response');
          return null;
        }
      } else {
        showSnackBar('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception: $e');
      showSnackBar('Something went wrong');
      return null;
    }
  }


  Future<ApiResponse?> logOut(String mobileNumber, String token) async {

    try {
      final url = Uri.parse(
          'https://association.ssspltd.com/api/Login/LogOutUser?mobileNo=$mobileNumber');
      print('Req: ${url}');
      final response = await http.post(
        url,
        headers: {
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '', // required empty body
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        // ✅ Success Check
        if (json['success'] == true) {
          // ✅ Build ApiResponse directly from full JSON
          final model = ApiResponse.fromJson(json);
          print('Parsed Model: $model');
          return model;
        } else {
          showSnackBar(json['message'] ?? 'Unexpected response');
          return null;
        }
      }
    } catch (e) {
      log('Exception: $e');
      showSnackBar('Something went wrong');
      return null;
    }
  }


  Future<String?> deleteBanner(String id, String token) async {
    try {
      final url = Uri.parse(
          'https://association.ssspltd.com/api/Banner/DeleteBannerDetailsById?id=$id');
      print('Url: $url');

      final response = await http.post(
        url,
        headers: {
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '', // empty body as expected
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        print('Response JSON: $json');
        if (json['success'] == true) {
          return json['message']; // This is your URL string
        } else {
          showSnackBar(json['message'] ?? 'Unexpected response');
          return null;
        }
      } else {
        showSnackBar('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      log('Exception: $e');
      showSnackBar('Something went wrong');
      return null;
    }
  }







}
