import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewStoryScreen extends StatefulWidget {
  final String storyId;
  final String userId;

  const ViewStoryScreen({
    Key? key,
    required this.storyId,
    required this.userId,
  }) : super(key: key);

  @override
  State<ViewStoryScreen> createState() => _ViewStoryScreenState();
}

class _ViewStoryScreenState extends State<ViewStoryScreen> {
  Map<String, dynamic>? _story;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  Future<void> _loadStory() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('stories')
          .select('*, users(fullName, photoURL)')
          .eq('id', widget.storyId)
          .single();

      // Increment view count
      await supabase
          .from('stories')
          .update({'views': (response['views'] ?? 0) + 1}).eq('id', widget.storyId);

      setState(() {
        _story = response;
        _story?['views'] = (response['views'] ?? 0) + 1;
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load story',
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final story = _story;
    if (story == null) {
      return Scaffold(
        body: Center(
          child: Text('Story not found'),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          if (story['imageURL'] != null)
            Image.network(
              story['imageURL'],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.grey.shade300),
            )
          else
            Container(color: Colors.grey.shade300),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Story info at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      if (story['users']?['photoURL'] != null)
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(story['users']['photoURL']),
                          radius: 24,
                        )
                      else
                        CircleAvatar(
                          child: Icon(Icons.person),
                          radius: 24,
                        ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story['users']?['fullName'] ??
                                  'Anonymous',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              DateTime.parse(story['createdAt'])
                                  .toString()
                                  .split('.')[0],
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Caption
                  if (story['caption'] != null && story['caption'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story['caption'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                      ],
                    ),

                  // View count
                  Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${story['views'] ?? 0} views',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
