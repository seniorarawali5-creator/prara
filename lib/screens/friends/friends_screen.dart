import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prashant/models/user_model.dart';
import 'package:prashant/models/friend_request_model.dart';
import 'package:prashant/services/friend_service.dart';

final logger = Logger();

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  
  late String _currentUserId;
  List<AppUser> _friends = [];
  List<FriendRequest> _pendingRequests = [];
  List<AppUser> _allUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
    
    // Get current user ID
    _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // Load friends
      final friends = await FriendService.getFriends(_currentUserId);
      
      // Load pending requests
      final requests = await FriendService.getPendingRequests(_currentUserId);
      
      // Load all users (for adding friends)
      final allUsers = await Supabase.instance.client
          .from('users')
          .select()
          .neq('id', _currentUserId);
      
      setState(() {
        _friends = friends;
        _pendingRequests = requests;
        _allUsers = allUsers.map((u) => AppUser.fromJson(u)).toList();
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAcceptRequest(FriendRequest request) async {
    final success = await FriendService.acceptFriendRequest(request.id);
    if (success) {
      Get.snackbar('Success', 'Friend request accept ho gai!',
          backgroundColor: Colors.green, colorText: Colors.white);
      _loadData();
    }
  }

  Future<void> _handleRejectRequest(FriendRequest request) async {
    final success = await FriendService.rejectFriendRequest(request.id);
    if (success) {
      Get.snackbar('Rejected', 'Friend request reject ho gya',
          backgroundColor: Colors.orange, colorText: Colors.white);
      _loadData();
    }
  }

  Future<void> _handleSendRequest(AppUser user) async {
    final success = await FriendService.sendFriendRequest(_currentUserId, user.id);
    if (success) {
      Get.snackbar('Sent', 'Friend request ${user.fullName} ko bhej di!',
          backgroundColor: Colors.green, colorText: Colors.white);
      _loadData();
    } else {
      Get.snackbar('Error', 'Request pehle se bhej rakhi hai ya accept ho gai',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Users'),
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              child: const Icon(Icons.close),
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // All Users Tab
                      _buildAllUsersTab(),
                      
                      // Friends Tab
                      _buildFriendsTab(),
                      
                      // Requests Tab
                      _buildRequestsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAllUsersTab() {
    final filteredUsers = _allUsers
        .where((u) => u.fullName
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();

    return filteredUsers.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('Koi user nahi mila'),
              ],
            ),
          )
        : ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    // Profile Avatar
                    GestureDetector(
                      onTap: () => Get.toNamed(
                        '/friend-profile',
                        arguments: {
                          'friendId': user.id,
                          'currentUserId': _currentUserId,
                        },
                      ),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF6366F1),
                            width: 2,
                          ),
                          image: user.profilePhotoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(user.profilePhotoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user.profilePhotoUrl == null
                            ? Center(
                                child: Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Colors.grey.shade400,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name & Status
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.toNamed(
                          '/friend-profile',
                          arguments: {
                            'friendId': user.id,
                            'currentUserId': _currentUserId,
                          },
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              user.isOnline ? 'Active now' : 'Offline',
                              style: TextStyle(
                                fontSize: 12,
                                color: user.isOnline ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Add Friend Button
                    ElevatedButton(
                      onPressed: () => _handleSendRequest(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildFriendsTab() {
    final filteredFriends = _friends
        .where((u) => u.fullName
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();

    return filteredFriends.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('Abhi koi friend nahi hai'),
              ],
            ),
          )
        : ListView.builder(
            itemCount: filteredFriends.length,
            itemBuilder: (context, index) {
              final friend = filteredFriends[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    // Profile Avatar
                    GestureDetector(
                      onTap: () => Get.toNamed(
                        '/friend-profile',
                        arguments: {
                          'friendId': friend.id,
                          'currentUserId': _currentUserId,
                        },
                      ),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF8B5CF6),
                            width: 2,
                          ),
                          image: friend.profilePhotoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(friend.profilePhotoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: friend.profilePhotoUrl == null
                            ? Center(
                                child: Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Colors.grey.shade400,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name & Status
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.toNamed(
                          '/friend-profile',
                          arguments: {
                            'friendId': friend.id,
                            'currentUserId': _currentUserId,
                          },
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              friend.isOnline ? 'Active now' : 'Offline',
                              style: TextStyle(
                                fontSize: 12,
                                color: friend.isOnline ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // View Profile Button
                    ElevatedButton.icon(
                      onPressed: () => Get.toNamed(
                        '/friend-profile',
                        arguments: {
                          'friendId': friend.id,
                          'currentUserId': _currentUserId,
                        },
                      ),
                      icon: const Icon(Icons.person, size: 16),
                      label: const Text('View'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildRequestsTab() {
    return _pendingRequests.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('Koi pending request nahi hai'),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _pendingRequests.length,
            itemBuilder: (context, index) {
              final request = _pendingRequests[index];
              
              return FutureBuilder<AppUser?>(
                future: FriendService.getUserProfile(request.senderId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    );
                  }

                  final senderUser = snapshot.data;
                  if (senderUser == null) return Container();

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        // Sender Avatar
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFEC4899),
                              width: 2,
                            ),
                            image: senderUser.profilePhotoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(senderUser.profilePhotoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: senderUser.profilePhotoUrl == null
                              ? Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 28,
                                    color: Colors.grey.shade400,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        // Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                senderUser.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Friend request bhej rakhi hai',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Accept/Reject Buttons
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  _handleAcceptRequest(request),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              child: const Text(
                                'Accept',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                            ),
                            const SizedBox(height: 4),
                            OutlinedButton(
                              onPressed: () =>
                                  _handleRejectRequest(request),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              child: const Text(
                                'Reject',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
  }
}
