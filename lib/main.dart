import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() => runApp(SignUpApp());

class SignUpApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => SignUpScreen(),
        '/welcome': (context) => DashboardScreen(),
      },
    );
  }
}

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: SizedBox(
            width: 400,
            height: 220,
            child: SignUpForm(),
          ),
        ));
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Card(
          child: DashboardForm(),
        ),
      ),
    );
  }
}

class DashboardForm extends StatefulWidget {
  @override
  _DashboardFormState createState() => _DashboardFormState();
}

class _DashboardFormState extends State<DashboardForm> {
  final _productIdTxtFld = TextEditingController();

  var _productIdValid = false;
  var _productId = "";

  void _updateDashboard() {
    var productValid;
    var productId;
    if (_productIdTxtFld.value.text == "1" ||
        _productIdTxtFld.value.text == "2" ||
        _productIdTxtFld.value.text == "3" ||
        _productIdTxtFld.value.text == "4") {
      productValid = true;
      productId = _productIdTxtFld.value.text;
    } else {
      productValid = false;
      productId = "";
    }

    setState(() {
      _productIdValid = productValid;
      _productId = productId;
    });
  }

  _showNotificationSnackbar(BuildContext context, isValid) {
    if (!isValid) _productIdTxtFld.text = "";
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: isValid == false ? Colors.red : Colors.green,
        content: isValid == false
            ? const Text('Die Eingabe war fehlerhaft.')
            : const Text('Die Notification wurde versendet.'),
        action: SnackBarAction(
            label: 'Close', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Form(
        onChanged: _updateDashboard,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'uller.png',
                  width: 35,
                ),
                Text('Uller Dashboard',
                    style: Theme.of(context).textTheme.headline4),
              ],
            ),
            getRow("Send Notification"),
          ],
        ),
      ),
    ));
  }

  getRow(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.padded,
            foregroundColor:
                MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              return states.contains(MaterialState.disabled)
                  ? null
                  : Colors.white;
            }),
            backgroundColor:
                MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              return states.contains(MaterialState.disabled)
                  ? null
                  : Colors.blue;
            }),
          ),
          onPressed: () => _productIdValid == true
              ? sendNotification(_productIdTxtFld.value.text)
              : _showNotificationSnackbar(context, false),
          child: Text(text),
        ),
        Flexible(
          child: TextFormField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: _productIdTxtFld,
            decoration: const InputDecoration(hintText: 'Product Id'),
          ),
        ),
        const Flexible(
          child: Text("ProductId: \n"
              "1 = PlayStation 5 \n"
              "2 = Xbox Series X \n"
              "3 = GPUs \n"
              "4 = Nintendo Switch \n"),
        ),
      ],
    );
  }

  void sendNotification(String id) {
    postNotification(id);
    _showNotificationSnackbar(context, true);
  }

  postNotification(String id) async {
    await http.get(
        Uri.parse('http://192.168.178.23:8081/notification?productId=$id'));
  }

  Future<http.Response> getProductList() {
    return http.get(Uri.parse('http://192.168.178.23:8081/productlist'));
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _userNameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  double _formProgress = 0;
  var _userName = "";
  var _password = "";

  void _showWelcomeScreen() {
    if (_userName == "admin" && _password == "admin") {
      Navigator.of(context).pushNamed('/welcome');
    } else {
      _passwordTextController.text = "";
      _showToast(context);
    }
  }

  void _updateFormProgress() {
    var progress = 0.0;
    final controllers = [
      _userNameTextController,
      _passwordTextController,
    ];

    for (final controller in controllers) {
      if (controller.value.text.isNotEmpty) {
        progress += 1 / controllers.length;
      }
    }

    setState(() {
      _formProgress = progress;
      _userName = _userNameTextController.value.text;
      _password = _passwordTextController.value.text;
    });
  }

  _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: const Text('Die Eingabe war fehlerhaft.'),
        action: SnackBarAction(
            label: 'Close', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      onChanged: _updateFormProgress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'uller.png',
                width: 35,
              ),
              Text('Uller Login', style: Theme.of(context).textTheme.headline4),
            ],
          ),
          LinearProgressIndicator(value: _formProgress),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _userNameTextController,
              decoration: InputDecoration(hintText: 'Username'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              obscureText: true,
              controller: _passwordTextController,
              decoration: InputDecoration(hintText: 'Password'),
            ),
          ),
          TextButton(
            style: ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.padded,
              foregroundColor: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> states) {
                return states.contains(MaterialState.disabled)
                    ? null
                    : Colors.white;
              }),
              backgroundColor: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> states) {
                return states.contains(MaterialState.disabled)
                    ? null
                    : Colors.blue;
              }),
            ),
            onPressed: _formProgress == 1 ? _showWelcomeScreen : null,
            // UPDATED
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
