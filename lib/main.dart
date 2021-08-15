import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Draggable;

void main() {
  runApp(
    MaterialApp(
      home: SafeArea(child: GameWidget(game: BreakoutGame())),
    ),
  );
}

final _paintBorder = BasicPalette.white.paint()..style = PaintingStyle.stroke;
final _paintWhite = BasicPalette.white.paint();

final _paintGreen = BasicPalette.green.paint()..blendMode = BlendMode.lighten;
final _paintRed = BasicPalette.red.paint()..blendMode = BlendMode.lighten;
final _paintBlue = BasicPalette.blue.paint()..blendMode = BlendMode.lighten;

class Platform extends PositionComponent
    with HasGameRef<BreakoutGame>, Draggable {
  @override
  Future<void>? onLoad() {
    anchor = Anchor.topCenter;
    x = gameRef.size.x / 2;
    y = gameRef.size.y - 100;
    size = Vector2(100, 20);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paintWhite);
  }

  late Vector2 previousPosition = position;
  Vector2 averageVelocity = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);
    if (dt != 0) {
      averageVelocity = (position - previousPosition) / dt;
      previousPosition = position.clone();
    }
  }

  double? dragX;

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    x += info.delta.game.x;
    if (gameRef.ball.isReset) {
      gameRef.ball.launch();
    }
    return super.onDragUpdate(pointerId, info);
  }
}

class Bg extends Component with HasGameRef<BreakoutGame> {
  @override
  void render(Canvas c) {
    c.drawRect(gameRef.size.toRect().deflate(1.0), _paintBorder);
    super.render(c);
  }

  @override
  bool get isHud => true;

  @override
  int get priority => -1;
}

class Ball extends PositionComponent with HasGameRef<BreakoutGame> {
  static const radius = 10.0;
  static const speed = 500.0;

  bool isReset = true;
  Vector2 velocity = Vector2.zero();

  @override
  Future<void>? onLoad() {
    anchor = Anchor.center;
    position = gameRef.platform.position - Vector2(0, radius);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset.zero, radius, _paintWhite);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final ds = velocity * dt;
    position += ds;
  }

  void launch() {
    velocity = Vector2(0.75, -1) * speed;
    isReset = false;
  }
}

class BreakoutGame extends BaseGame with HasDraggableComponents {
  late Platform platform;
  late Ball ball;
  @override
  Future<void> onLoad() async {
    camera.defaultShakeIntensity = 5;
    // viewport = FixedResolutionViewport(Vector2(640, 1280));
    setup();
  }

  void setup() {
    add(Bg());
    add(platform = Platform());
    add(ball = Ball());
    super.onLoad();
  }
}
