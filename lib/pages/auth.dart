import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';
import '../models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  String _authToken;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Datacenter _datacenter = Datacenter.EU;

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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.0),
      child: TextFormField(
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
      ),
    );
  }

  Widget _buildRadioForRegionSelect() {
    return Column(children: <Widget>[
      Text('Please select your datacenter'),
      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Radio<int>(
            value: Datacenter.EU.index,
            groupValue: _datacenter.index,
            onChanged: (value) {
              setState(() {
                _datacenter = Datacenter.EU;
              });
            }),
        Text('EU'),
        Radio<int>(
            value: Datacenter.US.index,
            groupValue: _datacenter.index,
            onChanged: (value) {
              setState(() {
                _datacenter = Datacenter.US;
              });
            }),
        Text('US'),
        Radio<int>(
            value: Datacenter.AU.index,
            groupValue: _datacenter.index,
            onChanged: (value) {
              setState(() {
                _datacenter = Datacenter.AU;
              });
            }),
        Text('AU'),
      ])
    ]);
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Container(
                margin: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(),
              )
            : RaisedButton(
                child: Text('Login'),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                splashColor: Colors.blueGrey,
                elevation: 4.0,
                onPressed: () =>
                    _handleSubmitForm(model.isTokenValid, _datacenter),
              );
      },
    );
  }

  void _handleSubmitForm(Function isTokenValid, Datacenter datacenter) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();
    bool isValid = await isTokenValid(_authToken, datacenter);
    if (isValid) {
      Navigator.pushReplacementNamed(context, '/orchestrations');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('An error occurred'),
            content: Text(
                'Fetching of orchestrations wasn\'t successful. Please verify your token, make sure you have selected the correct datacenter and try it again.'),
            actions: <Widget>[
              RaisedButton(
                child: Text('Okay'),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                splashColor: Colors.blueGrey,
                elevation: 4.0,
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
              _buildRadioForRegionSelect(),
              _buildVerticalSpace(),
              _buildSubmitButton()
            ],
          ),
        ),
      ),
    );
  }
}
