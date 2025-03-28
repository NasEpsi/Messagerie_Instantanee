import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../services/auth/auth_service.dart';
import '../../services/database/database_provider.dart';
import '../components/my_input_alertbox.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Providers and Services
  late final AuthService _authService = AuthService();
  late final DatabaseProvider _databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  // Controllers
  final bioTextController = TextEditingController();
  final usernameTextController = TextEditingController();

  // User info
  UserProfile? userProfile;
  List<UserProfile> _friends = [];
  List<UserProfile> _pendingFriendRequests = [];
  bool _isLoading = true;
  bool _isFriend = false;
  bool _hasIncomingFriendRequest = false;
  bool _isCurrentUser = false;
  bool _isFriendRequestSent = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfileAndFriends();
  }

  // Load user profile and check friend status
  Future<void> _loadUserProfileAndFriends() async {
    try {
      setState(() {
        _isLoading = true;
        _isFriendRequestSent = false;
      });

      // reset friend request status
      if (_isFriend || _hasIncomingFriendRequest) {
        _isFriendRequestSent = false;
      }
      // Load user profile
      userProfile = await _databaseProvider.userProfile(widget.uid);

      // Check if this is the current user's profile
      _isCurrentUser = widget.uid == _authService.getCurrentUid();

      // Load current user's friends
      _friends = await _databaseProvider.getFriends();

      // Load pending friend requests
      _pendingFriendRequests =
          await _databaseProvider.getPendingFriendRequests();

      // Check if the viewed profile is a friend
      _isFriend = _friends.any((friend) => friend.uid == widget.uid);

      // Check if there's an incoming friend request from this user
      _hasIncomingFriendRequest =
          _pendingFriendRequests.any((request) => request.uid == widget.uid);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Send Friend Request
  Future<void> _sendFriendRequest() async {
    try {
      bool success = await _databaseProvider.sendFriendRequest(widget.uid);
      if (success) {
        setState(() {
          _isFriendRequestSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande d\'ami envoyée')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Impossible d\'envoyer la demande d\'ami')),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  // Handle accepting a friend request
  Future<void> _acceptFriendRequest(String requesterUid) async {
    try {
      bool success = await _databaseProvider.acceptFriendRequest(requesterUid);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande d\'ami acceptée')),
        );
        await _loadUserProfileAndFriends(); // Reload to update state
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Impossible d\'accepter la demande d\'ami')),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  // Handle rejecting a friend request
  Future<void> _rejectFriendRequest(String requesterUid) async {
    try {
      bool success = await _databaseProvider.rejectFriendRequest(requesterUid);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande d\'ami rejetée')),
        );
        await _loadUserProfileAndFriends(); // Reload to update state
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Impossible de rejeter la demande d\'ami')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  // Settings Dialog
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Paramètres du Profil',
        style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
        ),),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditBioDialog();
              },
              child: Text('Modifier la bio'),

            ),
          ],
        ),
      ),
    );
  }

  // Edit Bio Dialog
  void _showEditBioDialog() {
    bioTextController.text = userProfile?.bio ?? '';
    showDialog(
      context: context,
      builder: (context) => MyInputAlertbox(
        textController: bioTextController,
        hintText: "Parlez-nous de vous",
        onPressed: _saveBio,
        onPressedText: "Enregistrer",
      ),
    );
  }

  // Save Bio
  Future<void> _saveBio() async {
    if (userProfile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _databaseProvider.updateBio(bioTextController.text);
      await _loadUserProfileAndFriends();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  // Remove Friend
  Future<void> _removeFriend() async {
    try {
      bool success = await _databaseProvider.removeFriend(widget.uid);
      if (success) {
        setState(() {
          _isFriend = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ami retiré')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de retirer l\'ami')),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _buildFriendInteractionButtons() {
    // If it's the current user's profile, don't show any buttons
    if (_isCurrentUser) {
      return const SizedBox.shrink();
    }

    // If already friends
    if (_isFriend) {
      return Column(
        children: [
          Text(
            'Ami',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: _removeFriend,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Retirer de mes amis'),
          ),
        ],
      );
    }

    // If there's an incoming friend request
    if (_hasIncomingFriendRequest) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _acceptFriendRequest(widget.uid),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Accepter'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _rejectFriendRequest(widget.uid),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: const Text('Refuser'),
              ),
            ],
          ),
        ],
      );
    }

    // If friend request is sent
    if (_isFriendRequestSent) {
      return ElevatedButton(
        onPressed: null, // Disable the button
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        child: const Text('Envoyé'),
      );
    }

    // If not friends and no pending requests
    return ElevatedButton(
      onPressed: _sendFriendRequest,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      child: Text(
        'Ajouter comme ami',
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }

  Widget _buildFriendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mes Amis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                // full friends list page
              },
              child: Text(
                'Voir tous',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _friends.isEmpty
            ? Center(
                child: Text(
                  'Aucun ami',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _friends.map((friend) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                Theme.of(context).colorScheme.inverseSurface,
                            child: Text(
                              friend.name[0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            friend.username,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLoading ? "Profil" : userProfile?.name ?? "Profil",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isCurrentUser)
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _showSettingsDialog,
            ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProfile == null
              ? const Center(child: Text('Utilisateur non trouvé'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Picture
                        Center(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor:
                                Theme.of(context).colorScheme.inverseSurface,
                            child: Text(
                              userProfile!.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 40,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name and Username
                        Text(
                          userProfile!.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inverseSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${userProfile!.username}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18,
                          ),
                        ),

                        // Bio
                        if (userProfile!.bio.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            userProfile!.bio,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inverseSurface,
                              fontSize: 16,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Friend Action Buttons
                        _buildFriendInteractionButtons(),

                        const SizedBox(height: 16),

                        // Subscriptions Section
                        if (_isCurrentUser) _buildFriendsSection(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }
}
