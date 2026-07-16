
import 'local_cell_info_platform_interface.dart';

class LocalCellInfo {
  Future<String?> getPlatformVersion() {
    return LocalCellInfoPlatform.instance.getPlatformVersion();
  }
}
