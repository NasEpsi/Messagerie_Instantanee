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
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Utilisateurs',
          style: TextStyle(color: theme.onPrimary),
        ),
        backgroundColor: theme.primary,
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
              backgroundColor: theme.secondary,
              child: Text(user.username[0].toUpperCase(),
              style: TextStyle(color: theme.onSecondary),
            ),
            ),
            title: Text(user.username,
              style: TextStyle(color: theme.primary),
            ),
            subtitle: Text(user.email,
              style: TextStyle(color: theme.tertiary),
            ),
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