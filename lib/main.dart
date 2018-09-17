import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './scoped-models/main.dart';

import './pages/auth.dart';
import './pages/orchestration_list.dart';
import './pages/orchestration_detail.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();

  @override
  void initState() {
    super.initState();
    _model.readTokenFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          accentColor: Colors.blue,
          buttonColor: Colors.blue,
        ),
        home: _model.user == null ? AuthPage() : OrchestrationList(_model),
        routes: {
          '/orchestrations': (BuildContext context) => OrchestrationList(_model)
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');

          if (pathElements[0] != '') {
            return null;
          }

          if (pathElements[1] == 'orchestration') {
            final int orchestrationId = int.parse(pathElements[2]);

            return MaterialPageRoute<bool>(
                builder: (BuildContext context) =>
                    OrchestrationDetail(_model, orchestrationId));
          }

          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => OrchestrationList(_model));
        },
      ),
    );
  }
}
