import 'package:currency_converter/approov_utility.dart';
import 'package:currency_converter/currency_converter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';

void main() => runApp(MyStatelessWidget());

class MyStatelessWidget extends StatelessWidget {
  final _appTitle = 'Currency Converter';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appTitle,
      home: MyHomePage(
        appTitle: _appTitle,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String appTitle;

  const MyHomePage({Key key, @required this.appTitle}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _approovIsInitialized = false;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  CurrencyConverterRequest currencyConverterRequest =
      new CurrencyConverterRequest();

  String _convertedAmount = '';

  @override
  void initState() {
    super.initState();
    ApproovUtility.initApproov().then((_) => setState(() {
          _approovIsInitialized = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.appTitle),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    MaterialColor _color = Theme.of(context).primaryColor;

    if (!_approovIsInitialized) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Initializing Approov'),
          ),
        ],
      ));
    } else {
      return Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            Image.asset(
              'images/money.jpg',
              width: 600,
              height: 80,
              fit: BoxFit.cover,
            ),
            CurrencySelectorWidget(
              label: 'From',
              onChanged: _handleFromCurrencyChanged,
              selectedCurrency: currencyConverterRequest.fromCurrency,
            ),
            CurrencySelectorWidget(
              label: 'To',
              onChanged: _handleToCurrencyChanged,
              selectedCurrency: currencyConverterRequest.toCurrency,
            ),
            TextFormField(
              style: TextStyle(
                color: _color,
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter an amount';
                }
                return null;
              },
              onSaved: (value) => currencyConverterRequest.amount = value,
              decoration: InputDecoration(
                  icon: const Icon(Icons.input),
                  hintText: 'Enter amount',
                  labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
                WhitelistingTextInputFormatter.digitsOnly
              ],
            ),
            Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: RaisedButton(
                    onPressed: _submitForm, child: Text('Convert'))),
            Container(
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                _convertedAmount,
                style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 40),
              ),
              decoration: new BoxDecoration(border: new Border.all()),
            ),
          ],
        ),
      );
    }
  }

  void _submitForm() {
    setState(() {
      _convertedAmount = '';
    });

    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _showMessage('Form is not valid! Please review and correct.');
    } else {
      form.save(); //This invokes each onSaved event

      var currencyConverterService = new CurrencyConverterService();
      currencyConverterService
          .convertCurrency(IOClient(), currencyConverterRequest)
          .then((value) {
        switch (value.statusCode) {
          case 200:
            _showMessage('${value.print()}', Colors.green);
            setState(() {
              _convertedAmount = value.amount;
            });
            break;
          case -1:
            _showMessage('${value.print()}', Colors.deepPurple);
            break;
          default:
            _showMessage('${value.print()}', Colors.deepOrange);
        }
      });
    }
  }

  void _showMessage(String message,
      [MaterialColor backgroundColor = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        backgroundColor: backgroundColor, content: new Text(message)));
  }

  void _handleFromCurrencyChanged(String value) {
    setState(() {
      currencyConverterRequest.fromCurrency = value;
    });
  }

  void _handleToCurrencyChanged(String value) {
    setState(() {
      currencyConverterRequest.toCurrency = value;
    });
  }
}

class CurrencySelectorWidget extends StatelessWidget {
  final String label;
  final ValueChanged<String> onChanged;
  final String selectedCurrency;

  CurrencySelectorWidget(
      {Key key,
      @required this.label,
      @required this.onChanged,
      @required this.selectedCurrency})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const currencyList = ['EUR', 'SEK', 'USD'];
    final MaterialColor _color = Theme.of(context).primaryColor;

    return FormField(
      validator: (value) {
        return value != null ? null : 'Please select a currency';
      },
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            icon: const Icon(Icons.attach_money),
            labelText: label,
            errorText: state.hasError ? state.errorText : null,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: selectedCurrency,
              isDense: true,
              items: currencyList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: _color,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                _handleOnChanged(value);
                state.didChange(value);
              },
              hint: Text(
                'Select currency',
                style: TextStyle(
                  color: _color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleOnChanged(String value) {
    onChanged(value);
  }
}
