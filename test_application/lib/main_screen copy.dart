import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("메인 화면"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/board/list");
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 152, 246, 45),
              foregroundColor: Colors.blueAccent),
          child: Text("게시글 목록"),
        ),
      ),
    );
  }
}
