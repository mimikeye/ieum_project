//하나의 커뮤니티 내 공지

import 'package:flutter/material.dart';

class NoticeListScreen extends StatelessWidget {
  const NoticeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 더미 데이터 (원하시는 데이터로 교체하세요)
    final List<Map<String, String>> notices = List.generate(
      10,
      (index) => {
        'title': '북한을 위한 기도합니다.',
        'content': '하나님, 우리가 직접 만나거나 볼 수 없는 사람들이지만 북한에서 살아가는 한 사람 한 사람의 삶을 주님께서 ...',
        'date': '08.02',
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '공지',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: notices.length,
        separatorBuilder: (context, index) => Padding(
          // 💡 수정됨: 구분선의 좌우 여백을 21로 맞춤
          padding: const EdgeInsets.symmetric(horizontal: 21.0),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
        itemBuilder: (context, index) {
          final notice = notices[index];
          return Padding(
            // 💡 수정됨: 리스트 아이템의 왼쪽/오른쪽 여백을 21로 맞춤
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice['title']!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notice['content']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    height: 1.4,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  notice['date']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}