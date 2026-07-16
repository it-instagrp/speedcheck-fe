import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'local_cell_info_platform_interface.dart';

/// An implementation of [LocalCellInfoPlatform] that uses method channels.
class MethodChannelLocalCellInfo extends LocalCellInfoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('local_cell_info');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
