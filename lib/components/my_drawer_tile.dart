import 'package:flutter/material.dart';

/*

 Drawer Tile is a case for each element of the drawer menu
 Drawer tile pour chaque element qu'il a sur menu drawer
 ---------------------------------------------------------
 dans chaque tile on a :
 - untitre
 - une icon
 - une fonction
  */

class MyDrawerTile extends StatelessWidget {
  // Declare values

  final String title;
  final IconData icon;
  final void Function()? onTap;

  // constructor
  const MyDrawerTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  //UI
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
      ),
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: onTap,
    );
  }
}
