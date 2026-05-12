import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shelf/shelf.dart';

import '../../core/constants/app_constants.dart';
import '../responses/api_response.dart';

/// Returns the application information.
class AppInfoController {
  const AppInfoController();

  Future<Response> get(Request request) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = await _resolveDeviceInfo();

    return ApiResponse.success(
      message: 'App info retrieved successfully.',
      data: {
        'app': {
          'name': AppConstants.appName,
          'package': packageInfo.packageName,
          'version': packageInfo.version,
          'build': packageInfo.buildNumber,
        },
        'device': deviceInfo,
        'platform': Platform.operatingSystem,
        'platformVersion': Platform.operatingSystemVersion,
      },
    ).toShelfResponse();
  }

  Future<Map<String, String>> _resolveDeviceInfo() async {
    final plugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      return {
        'manufacturer': info.manufacturer,
        'model': info.model,
        'androidVersion': info.version.release,
        'sdk': info.version.sdkInt.toString(),
      };
    }

    if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return {
        'manufacturer': 'Apple',
        'model': info.utsname.machine,
        'iosVersion': info.systemVersion,
      };
    }

    return {'platform': 'unknown'};
  }
}
