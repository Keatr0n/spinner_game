import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum _GameObjectType {
  platform,
  hazard,
  goal,
}

class SpinnerGame extends StatefulWidget {
  SpinnerGame({
    this.size = 40,
    this.spinnerBackgroundColor,
    this.gameBackgroundColor,
    this.gamePrimaryColor,
  });
  final double size;
  final Color? spinnerBackgroundColor;
  final Color? gameBackgroundColor;
  final Color? gamePrimaryColor;
  @override
  _SpinnerGameState createState() => _SpinnerGameState();
}

class _SpinnerGameState extends State<SpinnerGame> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Container(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: 6,
        ),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => _Game(widget.gameBackgroundColor, widget.gamePrimaryColor),
          ),
        );
      },
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        primary: Colors.black38,
        padding: EdgeInsets.all(10),
        backgroundColor: widget.spinnerBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.size),
        ),
      ),
    );
  }
}

class _Game extends StatefulWidget {
  _Game(this.backgroundColor, this.primaryColor);
  final Color? backgroundColor;
  final Color? primaryColor;

  @override
  __GameState createState() => __GameState();
}

class __GameState extends State<_Game> {
  _Player? _player;

  int score = 0;

  List<_Platform> _platforms = [];
  List<_Hazard> _hazards = [];

  _Goal _goal = _Goal(x: 220, y: 180);

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  double get maxGameHeight => MediaQuery.of(context).size.height * 0.67;
  double get maxGameWidth => MediaQuery.of(context).size.width;

  void buildMap() {
    _platforms = [];
    _hazards = [];
    for (var i = 1; i <= 4; i++) {
      // might add hazards in later, but they make the game too hard at the moment
      //if (Random().nextBool() || _hazards.length > 2) {
      _platforms.add(_Platform(x: Random().nextInt(((maxGameWidth / 2) - 100).floor()).toDouble(), y: ((maxGameHeight / 4) * i) - 90));
      _platforms.add(_Platform(x: (maxGameWidth / 2) + Random().nextInt(((maxGameWidth / 2) - 100).floor()).toDouble(), y: ((maxGameHeight / 4) * i) - 90));
      // } else {
      //   if (Random().nextBool()) {
      //     _platforms.add(_Platform(x: Random().nextInt(((maxGameWidth / 2) - 100).floor()).toDouble(), y: ((maxGameHeight / 4) * i) - 90));
      //     _hazards.add(_Hazard(x: (maxGameWidth / 2) + Random().nextInt(((maxGameWidth / 2) - 100).floor()).toDouble(), y: ((maxGameHeight / 4) * i) - 90));
      //   } else {
      //     _hazards.add(_Hazard(x: Random().nextInt(((maxGameWidth / 2) - 100).floor()).toDouble(), y: ((maxGameHeight / 4) * i) - 90));
      //     _platforms.add(_Platform(x: (maxGameWidth / 2) + Random().nextInt(((maxGameWidth / 2) - 100).floor()).toDouble(), y: ((maxGameHeight / 4) * i) - 90));
      //   }
      // }
    }
    _goal = _Goal(x: Random().nextInt((maxGameWidth - 30).floor()).toDouble(), y: maxGameHeight - 70);
  }

  List<Widget> renderObjects(List<_GameObject> objects) {
    List<Widget> widgets = [];
    objects.forEach((object) {
      widgets.add(object.render());
    });
    return widgets;
  }

  Widget controlSurface() {
    return Container(
      width: screenWidth,
      height: screenHeight * 0.33,
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            right: 10,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Icon(Icons.exit_to_app),
              style: TextButton.styleFrom(
                primary: widget.primaryColor,
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Positioned(
            left: 50,
            top: 14,
            child: Material(
              child: Text(
                "SCORE: $score",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: widget.primaryColor,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 4,
                child: Container(
                  margin: EdgeInsets.all(30),
                  child: Text(
                    "JUMP",
                    style: TextStyle(
                      fontSize: 28,
                      color: widget.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              onTapDown: (_) {
                _player!.jump();
              },
            ),
          ),
          gameTicker != null
              ? Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    onPressed: () {
                      if (gameTicker!.isActive) {
                        gameTicker!.cancel();
                        if (mounted) setState(() {});
                      } else {
                        gameTicker = Timer.periodic(Duration(milliseconds: 10), (_) {
                          if (mounted) setState(() {});
                        });
                      }
                    },
                    child: Icon(gameTicker!.isActive ? Icons.pause : Icons.play_arrow),
                    style: TextButton.styleFrom(
                      primary: widget.primaryColor,
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget gameSurface() {
    if (_player != null)
      _player!.checkCollisions([_goal, ..._hazards, ..._platforms], () {
        score++;
        buildMap();
      });
    return Container(
      width: screenWidth,
      height: screenHeight * 0.67,
      color: widget.backgroundColor ?? Colors.grey.shade900,
      child: Stack(
        children: [
          _player != null ? _player!.render() : Container(),
          ...renderObjects(_platforms),
          ...renderObjects(_hazards),
          _goal.render(),
        ],
      ),
    );
  }

  Timer? gameTicker;

  @override
  void dispose() {
    if (gameTicker != null) gameTicker!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      _player = _Player(
        maxX: maxGameWidth,
        maxY: maxGameHeight,
        color: widget.primaryColor,
      );
      gameTicker = Timer.periodic(Duration(milliseconds: 10), (_) {
        if (mounted) setState(() {});
      });
      buildMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [gameSurface(), controlSurface()],
    );
  }
}

abstract class _GameObject {
  _GameObject({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
    required this.color,
  });

  final double x;
  final double y;
  final double width;
  final double height;
  final Color color;
  final _GameObjectType type;

  bool containsPoint(double px, double py) {
    if (px >= x && px <= x + width) {
      if (py >= y && py <= y + height) {
        return true;
      }
    }

    return false;
  }

  Widget render() {
    return Positioned(
      bottom: y,
      left: x,
      child: Container(
        width: width,
        height: height,
        color: color,
      ),
    );
  }
}

class _Platform extends _GameObject {
  _Platform({required double x, required double y, Color? color}) : super(height: 20, width: 100, type: _GameObjectType.platform, x: x, y: y, color: color ?? Colors.black);
}

class _Hazard extends _GameObject {
  _Hazard({required double x, required double y, Color? color}) : super(height: 20, width: 50, type: _GameObjectType.hazard, x: x, y: y, color: color ?? Colors.red);
}

class _Goal extends _GameObject {
  _Goal({required double x, required double y, Color? color}) : super(height: 30, width: 30, type: _GameObjectType.goal, x: x, y: y, color: color ?? Colors.green);
}

class _Player {
  _Player({required this.maxX, required this.maxY, this.color});

  final double maxX;
  final double maxY;
  final Color? color;

  double x = 0;
  double y = 0;

  double _verticalMomentum = 0;

  bool _isOnGround = true;

  bool _goingRight = true;

  double _calculateX() {
    if (x >= maxX - 30) {
      x = maxX - 30;
      _goingRight = false;
    }

    if (x <= 0) {
      x = 0;
      _goingRight = true;
    }

    if (_goingRight)
      x += 3;
    else
      x -= 3;

    return x;
  }

  double _calculateY() {
    if (y < 0) {
      y = 0;
      _isOnGround = true;
    }

    if (_isOnGround) {
      if (_verticalMomentum < 0) _verticalMomentum = 0;
    } else {
      _verticalMomentum -= 2;
    }

    y = y + (_verticalMomentum * 0.1);

    return y;
  }

  void reset() {
    x = 0;
    y = 0;

    _verticalMomentum = 0;
    _isOnGround = true;
    _goingRight = true;
  }

  void jump() {
    if (_isOnGround) {
      _verticalMomentum = 70;
      _isOnGround = false;
    }
  }

  void checkCollisions(List<_GameObject> objects, void Function() onGoal) {
    for (var i = 0; i < objects.length; i++) {
      if (objects[i].containsPoint(x, y - 1) || objects[i].containsPoint(x + 30, y - 1)) {
        if (objects[i].type == _GameObjectType.goal) {
          reset();
          onGoal();
          return;
        } else if (objects[i].type == _GameObjectType.hazard) {
          reset();
          return;
        } else {
          _isOnGround = true;
          return;
        }
      }
      if (objects[i].containsPoint(x, y + 31) || objects[i].containsPoint(x + 30, y + 31)) {
        if (objects[i].type == _GameObjectType.goal) {
          reset();
          onGoal();
          return;
        } else if (objects[i].type == _GameObjectType.hazard) {
          reset();
          return;
        } else {
          _verticalMomentum = 30;
          _isOnGround = true;
          return;
        }
      }
    }
    if (y > 0) _isOnGround = false;
  }

  Widget render() {
    return Positioned(
      bottom: _calculateY(),
      left: _calculateX(),
      child: Container(
        width: 30,
        height: 30,
        color: color ?? Colors.black,
      ),
    );
  }
}
