import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedFab extends StatefulWidget {
  final VoidCallback onClick;

  const AnimatedFab({required this.onClick});

  @override
  _AnimatedFabState createState() => new _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  final double expandedSize = 180.0;
  final double hiddenSize = 20.0;

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 200));
    _colorAnimation = ColorTween(begin: Colors.pink, end: Colors.pink[800])
        .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      width: expandedSize,
      height: expandedSize,
      child: new AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget? child) {
          return new Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _buildExpandedBackground(),
              _buildOption(Icons.check_circle, 0.0),
              _buildOption(Icons.flash_on, -math.pi / 3),
              _buildOption(Icons.access_time, -2 * math.pi / 3),
              _buildOption(Icons.error_outline, math.pi),
              _buildFabCore(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOption(IconData icon, double angle) {
    if (_animationController.isDismissed) {
      return Container();
    }
    double iconSize = 0.0;
    if (_animationController.value > 0.8) {
      iconSize = 26.0 * (_animationController.value - 0.8) * 5;
    }
    return new Transform.rotate(
      angle: angle,
      child: new Align(
        alignment: Alignment.topCenter,
        child: new Padding(
          padding: new EdgeInsets.only(top: 8.0),
          child: new IconButton(
            onPressed: _onIconClick,
            icon: new Transform.rotate(
              angle: -angle,
              child: new Icon(
                icon,
                color: Colors.white,
              ),
            ),
            iconSize: iconSize,
            alignment: Alignment.center,
            padding: new EdgeInsets.all(0.0),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedBackground() {
    // double size =
    //     hiddenSize + (expandedSize - hiddenSize) * _animationController.value;
    Animation size = Tween(begin: hiddenSize, end: expandedSize)
        .animate(_animationController);
    return new Container(
      height: size.value,
      width: size.value,
      decoration: new BoxDecoration(shape: BoxShape.circle, color: Colors.pink),
    );
  }

  Widget _buildFabCore() {
    double scaleFactor = 2 * (_animationController.value - 0.5).abs();
    return new FloatingActionButton(
      onPressed: _onFabTap,
      child: new Transform(
        alignment: Alignment.center,
        transform: new Matrix4.identity()..scale(1.0, scaleFactor),
        child: new Icon(
          _animationController.value > 0.5 ? Icons.close : Icons.filter_list,
          color: Colors.white,
          size: 26.0,
        ),
      ),
      backgroundColor: _colorAnimation.value,
    );
  }

  open() {
    _animationController.forward();
  }

  close() {
    _animationController.reverse();
  }

  _onFabTap() {
    if (_animationController.isDismissed) {
      open();
    } else if (_animationController.isCompleted) {
      close();
    }
  }

  _onIconClick() {
    widget.onClick();
    close();
  }
}
