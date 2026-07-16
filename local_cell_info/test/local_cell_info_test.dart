import 'package:flutter_test/flutter_test.dart';
import 'package:local_cell_info/local_cell_info.dart';
import 'package:local_cell_info/local_cell_info_platform_interface.dart';
import 'package:local_cell_info/local_cell_info_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLocalCellInfoPlatform
    with MockPlatformInterfaceMixin
    implements LocalCellInfoPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LocalCellInfoPlatform initialPlatform = LocalCellInfoPlatform.instance;

  test('$MethodChannelLocalCellInfo is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLocalCellInfo>());
  });

  test('getPlatformVersion', () async {
    LocalCellInfo localCellInfoPlugin = LocalCellInfo();
    MockLocalCellInfoPlatform fakePlatform = MockLocalCellInfoPlatform();
    LocalCellInfoPlatform.instance = fakePlatform;

    expect(await localCellInfoPlugin.getPlatformVersion(), '42');
  });
}
