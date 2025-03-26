/*
*
* Un textField dans une boite de dialogue pour saisir du texte
*
* ----------------------------------------------------------
*
* On a besoin :
* - text controller
* - hint Text
* - Fonction, (sauvegarder
* - le texte du bouton qui lance la fonction
*
*/
import 'package:flutter/material.dart';

class MyInputAlertbox extends StatelessWidget {
  // variables
  final TextEditingController textController;
  final String hintText;
  final void Function()? onPressed;
  final String onPressedText;

  const MyInputAlertbox({
    super.key,
    required this.textController,
    required this.hintText,
    required this.onPressed,
    required this.onPressedText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      content: TextField(
        controller: textController,
        maxLength: 200,
        maxLines: 3,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide:
            BorderSide(color: Theme
                .of(context)
                .colorScheme
                .tertiary),
            borderRadius: BorderRadius.circular(12),
          ),

          // bordure quand input selectione
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
            ),
            borderRadius: BorderRadius.circular(12),
          ),


          //hintText
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme
                .of(context)
                .colorScheme
                .primary,
          ),
          // couleur de fond
          fillColor: Theme
              .of(context)
              .colorScheme
              .secondary,
          filled: true,

          // compteur de caractere
          counterStyle: TextStyle(
            color:
            Theme
                .of(context)
                .colorScheme
                .primary,
          ),
        ),

      ),
      actions: [
        //bouton enregistrer
        TextButton(
          onPressed: () {

            Navigator.pop(context);

            onPressed!();

            textController.clear();
          },
          child: Text(onPressedText),
        ),

        //bouton annuler
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            textController.clear();
          },
          child: Text("Annuler"),
        ),
      ],
    );
  }
}
