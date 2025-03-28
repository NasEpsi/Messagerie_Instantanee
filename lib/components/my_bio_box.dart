/*
*
* Box Pour affiche la bio de l'utilisateur
*
* -----------------------------------------------------
*
* a besoin pour fonctionner de :
*
* - texte
*
* */
import 'package:flutter/material.dart';

class MyBioBox extends StatelessWidget {
  final String text;

  const MyBioBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text.isNotEmpty? text : "Pas encore de bio",
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
