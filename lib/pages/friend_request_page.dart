import 'package:flutter/material.dart';
import 'package:messagerie_instantanee/pages/profile_page.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../services/database/database_provider.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  // Providers and Services
  late final DatabaseProvider _databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  List<UserProfile> _pendingFriendRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingFriendRequests();
  }

  Future<void> _loadPendingFriendRequests() async {
    try {
      setState(() {
        _isLoading = true;
      });
      _pendingFriendRequests =
          await _databaseProvider.getPendingFriendRequests();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement : $e')),
      );
    }
  }

  Future<void> _acceptFriendRequest(String requesterUid) async {
    try {
      bool success = await _databaseProvider.acceptFriendRequest(requesterUid);
      if (success) {
        await _loadPendingFriendRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande d\'ami acceptée')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'accepter la demande')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Future<void> _rejectFriendRequest(String requesterUid) async {
    try {
      bool success = await _databaseProvider.rejectFriendRequest(requesterUid);
      if (success) {
        await _loadPendingFriendRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande d\'ami rejetée')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de rejeter la demande')),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void _navigateToUserProfile(String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(uid: uid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes d\'amis'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.inversePrimary, // Inverser le fond
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _pendingFriendRequests.isEmpty
                ? Center(
                    child: Text(
                      'Aucune demande d\'ami',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _pendingFriendRequests.length,
                    itemBuilder: (context, index) {
                      final requester = _pendingFriendRequests[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 2,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () => _navigateToUserProfile(requester.uid),
                            child: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.inverseSurface,
                              child: Text(
                                requester.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            requester.name,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inverseSurface,
                            ),
                          ),
                          subtitle: Text(
                            '@${requester.username}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () =>
                                    _acceptFriendRequest(requester.uid),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                onPressed: () =>
                                    _rejectFriendRequest(requester.uid),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
