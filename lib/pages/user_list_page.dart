import 'package:flutter/material.dart';
import 'package:messagerie_instantanee/pages/profile_page.dart';
import 'package:provider/provider.dart';
import '../../services/database/database_service.dart';
import '../../models/user.dart';
import '../components/my_drawer.dart';
import '../pages/chat_page.dart';
import '../services/auth/auth_service.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  List<UserProfile> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final dbService = DatabaseService();
      final users = await dbService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Utilisateurs',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return UserTile(user: user);
        },
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final UserProfile user;

  const UserTile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(uid: user.uid),
            ),
          );
        },
        child: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          child: Text(
            user.username[0].toUpperCase(),
            style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ),
      ),
      title: Text(
        user.username,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.inverseSurface,
          fontSize: 19,
        ),
      ),
      subtitle: Text(
        user.email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 23,
        ),
      ),
      onTap: () {
        // Generate conversation ID
        List<String> participants = [
          Provider.of<AuthService>(context, listen: false).getCurrentUid(),
          user.uid
        ]..sort();
        String conversationId = participants.join("_");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              conversationId: conversationId,
              recipientName: user.username,
            ),
          ),
        );
      },
    );
  }
}