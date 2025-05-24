import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/beacon_provider.dart';
import 'map_painter.dart'; // import the painter here

class MapWidget extends StatefulWidget {
  final double currentX;
  final double currentY;

  const MapWidget({super.key, required this.currentX, required this.currentY});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late TransformationController _controller;
  final double restrictionUnits =
      200.0; // Restriction boundary in logical units
  static const double scale = 50.0; // same scale as painter
  bool _initialSetupDone = false;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  void _clampTransformation() {
    final matrix = _controller.value;

    final double currentScale = matrix.getMaxScaleOnAxis();

    double translateX = matrix[12];
    double translateY = matrix[13];

    final double maxTranslateX = restrictionUnits * scale * currentScale;
    final double maxTranslateY = restrictionUnits * scale * currentScale;

    translateX = translateX.clamp(-maxTranslateX, maxTranslateX);
    translateY = translateY.clamp(-maxTranslateY, maxTranslateY);

    _controller.value = Matrix4.identity()
      ..scale(currentScale)
      ..translate(translateX / currentScale, translateY / currentScale);
  }

  void _setupInitialTransform() {
    final beacons = Provider.of<BeaconProvider>(context, listen: false).beacons;
    if (beacons.isEmpty) return;

    final xVals = beacons.values.map((b) => b.x).toList();
    final yVals = beacons.values.map((b) => b.y).toList();

    final minX = xVals.reduce((a, b) => a < b ? a : b);
    final maxX = xVals.reduce((a, b) => a > b ? a : b);
    final minY = yVals.reduce((a, b) => a < b ? a : b);
    final maxY = yVals.reduce((a, b) => a > b ? a : b);

    const marginUnits = 3.0;

    final totalWidth =
        (maxX - minX + marginUnits * 2 + restrictionUnits * 2) * scale;
    final totalHeight =
        (maxY - minY + marginUnits * 2 + restrictionUnits * 2) * scale;

    final screenSize = MediaQuery.of(context).size;
    final scaleX = screenSize.width / totalWidth;
    final scaleY = screenSize.height / totalHeight;
    final fitScale = scaleX < scaleY ? scaleX : scaleY;

    // Compose transform matrix: scale then translate to fit and center beacons
    _controller.value = Matrix4.identity()
      ..scale(fitScale)
      ..translate(
        -((minX - marginUnits - restrictionUnits) * scale),
        -((minY - marginUnits - restrictionUnits) * scale),
      );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Setup initial transform only once after first frame
    if (!_initialSetupDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _setupInitialTransform();
          _initialSetupDone = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final beacons = Provider.of<BeaconProvider>(context).beacons;

    final xVals = beacons.values.map((b) => b.x).toList();
    final yVals = beacons.values.map((b) => b.y).toList();

    if (xVals.isEmpty || yVals.isEmpty) {
      return const Center(child: Text("No beacons to show"));
    }

    final screenSize = MediaQuery.of(context).size;

    final canvasWidth = screenSize.width + restrictionUnits * 2 * scale;
    final canvasHeight = screenSize.height + restrictionUnits * 2 * scale;

    return InteractiveViewer(
      transformationController: _controller,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(10000),
      minScale: 0.3,
      maxScale: 5.0,
      onInteractionEnd: (_) => _clampTransformation(),
      onInteractionUpdate: (_) => _clampTransformation(),
      child: Container(
        width: canvasWidth,
        height: canvasHeight,
        color: Colors.grey.shade300,
        child: CustomPaint(
          painter: MapPainter(
            beacons: beacons,
            currentX: widget.currentX,
            currentY: widget.currentY,
            minX: xVals.reduce((a, b) => a < b ? a : b) - restrictionUnits,
            minY: yVals.reduce((a, b) => a < b ? a : b) - restrictionUnits,
          ),
        ),
      ),
    );
  }
}
