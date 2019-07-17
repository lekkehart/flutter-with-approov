import 'package:currency_converter/approov_utility.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class CurrencyConverterService {
  static const _serviceUrl =
      'https://europe-west1-currency-converter-245112.cloudfunctions.net/http';
  static final _headers = {
    'Content-Type': 'application/json',
    'Api-key': '',
    'Approov-Token': '',
  };

  Future<CurrencyConverterResponse> convertCurrency(
      http.Client client, CurrencyConverterRequest request) async {
    try {
      _headers['Approov-Token'] = await ApproovUtility.fetchApproovToken();

      Map<String, dynamic> json = CurrencyConverterRequest.toJson(request);
      final response = await client.post(_serviceUrl,
          headers: _headers, body: jsonEncode(json));

      if (response.statusCode == 200) {
        return CurrencyConverterResponse.fromJson(jsonDecode(response.body));
      } else {
        return CurrencyConverterResponse(statusCode: response.statusCode);
      }
    } catch (e) {
      return CurrencyConverterResponse(statusCode: -1);
    }
  }
}

class CurrencyConverterRequest {
  String fromCurrency;
  String toCurrency;
  String amount;

  CurrencyConverterRequest({this.fromCurrency, this.toCurrency, this.amount});

  factory CurrencyConverterRequest.fromJson(Map<String, dynamic> map) {
    return CurrencyConverterRequest(
      fromCurrency: map['from_currency'],
      toCurrency: map['to_currency'],
      amount: map['amount'],
    );
  }

  String print() {
    return 'from [$fromCurrency], to:[$toCurrency], amount[$amount]';
  }

  static Map<String, dynamic> toJson(CurrencyConverterRequest request) {
    Map<String, dynamic> mapData = new Map<String, dynamic>();
    mapData['from_currency'] = request.fromCurrency;
    mapData['to_currency'] = request.toCurrency;
    mapData['amount'] = request.amount;
    return mapData;
  }
}

class CurrencyConverterResponse {
  String amount;
  int statusCode;

  CurrencyConverterResponse({this.amount, this.statusCode});

  factory CurrencyConverterResponse.fromJson(Map<String, dynamic> map) {
    return CurrencyConverterResponse(
      amount: map['amount'],
      statusCode: 200,
    );
  }

  String print() {
    return 'amount[$amount], statusCode[$statusCode]';
  }
}
