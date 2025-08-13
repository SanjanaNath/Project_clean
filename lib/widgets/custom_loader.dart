import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class OnlyLoader extends StatelessWidget {
  final Color? color;
  final double? radius;
  const OnlyLoader({super.key, this.color, this.radius});

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(
      radius: radius ?? 12,
      color: color,
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    this.message,
    this.heightFactor,
    this.widthFactor,
    this.alignment,
    this.color,
    this.backgroundColor,
    required this.buildContext,
  })  : assert(widthFactor == null || widthFactor >= 0.0),
        assert(heightFactor == null || heightFactor >= 0.0);

  final BuildContext buildContext;
  final String? message;
  final double? heightFactor;
  final double? widthFactor;
  final Color? color;
  final Color? backgroundColor;
  final Alignment? alignment;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoActivityIndicator(
              radius: 12,
              color: color ?? Theme.of(buildContext).primaryColor,
            ),
          ),
          Text(
            message ?? 'Loading Data...',
            style: Theme.of(buildContext).textTheme.titleMedium?.copyWith(
              color: color ?? Theme.of(buildContext).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}


Future<void> customLoader(BuildContext context) {
  Size size =MediaQuery.of(context).size;
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: OutlineInputBorder(
          borderSide: const BorderSide(
              color: Colors.blue
          ),
          borderRadius: BorderRadius.circular(4,),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.discreteCircle(
              color: Colors.blue.shade700,
              size:size.height*0.03 ,
            ),
            Gap(
              width: size.width*0.03,
            ),
            const Text(
          'Please wait....',
              style: TextStyle(fontSize: 20,),
            )
          ],
        ),
      );
    },
  );
}

class Gap extends StatelessWidget {
  final double? height;
  final double? width;
  const Gap({
    this.height,
    this.width,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
    );
  }
}