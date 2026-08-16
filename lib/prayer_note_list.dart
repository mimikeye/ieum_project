import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'prayer_note_service.dart';

class PrayerNotesPage extends StatefulWidget {
  const PrayerNotesPage({super.key});

  @override
  State<PrayerNotesPage> createState() => _PrayerNotesPageState();
}

class _PrayerNotesPageState extends State<PrayerNotesPage> {
  List<String> _categories = [];

  String? _selectedCategory;

  Future<void> _loadCategories() async {
    try {
      final snapshot =
          await PrayerNoteService.getPrayerNotes();

      final Set<String> categorySet = {};

      for (final note in snapshot.docs) {
        final data = note.data();

        final categories =
            List<String>.from(data['categories'] ?? []);

        categorySet.addAll(categories);
      }

      if (!mounted) return;

      setState(() {
        _categories = categorySet.toList();
      });
    } catch (e) {
      debugPrint('카테고리 불러오기 오류: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Widget _buildPrayerListItemFromFirebase(
    QueryDocumentSnapshot<Map<String, dynamic>> note,
  ) {
    final data = note.data();

    final String title =
        (data['title'] ?? '').toString();

    final String content =
        (data['content'] ?? '').toString();

    final String date =
        (data['date'] ?? '').toString();

    final List<String> categories =
        List<String>.from(data['categories'] ?? []);

    final List<String> imageUrls =
        List<String>.from(data['imageUrls'] ?? []);

    String displayDate = date;

    // yyyy-MM-dd → MM.dd
    if (date.length >= 10) {
      displayDate =
          '${date.substring(5, 7)}.${date.substring(8, 10)}';
    }

    final String tag =
        categories.isNotEmpty ? categories.first : '';

    final String? imageUrl =
        imageUrls.isNotEmpty ? imageUrls.first : null;

    return _buildPrayerListItem(
      title: title,
      content: content,
      date: displayDate,
      tag: tag,
      imageUrl: imageUrl,
      onTap: () {
        // 나중에 상세 페이지 연결
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 제목
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Text(
                    '나의 이음 기도문',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 카테고리
            SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 36),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected =
                      _selectedCategory == category;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory =
                            isSelected ? null : category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFA6A6A6)
                            : Colors.white,
                        border: Border.all(
                          color: const Color(0xFFA6A6A6),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Pretendard',
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFA6A6A6),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 기도문 목록
            Expanded(
              child: _buildPrayerNoteList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerNoteList() {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: PrayerNoteService.getPrayerNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              '기도문을 불러오지 못했습니다.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Pretendard',
                color: Colors.grey,
              ),
            ),
          );
        }

        final notes = snapshot.data?.docs ?? [];

        if (notes.isEmpty) {
          return const Center(
            child: Text(
              '작성한 기도문이 없습니다.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Pretendard',
                color: Colors.grey,
              ),
            ),
          );
        }

        // 카테고리 필터
        final filteredNotes = _selectedCategory == null
            ? notes
            : notes.where((note) {
                final data = note.data();

                final categories =
                    List<String>.from(
                  data['categories'] ?? [],
                );

                return categories.contains(
                  _selectedCategory,
                );
              }).toList();

        if (filteredNotes.isEmpty) {
          return const Center(
            child: Text(
              '해당 카테고리의 기도문이 없습니다.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Pretendard',
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          itemCount: filteredNotes.length,
          separatorBuilder: (context, index) {
            return const Divider(
              height: 24,
              thickness: 1,
              color: Color(0xFFEEEEEE),
            );
          },
          itemBuilder: (context, index) {
            final note = filteredNotes[index];

            return _buildPrayerListItemFromFirebase(note);
          },
        );
      },
    );
  }

  Widget _buildPrayerListItem({
    required String title,
    required String content,
    required String date,
    required String tag,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Pretendard',
                          height: 1.4,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 0.5,
                            height: 11,
                            color: const Color.fromRGBO(113, 113, 113, 100),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color.fromRGBO(166, 166, 166, 1),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Pretendard',
                                color: const Color.fromRGBO(166, 166, 166, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 95,
                    height: 95,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 95,
                          height: 95,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}