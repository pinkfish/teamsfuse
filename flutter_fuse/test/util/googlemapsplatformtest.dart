import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGoogleMapsFlutterPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GoogleMapsFlutterPlatform {}

class _MockStream<T> extends Mock implements Stream<T> {}

typedef _CreationCallback = void Function(int);

// Installs test mocks on the platform
void setupGoogleMapsMock(MockGoogleMapsFlutterPlatform platform) {
  var done = Set<_CreationCallback>();
  // Used to create the view of the map...
  when(platform.buildView(any, any, any)).thenAnswer((realInvocation) {
    // Call the onPlatformViewCreated callback so the controller gets created.
    _CreationCallback onPlatformViewCreatedCb =
        realInvocation.positionalArguments[2];
    if (!done.contains(onPlatformViewCreatedCb)) {
      done.add(onPlatformViewCreatedCb);
      onPlatformViewCreatedCb.call(0);
    }
    return Container();
  });
  // Used to create the Controller
  when(platform.onCameraIdle(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<CameraIdleEvent>());
  when(platform.onCameraMove(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<CameraMoveEvent>());
  when(platform.onCameraMoveStarted(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<CameraMoveStartedEvent>());
  when(platform.onCircleTap(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<CircleTapEvent>());
  when(platform.onInfoWindowTap(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<InfoWindowTapEvent>());
  when(platform.onLongPress(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<MapLongPressEvent>());
  when(platform.onMarkerDragEnd(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<MarkerDragEndEvent>());
  when(platform.onMarkerTap(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<MarkerTapEvent>());
  when(platform.onPolygonTap(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<PolygonTapEvent>());
  when(platform.onPolylineTap(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<PolylineTapEvent>());
  when(platform.onTap(mapId: anyNamed('mapId')))
      .thenAnswer((_) => _MockStream<MapTapEvent>());
}
