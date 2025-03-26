import 'package:flutter/material.dart';
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
        title: const Text('Users'),
      ),
      drawer: MyDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(user.username[0].toUpperCase()),
            ),
            title: Text(user.username),
            subtitle: Text(user.email),
            onTap: () {
              // Generate conversation ID
              List<String> participants = [
                Provider.of<AuthService>(context, listen: false)
                    .getCurrentUid(),
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
        },
      ),
    );
  }
}