import 'package:flutter/material.dart';
import 'package:test_application/board/insert_screen.dart';
import 'package:test_application/board/list_screen.dart';
import 'package:test_application/board/read_screen.dart';
import 'package:test_application/board/update_screen.dart';
import 'package:test_application/database_helper.dart';
import 'package:test_application/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 프레임워크 초기화

  // 데이터베이스 초기화 호출
  try {
    await DatabaseHelper.instance.database;
    print("데이터베이스 초기화 성공!"); // DB 초기화 성공 시 출력
  } catch (e) {
    print("데이터베이스 초기화 실패! : $e"); // DB 초기화 실패 시 출력
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'test app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      initialRoute: '/main',
      routes: {
        '/main': (context) => const MainScreen(),
        '/board/list': (context) => const ListScreen(),
        '/board/read': (context) => const ReadScreen(),
        '/board/insert': (context) => const InsertScreen(),
        '/board/update': (context) => const UpdateScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
