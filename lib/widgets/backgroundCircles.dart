import 'package:flutter/material.dart';
import 'package:project_clean/utils/color_constants.dart';

class BackgroundCircles extends StatelessWidget {
  final Widget child;
  final Color circleColor;

  const BackgroundCircles({
    super.key,
    required this.child,
    this.circleColor = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        /// Top right large faded circle
        Positioned(
          top: -screenWidth * 0.3,
          right: -screenWidth * 0.35,
          child: Opacity(
            opacity: 0.15,
            child: Container(
              width: screenWidth * 0.7,
              height: screenWidth * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor.withOpacity(0.3),
              ),
            ),
          ),
        ),

        /// Bottom left large faded circle
        Positioned(
          bottom: -screenWidth * 0.3,
          left: -screenWidth * 0.35,
          child: Opacity(
            opacity: 0.15,
            child: Container(
              width: screenWidth * 0.7,
              height: screenWidth * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor.withOpacity(0.3),
              ),
            ),
          ),
        ),

        /// Bottom left small circle
        Positioned(
          bottom: -screenWidth * 0.15,
          left: -screenWidth * 0.1,
          child: Opacity(
            opacity: 0.25,
            child: Container(
              width: screenWidth * 0.4,
              height: screenWidth * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor.withOpacity(0.4),
              ),
            ),
          ),
        ),

        /// Top right small circle
        Positioned(
          top: -screenWidth * 0.15,
          right: -screenWidth * 0.1,
          child: Opacity(
            opacity: 0.25,
            child: Container(
              width: screenWidth * 0.4,
              height: screenWidth * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor.withOpacity(0.4),
              ),
            ),
          ),
        ),

        /// Main child widget
        child,
      ],
    );
  }
}

class ScreenCustomContainer extends StatelessWidget {
  Widget child;
  ScreenCustomContainer({super.key,required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,  // Ensures full width
      height: double.infinity,
      decoration:  ColorConstants().screenGradient,
      child: child,
    );
  }
}
