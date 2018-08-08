import 'package:flutter/material.dart';

/**
 * 原型的图片组件
 */
class CircleImage extends StatelessWidget {
  final String renderUrl;

  CircleImage(this.renderUrl);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: new DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(renderUrl ?? ''),
        ),
      ),
    );
  }
}
