import 'package:flutter/material.dart';
import 'package:loading_painter/loading_painter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final Animation<double> _doubleAnim = CurvedAnimation(
    parent: _animationController,
    curve: Curves.fastOutSlowIn,
  );

  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        Future.delayed(
          const Duration(milliseconds: 100),
          () => _animationController.forward(from: 0.0),
        );
      }
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          Center(
            child: CustomPaint(
              painter: LoadingPainter(_doubleAnim),
            ),
          ),

    );
  }
}
