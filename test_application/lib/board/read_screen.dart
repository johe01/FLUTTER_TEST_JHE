import 'package:flutter/material.dart';
import 'package:test_application/models/board.dart';
import 'package:test_application/service/board_service.dart';

class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  // state
  String? id; // 게시글 id
  final boardService = BoardService(); // 게시글 서비스
  late Future<Map<String, dynamic>?> _board; // 게시글 데이터

  // 팝업메뉴 아이템 (수정하기, 삭제하기)
  final List<PopupMenuEntry<String>> _popupMenuItems = [
    const PopupMenuItem(
        value: 'update',
        child: Row(
          children: [
            Icon(Icons.edit, color: Colors.black),
            SizedBox(
              width: 8,
            ),
            Text("수정하기")
          ],
        )),
    const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, color: Colors.black),
            SizedBox(
              width: 8,
            ),
            Text("삭제하기")
          ],
        )),
  ];

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

          // 게시글 조회 요청
          _board = boardService.select(id!);
        });
      }
    });
  }

  // ❓ 삭제 확인 (정말로 삭제하시겠습니까?)
  Future<bool> _confirm() async {
    bool result = false;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("삭제 확인"),
            content: Text("정말로 삭제하시겠습니까?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("삭제")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("취소")),
            ],
          );
        }).then((value) {
      // [삭제], [취소] 클릭 후
      result = value ?? false;
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // id 파라미터 넘겨받기
    // String? id = ModalRoute.of(context)!.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, "/board/list");
          },
          child: Icon(Icons.arrow_back),
        ),
        title: Text("게시글 조회"),
        actions: [
          PopupMenuButton(
              onSelected: (String value) async {
                // 수정하기 클릭
                if (value == 'update') {
                  // 수정화면으로 이동
                  Navigator.pushReplacementNamed(context, "/board/update",
                      arguments: id);
                }
                // 삭제하기 클릭
                else if (value == 'delete') {
                  // 삭제 확인 -> 삭제 처리
                  bool check = await _confirm();
                  if (check) {
                    // 삭제 처리
                    int result = await boardService.delete(id!);
                    if (result > 0) {
                      // Alert 닫기
                      Navigator.pop(context); // Alert 닫기
                      // 게시글 목록으로 이동
                      Navigator.pushReplacementNamed(context, "/board/list");
                    }
                  }
                }
              },
              icon: const Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) {
                return _popupMenuItems;
              })
        ],
      ),
      body: Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 10),
          child: id == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : FutureBuilder(
                  future: _board,
                  builder: (context, snapshot) {
                    // 로딩 중
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    // 에러
                    else if (snapshot.hasError) {
                      return Center(
                        child: Text("게시글 조회 중, 에러"),
                      );
                    }

                    // 데이터 없음
                    else if (!snapshot.hasError && snapshot.data!.isEmpty) {
                      return Center(
                        child: Text("데이터를 조회할 수 없습니다."),
                      );
                    }
                    // 데이터 있음
                    else {
                      Board board =
                          Board.fromMap(snapshot.data!); // map -> board
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.article),
                              title: Text(board.title ?? ''),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            padding: const EdgeInsets.all(12.0),
                            width: double.infinity,
                            height: 320.0,
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.3), // 그림자 색상, 투명도
                                    spreadRadius: 2, // 그림자 확산 정도
                                    blurRadius: 8, // 그림자 흐림 정도
                                    offset: const Offset(4, 4), // 그림자 위치 (x, y)
                                  )
                                ],
                                borderRadius:
                                    BorderRadius.circular(8)), // 테두리 곡률
                            child: SingleChildScrollView(
                              child: Text(board.content ?? ''),
                            ),
                          )
                        ],
                      );
                    }
                  })),
    );
  }
}
