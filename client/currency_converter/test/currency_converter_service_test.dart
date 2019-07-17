import 'dart:convert';

import 'package:currency_converter/currency_converter_service.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

void main() {
  final requestOne = CurrencyConverterRequest();
  requestOne.amount = '100';
  requestOne.fromCurrency = 'SEK';
  requestOne.toCurrency = 'EUR';

  group('CurrencyConverterRequest', () {
    test('Should print output', () {
      final output = requestOne.print();

      expect(output,
          'from [SEK], to:[EUR], amount[100]');
    });

    test('Should convert to json', () {
      final map = CurrencyConverterRequest.toJson(requestOne);

      expect(map['amount'], requestOne.amount);
      expect(map['from_currency'], requestOne.fromCurrency);
      expect(map['to_currency'], requestOne.toCurrency);
    });
  });

  group('CurrencyConverterResponse', () {
    test('Should convert from json', () {
      String s = '{ "amount": "100.00" }';

      Map<String, dynamic> map = jsonDecode(s);
      CurrencyConverterResponse response =
          CurrencyConverterResponse.fromJson(map);

      expect(response.amount, '100.00');
      expect(response.statusCode, 200);
    });
  });

  group('CurrencyConverterService', () {
    test('Should return converted amount when remote call succeeds', () async {
      final client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.post(
        'https://europe-west1-currency-converter-245112.cloudfunctions.net/http',
        headers: anyNamed('headers'),
        body: jsonEncode(CurrencyConverterRequest.toJson(requestOne)),
      )).thenAnswer((_) async => http.Response('{ "amount": "100.00"}', 200));

      var currencyConverterService = new CurrencyConverterService();

      var response =
          await currencyConverterService.convertCurrency(client, requestOne);
      expect(response, TypeMatcher<CurrencyConverterResponse>());
      expect(response.amount, "100.00");
      expect(response.statusCode, 200);     
    });

    test('Should return statusCode other than 200 when remote call fails', () async {
      final client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.post(
        'https://europe-west1-currency-converter-245112.cloudfunctions.net/http',
        headers: anyNamed('headers'),
        body: jsonEncode(CurrencyConverterRequest.toJson(requestOne)),
      )).thenAnswer((_) async => http.Response('{}', 500));

      var currencyConverterService = new CurrencyConverterService();

      var response =
          await currencyConverterService.convertCurrency(client, requestOne);
      expect(response, TypeMatcher<CurrencyConverterResponse>());
      expect(response.amount, null);
      expect(response.statusCode, 500);     
    });
  });
}
