import 'dart:async';
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth.dart';
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
  bool _showFavorites = false;

  List<Orchestration> get allOrchestrations {
    return List.from(_orchestrations);
  }

  List<Orchestration> get highlightedOrchestrations {
    if (_showFavorites) {
      return _orchestrations
          .where((Orchestration orchestration) => orchestration.isFavorite)
          .toList();
    }

    return List.from(_orchestrations);
  }

  void toggleOrchestrationFavoriteStatus(int id) {
    final List<Orchestration> updatedOrchestrationList =
        _orchestrations.map((Orchestration orchestration) {
      if (orchestration.id == id) {
        return Orchestration(
            id: orchestration.id,
            active: orchestration.active,
            createdTime: orchestration.createdTime,
            lastScheduledTime: orchestration.lastScheduledTime,
            name: orchestration.name,
            nextScheduledTime: orchestration.lastScheduledTime,
            status: orchestration.status,
            isFavorite: !orchestration.isFavorite);
      }
      return orchestration;
    }).toList();

    _orchestrations = updatedOrchestrationList;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }

  List<OrchestrationDetail> get selectedOrchestration {
    return _selectedOrchestration;
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<bool> fetchOrchestrationById(int orchestrationId) async {
    _isLoading = true;
    notifyListeners();
    try {
      http.Response response = await http.get(
          '${_authenticatedUser.datacenter}/orchestrator/orchestrations/${orchestrationId.toString()}/jobs',
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
          '${_authenticatedUser.datacenter}/orchestrator/orchestrations',
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

String getBaseApiUrl(Datacenter datacenter) {
  if (datacenter == Datacenter.AU) {
    return 'https://syrup.ap-southeast-2.keboola.com';
  } else if (datacenter == Datacenter.EU) {
    return 'https://syrup.eu-central-1.keboola.com';
  } else {
    return 'https://syrup.keboola.com';
  }
}

class UserModel extends ConnectedOrchestrationsModel {
  User get user {
    return _authenticatedUser;
  }

  Future<bool> isTokenValid(String token,
      [Datacenter datacenter = Datacenter.EU]) async {
    _isLoading = true;
    notifyListeners();

    String baseApiUrl = getBaseApiUrl(datacenter);

    try {
      http.Response response = await http
          .get('$baseApiUrl/orchestrator/orchestrations', headers: {
        'Content-Type': 'application/json',
        'X-StorageApi-Token': token.trim()
      });

      if (response.statusCode == 200) {
        _authenticatedUser = User(token: token, datacenter: baseApiUrl);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token.trim());
        prefs.setString('datacenter', baseApiUrl);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      throw (responseData['message']);
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void readTokenFromStorage() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token');
      final String datacenter = prefs.getString('datacenter');
      if (token != null) {
        _authenticatedUser = User(token: token, datacenter: datacenter);
        notifyListeners();
      }
    } catch (error) {}
  }

  void logout() async {
    try {
      _authenticatedUser = null;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      prefs.remove('datacenter');
    } catch (error) {}
  }
}

class UtilityModel extends ConnectedOrchestrationsModel {
  bool get isLoading {
    return _isLoading;
  }
}
