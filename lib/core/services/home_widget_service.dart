import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String _appGroupId = 'group.com.safesignal.sos';
  static const String _androidWidgetName = 'SosWidgetProvider';
  static const String _iOSWidgetName = 'SosWidget';

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> updateWidget({
    required bool isActive,
    required String scenarioName,
  }) async {
    await HomeWidget.saveWidgetData('is_active', isActive);
    await HomeWidget.saveWidgetData('scenario_name', scenarioName);
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      iOSName: _iOSWidgetName,
    );
  }

  static Future<void> registerInteractivityCallback(
    void Function(Uri?) callback,
  ) async {
    HomeWidget.widgetClicked.listen(callback);
  }
}
