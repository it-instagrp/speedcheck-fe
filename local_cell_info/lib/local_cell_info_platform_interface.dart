import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'local_cell_info_method_channel.dart';

abstract class LocalCellInfoPlatform extends PlatformInterface {
  /// Constructs a LocalCellInfoPlatform.
  LocalCellInfoPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocalCellInfoPlatform _instance = MethodChannelLocalCellInfo();

  /// The default instance of [LocalCellInfoPlatform] to use.
  ///
  /// Defaults to [MethodChannelLocalCellInfo].
  static LocalCellInfoPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LocalCellInfoPlatform] when
  /// they register themselves.
  static set instance(LocalCellInfoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
