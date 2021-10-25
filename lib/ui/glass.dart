import 'dart:ui';

import 'package:flutter/material.dart';

import 'utils.dart';

class FrostedGlassBox extends StatelessWidget {
  final double width, height;
  final Widget child;

  const FrostedGlassBox(
      {Key? key,
      required this.width,
      required this.height,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7.0,
                sigmaY: 7.0,
              ),
              child: SizedBox(
                  width: width, height: height, child: const Text(" ")),
            ),
            Opacity(
                opacity: 0.02,
                child: Image.asset(
                  img("noise.png"),
                  fit: BoxFit.cover,
                  width: width,
                  height: height,
                )),
            Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 30,
                        offset: const Offset(2, 2))
                  ],
                  borderRadius: BorderRadius.circular(20.0),
                  // border: Border.all(
                  //     color: Colors.white.withOpacity(0.1), width: 1.0),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.1),
                      ],
                      stops: const [
                        0.0,
                        1.0
                      ])),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class GlassButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool red;
  final bool loading;

  const GlassButton({
    Key? key,
    required this.child,
    required this.onTap,
    this.loading = false,
    this.red = false,
  }) : super(key: key);

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  void _onTap() {
    setState(() {
      _pressed = true;
    });
    widget.onTap();
    Future.delayed(const Duration(milliseconds: 300)).then((value) => {
          setState(() {
            _pressed = false;
          })
        });
  }

  ImageProvider _getBackgroundImage() {
    if (widget.red) {
      return Image.asset(img('red-gradient.png')).image;
    }
    return Image.asset(img('background.png')).image;
  }

  Widget _getChild() {
    if (_pressed) {
      return Opacity(
        opacity: 0.5,
        child: widget.child,
      );
    }
    return widget.child;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const CircularProgressIndicator();
    }
    return GestureDetector(
        onTap: _onTap,
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                    image: _getBackgroundImage(), fit: BoxFit.cover)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _getChild(),
            )));
  }
}
