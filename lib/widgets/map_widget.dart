import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/beacon_provider.dart';
import 'map_painter.dart';

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
      100.0; // Restriction boundary in logical units
  static const double scale = 50.0; // same scale as painter

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  void _clampTransformation() {
    final matrix = _controller.value;

    // Extract scale & translation
    final double currentScale = matrix.getMaxScaleOnAxis();

    double translateX = matrix[12];
    double translateY = matrix[13];

    // Calculate max translation in pixels for restrictionUnits at current scale
    final double maxTranslateX = restrictionUnits * scale * currentScale;
    final double maxTranslateY = restrictionUnits * scale * currentScale;

    // Clamp translation to ±maxTranslateX/Y
    translateX = translateX.clamp(-maxTranslateX, maxTranslateX);
    translateY = translateY.clamp(-maxTranslateY, maxTranslateY);

    // Update matrix with clamped translation
    _controller.value = Matrix4.identity()
      ..scale(currentScale)
      ..translate(translateX / currentScale, translateY / currentScale);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final screenSize = MediaQuery.of(context).size;

    // You can tweak this initial scale if you want zoomed in/out on init
    const double initialScale = 1.0;

    // Center current point on screen
    final double translateX =
        screenSize.width / 2 -
        widget.currentX * scale * initialScale -
        50 * scale;
    final double translateY =
        screenSize.height / 2 -
        widget.currentY * scale * initialScale -
        50 * scale;

    _controller.value = Matrix4.identity()
      ..scale(initialScale)
      ..translate(translateX / initialScale, translateY / initialScale);
  }

  @override
  Widget build(BuildContext context) {
    final beacons = Provider.of<BeaconProvider>(context).beacons;

    final xVals = beacons.values.map((b) => b.x).toList();
    final yVals = beacons.values.map((b) => b.y).toList();

    // Add current position for bounds calculation if needed
    xVals.add(widget.currentX);
    yVals.add(widget.currentY);

    if (xVals.isEmpty || yVals.isEmpty) {
      return const Center(child: Text("No beacons to show"));
    }

    final screenSize = MediaQuery.of(context).size;

    // Canvas size with extra padding for restrictions (optional)
    final canvasWidth = screenSize.width + restrictionUnits * 2 * scale;
    final canvasHeight = screenSize.height + restrictionUnits * 2 * scale;

    return InteractiveViewer(
      transformationController: _controller,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(50),
      minScale: 0.4,
      maxScale: 6.0,
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
            minX: -50, // zero so we paint raw coords
            minY: -50,
          ),
        ),
      ),
    );
  }
}
