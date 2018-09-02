import 'package:flutter/material.dart';

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
    return FlatButton(
      child: Text('Login'),
      onPressed: _handleSubmitForm,
    );
  }

  void _handleSubmitForm() {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();
    print('token: $_authToken');
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
