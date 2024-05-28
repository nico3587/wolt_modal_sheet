import 'package:coffee_maker_navigator_2/domain/add_water/add_water_service.dart';
import 'package:coffee_maker_navigator_2/domain/add_water/entities/water_acceptance_result.dart';
import 'package:coffee_maker_navigator_2/domain/add_water/entities/water_source.dart';
import 'package:coffee_maker_navigator_2/domain/orders/entities/coffee_maker_step.dart';
import 'package:coffee_maker_navigator_2/domain/orders/orders_service.dart';
import 'package:flutter/foundation.dart';

class AddWaterViewModel extends ChangeNotifier {
  final AddWaterService _addWaterService;
  final OrdersService _ordersService;
  String _waterQuantityInMl = '';
  String _waterTemperatureInC = '';
  WaterSource _waterSource = WaterSource.tap;
  late String _orderId;

  final ValueNotifier<bool> isReadyToAddWater = ValueNotifier(false);
  final ValueNotifier<String?> _errorMessage = ValueNotifier(null);

  AddWaterViewModel({
    required AddWaterService addWaterService,
    required OrdersService ordersService,
  })  : _addWaterService = addWaterService,
        _ordersService = ordersService;

  void onInit(String orderId) {
    _orderId = orderId;
  }

  void onWaterQuantityUpdated(String value) {
    _waterQuantityInMl = value;
  }

  void onWaterTemperatureUpdated(String value) {
    _waterTemperatureInC = value;
  }

  void onWaterSourceUpdated(WaterSource value) {
    _waterSource = value;
  }

  void checkWaterAcceptance() {
    double? quantity = double.tryParse(_waterQuantityInMl);
    double? temperature = double.tryParse(_waterTemperatureInC);

    if (quantity == null) {
      _errorMessage.value = WaterQuantityFailure().message;
    } else if (temperature == null) {
      _errorMessage.value = 'Invalid temperature value.';
    }

    final result = _addWaterService.checkWaterAcceptance(
      waterQuantityInMl: quantity!,
      waterTemperatureInC: temperature!,
      waterSource: _waterSource,
      currentDate: DateTime.now(),
    );
    if (!result.isAccepted) {
      _errorMessage.value = result.message;
    }
  }

  @override
  void dispose() {
    isReadyToAddWater.dispose();
    _errorMessage.dispose();
    super.dispose();
  }

  ValueListenable<bool> get isAddWaterButtonEnabled => isReadyToAddWater;

  ValueListenable<String?> get errorMessage => _errorMessage;

  // Method to check the validity of the current state
  void checkValidity() {
    _errorMessage.value = null; // Clear previous errors
    double? quantity = double.tryParse(_waterQuantityInMl);
    double? temperature = double.tryParse(_waterTemperatureInC);

    if (quantity == null || temperature == null) {
      _errorMessage.value =
          "Invalid numeric values for quantity or temperature.";
      isReadyToAddWater.value = false;
      return;
    }

    final result = _addWaterService.checkWaterAcceptance(
      waterQuantityInMl: quantity,
      waterTemperatureInC: temperature,
      waterSource: _waterSource,
      currentDate: DateTime.now(),
    );
    isReadyToAddWater.value = result.isAccepted;
    if (!result.isAccepted) {
      _errorMessage.value = result.message;
    }
  }

  void addWater() {
    _ordersService.updateOrder(_orderId, CoffeeMakerStep.ready);
  }
}
