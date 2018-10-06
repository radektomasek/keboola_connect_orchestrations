import 'dart:async';
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/orchestration.dart';
import '../models/orchestration_detail.dart';

class ConnectedOrchestrationsModel extends Model {
  List<Orchestration> _orchestrations = [];
  List<OrchestrationDetail> _selectedOrchestration = [];
  User _authenticatedUser;
  bool _isLoading = false;
}

class KeboolaConnectionModel extends ConnectedOrchestrationsModel {
  List<Orchestration> get allOrchestrations {
    return List.from(_orchestrations);
  }

  List<OrchestrationDetail> get selectedOrchestration {
    return _selectedOrchestration;
  }

  Future<bool> fetchOrchestrationById(int orchestrationId) async {
    _isLoading = true;
    notifyListeners();
    try {
      http.Response response = await http.get(
          'https://syrup.eu-central-1.keboola.com/orchestrator/orchestrations/${orchestrationId.toString()}/jobs',
          headers: {
            'Content-Type': 'application/json',
            'X-StorageApi-Token': _authenticatedUser.token
          });

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<OrchestrationDetail> orchestrationDetailList =
            responseData.map(
          (orchestrationDetail) {
            return OrchestrationDetail(
              id: orchestrationDetail['id'],
              active: orchestrationDetail['active'],
              status: orchestrationDetail['status'],
              endTime: orchestrationDetail['endTime'],
              description: orchestrationDetail['token']['description'],
              errorMessage: orchestrationDetail['results']['tasks'][0]
                  ['response']['result']['message'],
            );
          },
        ).toList();

        _selectedOrchestration = orchestrationDetailList;
        _isLoading = false;

        notifyListeners();
        return true;
      } else {
        final dynamic responseData = json.decode(response.body);
        throw (responseData['message']);
      }
    } catch (error) {
      print(error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchOrchestrations() async {
    _isLoading = true;
    notifyListeners();
    try {
      http.Response response = await http.get(
          'https://syrup.eu-central-1.keboola.com/orchestrator/orchestrations',
          headers: {
            'Content-Type': 'application/json',
            'X-StorageApi-Token': _authenticatedUser.token
          });

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<Orchestration> orchestrationList = responseData.map(
          (orchestration) {
            return Orchestration(
              id: orchestration['id'],
              name: orchestration['name'],
              active: orchestration['active'],
              createdTime: orchestration['createdTime'],
              status: orchestration['lastExecutedJob']['status'],
              lastScheduledTime: orchestration['lastScheduledTime'],
              nextScheduledTime: orchestration['nextScheduledTime'],
            );
          },
        ).toList();
        _orchestrations = orchestrationList;
        _selectedOrchestration = [];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final dynamic responseData = json.decode(response.body);
        throw (responseData['message']);
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

class UserModel extends ConnectedOrchestrationsModel {
  User get user {
    return _authenticatedUser;
  }

  Future<bool> isTokenValid(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      http.Response response = await http.get(
          'https://syrup.eu-central-1.keboola.com/orchestrator/orchestrations',
          headers: {
            'Content-Type': 'application/json',
            'X-StorageApi-Token': token.trim()
          });

      if (response.statusCode == 200) {
        _authenticatedUser = User(
          token: token,
        );
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token.trim());
        _isLoading = false;
        notifyListeners();
        return true;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      throw (responseData['message']);
    } catch (error) {
      print(error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void readTokenFromStorage() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token');
      if (token != null) {
        _authenticatedUser = User(token: token);
        print(_authenticatedUser.token);
        notifyListeners();
      }
    } catch (error) {}
  }

  void logout() async {
    try {
      _authenticatedUser = null;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
    } catch (error) {}
  }
}

class UtilityModel extends ConnectedOrchestrationsModel {
  bool get isLoading {
    return _isLoading;
  }
}
