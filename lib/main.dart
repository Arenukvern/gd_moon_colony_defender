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

class Crate extends PositionComponent {
  static final _paintrow1 = Paint()..color = Color(0xFFE22349);
  static final _paintrow2 = Paint()..color = Color(0xFFFF2600);
  static final _paintrow3 = Paint()..color = Color(0xFFFF5300);
  static final _paintrow4 = Paint()..color = Color(0xFFFFC100);
  static final _paints = [_paintrow1, _paintrow2, _paintrow3, _paintrow4];
  static final crateSize = Vector2(100, 26);

  final int rowIndex;

  Crate({required Vector2 position, required this.rowIndex}) {
    this.position = position;
    size = crateSize;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paints[rowIndex ~/ 2]);
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

    if (position.x < 0) {
      position.x = 0;
      velocity.multiply(Vector2(-1, 1));
      gameRef.camera.shake(intensity: .15);
    } else if (position.x > gameRef.size.x) {
      position.x = gameRef.size.x;
      velocity.multiply(Vector2(-1, 1));
      gameRef.camera.shake(intensity: .15);
    } else if (position.y < 0) {
      position.y = 0;
      velocity.multiply(Vector2(1, -1));
      gameRef.camera.shake(intensity: .15);
    } else if (position.y > gameRef.size.y) {
      gameRef.onLose();
    } else {
      final previousRect = (position - ds) & size;
      final effectiveCollisionBounds = toRect().expandToInclude(previousRect);
      final intersects =
          gameRef.platform.toRect().intersect(effectiveCollisionBounds);
      if (!intersects.isEmpty) {
        position.y = gameRef.platform.position.y - radius;
        velocity.multiply(Vector2(1, -1));
        velocity += gameRef.platform.averageVelocity / 10;
      } else {
        final boxes = gameRef.components.whereType<Crate>();
        bool firstBox = true;
        for (final box in boxes) {
          final collision = box.toRect().intersect(effectiveCollisionBounds);
          if (!collision.isEmpty) {
            if (firstBox) {
              velocity.multiply(Vector2(1, -1));
              firstBox = false;
            }
            box.remove();
          }
        }
      }
    }
  }

  void launch() {
    velocity = Vector2(.75, -1) * speed;
    isReset = false;
  }
}

class BreakoutGame extends BaseGame with HasDraggableComponents {
  late Platform platform;
  late Ball ball;
  @override
  Future<void> onLoad() async {
    camera.defaultShakeIntensity = 5;
    viewport = FixedResolutionViewport(Vector2(640, 1280));
    setup();
    super.onLoad();
  }

  void onLose() {}
  void setup() {
    add(Bg());
    add(platform = Platform());
    add(ball = Ball());
    createCrates();
  }

  void createCrates() {
    final grid = Vector2(5, 8);
    final margin = Vector2(5, 5);

    final unitWidth = Crate.crateSize + margin;
    final totalDimensions = grid.clone()..multiply(unitWidth);
    final start = ((size - totalDimensions) / 2)..y = 100.0;

    for (var i = 0; i < grid.x; i++) {
      for (var j = 0; j < grid.y; j++) {
        final position =
            start + (Vector2Extension.fromInts(i, j)..multiply(unitWidth));
        add(Crate(position: position, rowIndex: j));
      }
    }
  }
}
