import 'package:flutter/material.dart';
import 'package:messagerie_instantanee/pages/conversations_list_page.dart';
import 'package:messagerie_instantanee/pages/friend_request_page.dart';
import 'package:messagerie_instantanee/pages/home_page.dart';
import 'package:messagerie_instantanee/pages/user_list_page.dart';

import '../pages/profile_page.dart';
import '../services/auth/auth_service.dart';
import 'my_drawer_tile.dart';
/*
MENU  DRAWER

menu acessible par un bouton en déployant une navigation latérale

--------------------------------------------------------------

les options du menu sont

- Accueil
- Profil
- Rechercher
- Paramètres
- Deconnexion

*/

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  //auth service
  final _auth = AuthService();

  void logout() {
    _auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,

      // icone
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(
                  indent: 25,
                  endIndent: 25,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(
                height: 10,
              ),

              // Accueil
              MyDrawerTile(
                title: "Vos conversations",
                icon: Icons.home,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationListPage(),
                    ),
                  );
                },
              ),

              // Profil
              MyDrawerTile(
                  title: "Profil",
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          uid: _auth.getCurrentUid(),
                        ),
                      ),
                    );
                  }),

              // Rechercher
              MyDrawerTile(
                title: "Rechercher",
                icon: Icons.search,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UsersListPage(),
                    ),
                  );
                },
              ),

              // Rechercher
              MyDrawerTile(
                title: "Demande d'ami",
                icon: Icons.mobile_friendly,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendRequestsPage(),
                    ),
                  );
                },
              ),

              // Parametres
              // MyDrawerTile(
              //   title: "parametres",
              //   icon: Icons.settings,
              //   onTap: () {
              //     Navigator.pop(context);
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => (){},
              //       ),
              //     );
              //   },
              // ),

              // Deconnexion
              MyDrawerTile(
                title: "Deconnexion",
                icon: Icons.logout,
                onTap: logout,
              ),
            ],
          ),
        ),
      ),

      //Rechercher
      // Deconnexion
    );
  }
}
