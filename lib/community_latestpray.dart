//커뮤니티 하나에 들어가서 최신순 더보기 눌렀을 때

import 'package:flutter/material.dart';

class LatestListScreen extends StatelessWidget {
  const LatestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 더미 데이터
    final List<Map<String, String>> latestItems = List.generate(
      10,
      (index) => {
        'title': '북한을 위한 기도합니다.',
        'content': '하나님, 우리가 직접 만나거나 볼 수 없는 사람들이지만 북한에서 살아가는 한 사람 한 사람의 삶을 주님께서 ...',
        'date': '08.02',
        'tag': '북한', 
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
          '최신순',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: latestItems.length,
        separatorBuilder: (context, index) => Padding(
          // 💡 NoticeListScreen과 동일하게 구분선 여백 21로 유지
          padding: const EdgeInsets.symmetric(horizontal: 21.0),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
        itemBuilder: (context, index) {
          final item = latestItems[index];
          return Padding(
            // 💡 요청하신 패딩 적용 (left: 25.0, right: 25.0, top: 20.0, bottom: 20.0)
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  style: const TextStyle(
                    fontSize: 15, // 💡 NoticeListScreen에 맞춤
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['content']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14, // 💡 NoticeListScreen에 맞춤
                    color: Colors.black, // 💡 NoticeListScreen에 맞춰 완전한 검정색으로 변경
                    height: 1.4,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      item['date']!,
                      style: const TextStyle(
                        fontSize: 12, // 💡 NoticeListScreen에 맞춤
                        color: Colors.black, // 💡 NoticeListScreen에 맞춰 검정색으로 변경
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      // 💡 중간 기호('|') 색상도 통일감 있게 검정 계열로 조정
                      child: Text('|', style: TextStyle(color: Colors.black54, fontSize: 12)), 
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color.fromRGBO(166, 166, 166, 1), width: 0.8),
                        borderRadius: BorderRadius.circular(13.4),
                      ),
                      child: Text(
                        item['tag']!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color.fromRGBO(166, 166, 166, 1), // 💡 다른 텍스트들과 조화를 위해 어두운 회색으로 변경
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}