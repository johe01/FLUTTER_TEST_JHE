import 'package:flutter/material.dart';
import 'package:test_application/models/board.dart';
import 'package:test_application/service/board_service.dart';

class InsertScreen extends StatefulWidget {
  const InsertScreen({super.key});

  @override
  State<InsertScreen> createState() => _InsertScreenState();
}

class _InsertScreenState extends State<InsertScreen> {
  // state
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final boardService = BoardService();

  // 게시글 등록 처리
  Future<void> insert() async {
    // 유효성 검사
    if (!_formkey.currentState!.validate()) {
      print("게시글 입력 정보가 유효하지 않습니다.");
      return;
    }

    // 게시글 객체 생성
    Board board =
        Board(title: _titleController.text, content: _contentController.text);

    print("board - id : ${board.id}");

    // 데이터 등록
    int result = await boardService.insert(board);
    if (result > 0) {
      print("게시글 등록 성공!");
      // 게시글 목록으로 이동
      Navigator.pushReplacementNamed(context, "/board/list");
    } else {
      print("게시글 등록 실패!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, "/board/list");
          },
          child: Icon(Icons.arrow_back),
        ),
        title: Text("게시글 등록"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '제목'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "제목을 입력하세요.";
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10.0,
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                    labelText: '내용', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "내용을 입력하세요.";
                  }
                  return null;
                },
                maxLines: 5, // 여러줄 입력 설정 (5줄)
                keyboardType: TextInputType.multiline, // 여러줄 입력 설정
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        height: 60,
        color: Colors.white,
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              // 게시글 데이터 등록 처리
              insert();
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Color.fromARGB(255, 152, 246, 45),
                foregroundColor: Colors.blueAccent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // 테두리 곡률 제거
                )),
            child: const Text("등록하기"),
          ),
        ),
      ),
    );
  }
}
