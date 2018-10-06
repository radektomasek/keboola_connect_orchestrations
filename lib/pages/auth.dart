import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  String _authToken;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildLogo() {
    return Center(
      child: Image.asset('assets/keboola.png'),
    );
  }

  Widget _buildVerticalSpace() {
    return SizedBox(
      height: 10.0,
    );
  }

  Widget _buildInfoText() {
    return Text('Please insert your token to see your list of orchestrations');
  }

  Widget _buildTokenTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Token',
        filled: true,
        fillColor: Colors.white70,
      ),
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty) {
          return 'You have to insert your KBC token to be able to continue!';
        }
      },
      onSaved: (String value) async {
        _authToken = value;
      },
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? CircularProgressIndicator()
            : FlatButton(
                child: Text('Login'),
                onPressed: () => _handleSubmitForm(model.isTokenValid),
              );
      },
    );
  }

  void _handleSubmitForm(Function isTokenValid) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();
    bool isValid = await isTokenValid(_authToken);
    if (isValid) {
      Navigator.pushReplacementNamed(context, '/orchestrations');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('An error occurred'),
            content: Text(
                'Fetching of orchestrations wasn\'t successful. Please verify your token and try it again!'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authorization'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildLogo(),
              _buildVerticalSpace(),
              _buildInfoText(),
              _buildVerticalSpace(),
              _buildTokenTextField(),
              _buildVerticalSpace(),
              _buildSubmitButton()
            ],
          ),
        ),
      ),
    );
  }
}
