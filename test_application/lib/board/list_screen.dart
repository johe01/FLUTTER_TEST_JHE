import 'package:flutter/material.dart';
import 'package:test_application/models/board.dart';
import 'package:test_application/service/board_service.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  // state
  late Future<List<Map<String, dynamic>>> _boardList;
  final boardService = BoardService();

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
  void initState() {
    super.initState();
    // 게시글 목록 요청
    _boardList = boardService.list();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("게시글 목록"),
      ),
      body: Container(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
          child:
              // FutureBuilder : 비동기 방식으로 데이터를 가져오는 객체
              FutureBuilder(
                  future: _boardList, // 비동기 데이터
                  builder: (context, snapshot) {
                    // 로딩 중
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    // 에러
                    else if (snapshot.hasError) {
                      return Center(child: Text("데이터 조회 시, 에러 발생"));
                    }
                    // 데이터 없음
                    else if (!snapshot.hasError && snapshot.data!.isEmpty) {
                      return Center(child: Text("조회된 데이터가 없습니다."));
                    }
                    // 데이터 있음
                    else {
                      List<Map<String, dynamic>> boardData = snapshot.data!;
                      return ListView.builder(
                        itemCount: boardData.length,
                        itemBuilder: (context, index) {
                          final board = Board.fromMap(boardData[index]);
                          return GestureDetector(
                            onTap: () {
                              // 게시글 조회 화면으로 이동
                              Navigator.pushReplacementNamed(
                                  context, "/board/read",
                                  arguments: board.id);
                            },
                            child: Card(
                              child: ListTile(
                                leading: Text(board.no.toString()),
                                title: Text(board.title ?? ''),
                                trailing: PopupMenuButton(
                                    onSelected: (String value) async {
                                      // 수정하기 클릭
                                      if (value == 'update') {
                                        // 수정화면으로 이동
                                        Navigator.pushReplacementNamed(
                                            context, "/board/update",
                                            arguments: board.id);
                                      }
                                      // 삭제하기 클릭
                                      else if (value == 'delete') {
                                        // 삭제 확인 -> 삭제 처리
                                        bool check = await _confirm();
                                        if (check) {
                                          // 삭제 처리
                                          int result = await boardService
                                              .delete(board.id!);
                                          if (result > 0) {
                                            // Alert 닫기
                                            Navigator.pop(context); // Alert 닫기
                                            // 게시글 목록으로 이동
                                            Navigator.pushReplacementNamed(
                                                context, "/board/list");
                                          }
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.more_vert),
                                    itemBuilder: (BuildContext context) {
                                      return _popupMenuItems;
                                    }),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  })
          // ListView.builder(
          //   itemBuilder: (context, index) {
          //     return GestureDetector(
          //       child: Card(
          //         child: ListTile(
          //           leading: Text('1'),
          //           title: Text("게시글 제목"),
          //           subtitle: Text("작성자"),
          //           trailing: Icon(Icons.more_vert),
          //         ),
          //       ),
          //     );
          //   },
          //   itemCount: 10,
          // ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 게시글 등록으로 이동
          Navigator.pushReplacementNamed(context, "/board/insert");
        },
        child: const Icon(Icons.create),
      ),
    );
  }
}
