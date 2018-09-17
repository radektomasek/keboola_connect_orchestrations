import 'package:scoped_model/scoped_model.dart';
import './connected_orchestrations.dart';

class MainModel extends Model
    with
        ConnectedOrchestrationsModel,
        KeboolaConnectionModel,
        UserModel,
        UtilityModel {}
