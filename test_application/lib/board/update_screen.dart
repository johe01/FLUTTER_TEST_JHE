import 'package:flutter/material.dart';
import 'package:test_application/models/board.dart';
import 'package:test_application/service/board_service.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  // state
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _writerController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String? id;
  final boardService = BoardService();
  late Future<Map<String, dynamic>?> _board;
  late Board board;

  @override
  void initState() {
    super.initState();

    // id 파라미터 넘겨받기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;

      if (args is String) {
        setState(() {
          id = args;
          print("id : $id");

          _getData(id!);
        });
      }
    });
  }

  // 게시글 조회 요청
  Future<void> _getData(String id) async {
    final data = await boardService.select(id!);
    if (data != null) {
      setState(() {
        board = Board.fromMap(data);
        _titleController.text = board.title ?? '';
        _contentController.text = board.content ?? '';
      });
    } else {
      print("데이터를 조회할 수 없습니다.");
    }
  }

  // 게시글 수정 처리
  Future<void> update() async {
    // 유효성 검사
    if (!_formkey.currentState!.validate()) {
      print("게시글 입력 정보가 유효하지 않습니다.");
      return;
    }

    // 게시글 객체 수정
    board.title = _titleController.text;
    board.content = _contentController.text;

    // 데이터 수정
    int result = await boardService.update(board);
    if (result > 0) {
      print("게시글 수정 성공!");
      // 게시글 목록으로 이동
      Navigator.pushReplacementNamed(context, "/board/list");
    } else {
      print("게시글 수정 실패!");
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
        title: Text("게시글 수정"),
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
              // 게시글 데이터 수정 처리
              update();
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Color.fromARGB(255, 152, 246, 45),
                foregroundColor: Colors.blueAccent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // 테두리 곡률 제거
                )),
            child: const Text("수정하기"),
          ),
        ),
      ),
    );
  }
}
