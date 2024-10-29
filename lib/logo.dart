import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Logo extends StatefulWidget {
  const Logo({super.key});

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  late final _leftHandleTween = Tween<Offset>(
    begin: Offset.zero,
    end: Offset.zero,
  );
  late final _rightHandleTween = Tween<Offset>(
    begin: Offset.zero,
    end: Offset.zero,
  );

  late final _leftHandleAnimation = _leftHandleTween
      .chain(CurveTween(curve: Curves.ease))
      .animate(_controller);
  late final _rightHandleAnimation = _rightHandleTween
      .chain(CurveTween(curve: Curves.ease))
      .animate(_controller);

  final _leftHandleOffset = ValueNotifier(Offset.zero);
  final _rightHandleOffset = ValueNotifier(Offset.zero);

  Future<void>? _animationFuture;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      _leftHandleOffset.value = _leftHandleAnimation.value;
      _rightHandleOffset.value = _rightHandleAnimation.value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    _leftHandleOffset.dispose();
    _rightHandleOffset.dispose();

    _animationFuture = null;

    super.dispose();
  }

  void _onDragStart() {
    _animationFuture = null;
  }

  Future<void> _onDragEnd() async {
    late final Future<void> animationFuture;

    animationFuture = Future<void>.delayed(
      const Duration(milliseconds: 1500),
      () async {
        if (!mounted || _animationFuture != animationFuture) {
          return;
        }

        _leftHandleTween
          ..begin = _leftHandleOffset.value
          ..end = Offset.zero;

        _rightHandleTween
          ..begin = _rightHandleOffset.value
          ..end = Offset.zero;

        _controller.reset();
        await _controller.forward();

        _animationFuture = null;
      },
    );

    _animationFuture = animationFuture;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 22,
      child: _Logo(
        leftHandleOffset: _leftHandleOffset,
        leftHandle: _Handle(
          onDragStart: _onDragStart,
          onDragUpdate: (value) {
            _leftHandleOffset.value += value;
          },
          onDragEnd: _onDragEnd,
        ),
        rightHandleOffset: _rightHandleOffset,
        rightHandle: _Handle(
          onDragStart: _onDragStart,
          onDragUpdate: (value) {
            _rightHandleOffset.value += value;
          },
          onDragEnd: _onDragEnd,
        ),
      ),
    );
  }
}

class _Handle extends StatefulWidget {
  const _Handle({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final VoidCallback onDragStart;

  final ValueChanged<Offset> onDragUpdate;

  final VoidCallback onDragEnd;

  @override
  State<_Handle> createState() => _HandleState();
}

class _HandleState extends State<_Handle> {
  final _isHovered = ValueNotifier(false);
  final _isPressed = ValueNotifier(false);

  @override
  void dispose() {
    _isHovered.dispose();
    _isPressed.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 8,
      child: GestureDetector(
        onTapDown: (_) {
          _isPressed.value = true;
          widget.onDragStart();
        },
        onTapUp: (_) => _isPressed.value = false,
        onTapCancel: () => _isPressed.value = false,
        onPanStart: (_) {
          _isPressed.value = true;
          widget.onDragStart();
        },
        onPanUpdate: (details) => widget.onDragUpdate(details.delta),
        onPanEnd: (_) {
          _isHovered.value = false;
          _isPressed.value = false;
          widget.onDragEnd();
        },
        onPanCancel: widget.onDragEnd,
        child: MouseRegion(
          onEnter: (_) => _isHovered.value = true,
          onExit: (_) => _isHovered.value = false,
          child: Center(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFF666666),
                shape: BoxShape.circle,
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.ease,
                child: ListenableBuilder(
                  listenable: Listenable.merge([_isHovered, _isPressed]),
                  builder: (context, _) {
                    final isHovered = _isHovered.value;
                    final isPressed = _isPressed.value;

                    final dimension = isPressed ? 6.0 : (isHovered ? 8.0 : 4.0);

                    return SizedBox.square(dimension: dimension);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _LogoSlot { leftHandle, rightHandle }

class _Logo extends SlottedMultiChildRenderObjectWidget<_LogoSlot, RenderBox> {
  const _Logo({
    required this.leftHandleOffset,
    required this.leftHandle,
    required this.rightHandleOffset,
    required this.rightHandle,
  });

  final ValueNotifier<Offset> leftHandleOffset;

  final Widget leftHandle;

  final ValueNotifier<Offset> rightHandleOffset;

  final Widget rightHandle;

  @override
  Iterable<_LogoSlot> get slots => _LogoSlot.values;

  @override
  Widget? childForSlot(_LogoSlot slot) {
    return switch (slot) {
      _LogoSlot.leftHandle => leftHandle,
      _LogoSlot.rightHandle => rightHandle,
    };
  }

  @override
  _RenderLogo createRenderObject(BuildContext context) {
    return _RenderLogo(
      leftHandleOffset: leftHandleOffset,
      rightHandleOffset: rightHandleOffset,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderLogo renderObject,
  ) {
    renderObject
      ..leftHandleOffset = leftHandleOffset
      ..rightHandleOffset = rightHandleOffset;
  }
}

class _RenderLogo extends RenderBox
    with SlottedContainerRenderObjectMixin<_LogoSlot, RenderBox> {
  _RenderLogo({
    required ValueNotifier<Offset> leftHandleOffset,
    required ValueNotifier<Offset> rightHandleOffset,
  })  : _leftHandleOffset = leftHandleOffset,
        _rightHandleOffset = rightHandleOffset,
        super() {
    _leftHandleOffset.addListener(markNeedsLayout);
    _rightHandleOffset.addListener(markNeedsLayout);
  }

  ValueNotifier<Offset> get leftHandleOffset => _leftHandleOffset;
  ValueNotifier<Offset> _leftHandleOffset;
  set leftHandleOffset(ValueNotifier<Offset> value) {
    if (value == _leftHandleOffset) {
      return;
    }

    _leftHandleOffset.removeListener(markNeedsLayout);
    _leftHandleOffset = value;
    _leftHandleOffset.addListener(markNeedsLayout);

    markNeedsLayout();
  }

  ValueNotifier<Offset> get rightHandleOffset => _rightHandleOffset;
  ValueNotifier<Offset> _rightHandleOffset;
  set rightHandleOffset(ValueNotifier<Offset> value) {
    if (value == _rightHandleOffset) {
      return;
    }

    _rightHandleOffset.removeListener(markNeedsLayout);
    _rightHandleOffset = value;
    _rightHandleOffset.addListener(markNeedsLayout);

    markNeedsLayout();
  }

  @override
  bool get isRepaintBoundary => true;

  RenderBox get _leftHandle => childForSlot(_LogoSlot.leftHandle)!;
  RenderBox get _rightHandle => childForSlot(_LogoSlot.rightHandle)!;

  static BoxParentData _boxParentData(RenderBox box) =>
      box.parentData! as BoxParentData;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final child in children) {
      final parentData = _boxParentData(child);
      final isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (result, transformed) {
          return child.hitTest(result, position: transformed);
        },
      );

      if (isHit) {
        return true;
      }
    }

    return false;
  }

  Size _getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  @protected
  Size computeDryLayout(BoxConstraints constraints) {
    return _getSize(constraints);
  }

  @override
  void performLayout() {
    size = _getSize(constraints);

    final rect = (Offset.zero & size).deflate(4);

    _leftHandle.layout(
      constraints.loosen(),
      parentUsesSize: true,
    );

    final leftHandleSize = _leftHandle.size;
    _boxParentData(_leftHandle).offset = rect.topLeft
        .translate(
          -leftHandleSize.width / 2,
          -leftHandleSize.height / 2,
        )
        .translate(
          leftHandleOffset.value.dx,
          leftHandleOffset.value.dy,
        );

    _rightHandle.layout(
      constraints.loosen(),
      parentUsesSize: true,
    );

    final rightHandleSize = _rightHandle.size;
    _boxParentData(_rightHandle).offset = rect.bottomRight
        .translate(
          -rightHandleSize.width / 2,
          -rightHandleSize.height / 2,
        )
        .translate(
          rightHandleOffset.value.dx,
          rightHandleOffset.value.dy,
        );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = (offset & size).deflate(4);

    final leftHandleSize = _leftHandle.size;
    final leftHandlePosition = _boxParentData(_leftHandle).offset + offset;
    final leftHandleCenter = (leftHandlePosition & leftHandleSize).center;

    final rightHandleSize = _leftHandle.size;
    final rightHandlePosition = _boxParentData(_rightHandle).offset + offset;
    final rightHandleCenter = (rightHandlePosition & rightHandleSize).center;

    final greyPaint = Paint()
      ..color = const Color(0xFF666666)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    canvas
      ..drawLine(leftHandleCenter, rect.bottomLeft, greyPaint)
      ..drawLine(rect.topRight, rightHandleCenter, greyPaint);

    context
      ..paintChild(
        _leftHandle,
        _boxParentData(_leftHandle).offset + offset,
      )
      ..paintChild(
        _rightHandle,
        _boxParentData(_rightHandle).offset + offset,
      );

    final path = Path()
      ..moveTo(rect.left, rect.bottom)
      ..cubicTo(
        leftHandleCenter.dx,
        leftHandleCenter.dy,
        rightHandleCenter.dx,
        rightHandleCenter.dy,
        rect.right,
        rect.top,
      );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }
}
