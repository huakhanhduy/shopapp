import 'dart:convert';

import 'package:http/http.dart'
as http;

import '../core/constants/api_constants.dart';
import '../models/home_response.dart';

class HomeService {

  Future<HomeResponse>
  getHome() async {

    final response =
    await http.get(

      Uri.parse(
        "${ApiConstants.baseUrl}/api/home",
      ),
    );

    if(response.statusCode == 200){

      return HomeResponse.fromJson(
        jsonDecode(
          response.body,
        ),
      );
    }

    throw Exception(
      "Load home failed",
    );
  }
}