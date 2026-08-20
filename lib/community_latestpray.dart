//커뮤니티 하나에 들어가서 최신순 더보기 눌렀을 때

import 'package:flutter/material.dart';
import 'package:ieum_project/community_post_detail.dart';
import 'package:ieum_project/community_service.dart';

class LatestListScreen extends StatefulWidget {
  final String communityId;
  final String communityName;

  const LatestListScreen({
    super.key,
    required this.communityId,
    required this.communityName,
  });

  @override
  State<LatestListScreen> createState() =>
      _LatestListScreenState();
}

class _LatestListScreenState
    extends State<LatestListScreen> {

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
          '최신순',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: CommunityService.getLatestCommunityPosts(
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
                '게시글을 불러오지 못했습니다.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                ),
              ),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                '아직 작성된 기도문이 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'Pretendard',
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: posts.length,
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
              final post = posts[index];

              final postId =
                  post['postId'] as String? ?? '';

              final title =
                  post['title'] as String? ?? '';

              final content =
                  post['content'] as String? ?? '';

              final tag =
                  post['category'] as String? ?? '기도';

              final amenCount =
                  post['amenCount'] as int? ?? 0;

              return GestureDetector(
                onTap: () {
                  if (postId.isEmpty) {
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CommunityPostDetailScreen(
                        communityId: widget.communityId,
                        postId: postId,
                        communityName: widget.communityName,
                        title: title,
                        content: content,
                        tag: tag,
                        amenCount: amenCount,
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
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content,
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
                      Row(
                        children: [
                          const Text(
                            '최근',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Text(
                              '|',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromRGBO(
                                  166,
                                  166,
                                  166,
                                  1,
                                ),
                                width: 0.8,
                              ),
                              borderRadius:
                                  BorderRadius.circular(13.4),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color.fromRGBO(
                                  166,
                                  166,
                                  166,
                                  1,
                                ),
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ),
                        ],
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