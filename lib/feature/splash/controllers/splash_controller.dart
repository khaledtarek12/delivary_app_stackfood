import 'package:delifast_multivendor_driver/feature/auth/controllers/auth_controller.dart';
import 'package:delifast_multivendor_driver/feature/splash/domain/services/splash_service_interface.dart';
import 'package:delifast_multivendor_driver/common/models/config_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:delifast_multivendor_driver/helper/route_helper.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  SplashController({required this.splashServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  final DateTime _currentTime = DateTime.now();
  DateTime get currentTime => _currentTime;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  Future<bool> getConfigData() async {
    ConfigModel? configModel = await splashServiceInterface.getConfigData();
    bool isSuccess = false;
    if (configModel != null) {
      _configModel = configModel;

      bool isMaintenanceMode = _configModel!.maintenanceMode!;
      String platform = 'deliveryman_app';
      bool isInMaintenance = isMaintenanceMode &&
          _configModel!.maintenanceModeData!.maintenanceSystemSetup!
              .contains(platform);

      if (isInMaintenance) {
        Get.offNamed(RouteHelper.getUpdateRoute(false));
      } else if ((Get.currentRoute.contains(RouteHelper.update) &&
              !isMaintenanceMode) ||
          (!isInMaintenance)) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          Get.offNamed(RouteHelper.getSignInRoute());
        }
      }

      isSuccess = true;
    } else {
      isSuccess = false;
    }
    update();
    return isSuccess;
  }

  Future<bool> initSharedData() async {
    return await splashServiceInterface.initSharedData();
  }

  Future<bool> removeSharedData() async {
    return await splashServiceInterface.removeSharedData();
  }

  void setLanguageIntro(bool intro) {
    splashServiceInterface.setLanguageIntro(intro);
  }

  bool showLanguageIntro() {
    return splashServiceInterface.showLanguageIntro();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  bool isRestaurantClosed() {
    DateTime open = DateFormat('hh:mm').parse('');
    DateTime close = DateFormat('hh:mm').parse('');
    DateTime openTime = DateTime(_currentTime.year, _currentTime.month,
        _currentTime.day, open.hour, open.minute);
    DateTime closeTime = DateTime(_currentTime.year, _currentTime.month,
        _currentTime.day, close.hour, close.minute);
    if (closeTime.isBefore(openTime)) {
      closeTime = closeTime.add(const Duration(days: 1));
    }
    if (_currentTime.isAfter(openTime) && _currentTime.isBefore(closeTime)) {
      return false;
    } else {
      return true;
    }
  }
}
