import 'package:flutter/material.dart';
import 'package:pooker_score/widgets/reflective_border.dart';

class GoldButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const GoldButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationTween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _elevationTween = Tween(begin: 4.0, end: 0.0)
        .animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _elevationTween,
        builder: (context, _) {
          return Transform.translate(
            offset: Offset(4.0 - _elevationTween.value, 4.0 - _elevationTween.value),
            child: ReflectiveBorder(
              borderRadius: 20,
              glow: true,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(offset: Offset(_elevationTween.value, _elevationTween.value), blurRadius: _elevationTween.value)
                ]
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                  overlayColor: Colors.transparent
                ),
                onPressed: () {
                  _controller.forward();
                  Future.delayed(Duration(milliseconds: 100), () {
                    _controller.reverse();
                  });
                  widget.onPressed?.call();
                },
                child: widget.child,
              ),
            ),
          );
        }
      ),
    );
  }
}
