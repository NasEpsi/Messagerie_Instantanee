import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/my_drawer.dart';
import '../components/my_input_alertbox.dart';
import '../helper/time_formatter.dart';
import '../models/conversation.dart';
import '../services/database/database_provider.dart';
import 'conversations_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Providers
  late final databaseProvider =
  Provider.of<DatabaseProvider>(context, listen: false);
  late final listeningProvider = Provider.of<DatabaseProvider>(context);

  // Controller for new conversation input
  final _conversationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load all conversations when the page is initialized
    _loadConversations();
  }

  // Load all conversations
  Future<void> _loadConversations() async {
    await databaseProvider.loadAllUserConversations();
  }

  // Show a dialog to start a new conversation
  void _showNewConversationBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertbox(
        textController: _conversationController,
        hintText: "Enter the user's email to start a conversation",
        onPressed: _startNewConversation,
        onPressedText: "Start",
      ),
    );
  }

  // Start a new conversation
  Future<void> _startNewConversation() async {
    if (_conversationController.text.trim().isEmpty) return;

    try {
      await databaseProvider.sendMessage(
        _conversationController.text.trim(), // Receiver's email
        "Hello!", // Initial message
      );
      _conversationController.clear();
    } catch (e) {
      print("Failed to start conversation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      drawer: MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewConversationBox,
        child: const Icon(Icons.message),
      ),
      // List of conversations
      body: _buildConversationList(listeningProvider.allConversations),
    );
  }

  // Display a list of conversations
  Widget _buildConversationList(List<Conversation> conversations) {
    return conversations.isEmpty
        ? const Center(
      child: Text(
        'No conversations yet',
      ),
    )
        : ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(conversation.participants.join(', ')),
          subtitle: Text(conversation.lastMessage),
          trailing: Text(formatTimestamp(conversation.lastMessageTimestamp)),
          onTap: () {
            // Navigate to the conversation page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversationListPage()
              ),
            );
          },
        );
      },
    );
  }
}