import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController _controller =PageController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            children: [
              Container(
                color: Colors.teal[400],
              ),
              Container(
                color: Colors.teal[500],
              ),
              Container(
                color: Colors.teal[600],
              ),
            ],
          ),
          Container(
            alignment:Alignment(0,0.75) ,
            child: SmoothPageIndicator(controller: _controller, count: 3))
        ],
      ),
    );
  }
}
