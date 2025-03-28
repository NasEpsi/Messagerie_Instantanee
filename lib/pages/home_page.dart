import 'package:flutter/material.dart';
import '../components/my_drawer.dart';
import 'conversations_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Navigate to ConversationListPage immediately after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ConversationListPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold with drawer while navigation occurs
    return Scaffold(
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}