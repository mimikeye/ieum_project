//하나의 커뮤니티 내 공지

import 'package:flutter/material.dart';
import 'community_service.dart';
import 'community_post_detail.dart';

class NoticeListScreen extends StatefulWidget {
  final String communityId;
  final String communityName;

  const NoticeListScreen({
    super.key,
    required this.communityId,
    required this.communityName,
  });

  @override
  State<NoticeListScreen> createState() =>
      _NoticeListScreenState();
}

class _NoticeListScreenState
    extends State<NoticeListScreen> {
  @override
  Widget build(BuildContext context) {

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: CommunityService.getAllNotices(
          communityId: widget.communityId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                '공지를 불러오지 못했습니다.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                ),
              ),
            );
          }

          final notices = snapshot.data ?? [];

          if (notices.isEmpty) {
            return const Center(
              child: Text(
                '등록된 공지가 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'Pretendard',
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: notices.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 21.0,
              ),
              child: Container(
                height: 1,
                color: Colors.grey.shade200,
              ),
            ),
            itemBuilder: (context, index) {
              final notice = notices[index];

              final postId =
                  notice['postId'] as String? ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CommunityPostDetailScreen(
                        communityId: widget.communityId,
                        postId: postId,
                        communityName: widget.communityName,
                        title:
                            notice['title'] as String? ?? '',
                        content:
                            notice['content'] as String? ?? '',
                        tag: '공지',
                        amenCount:
                            notice['amenCount'] as int? ?? 0,
                        isPublicPost: false,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 25.0,
                    right: 25.0,
                    top: 20.0,
                    bottom: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice['title'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notice['content'] as String? ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          height: 1.4,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}