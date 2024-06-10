import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          DrawerHeader(child: Icon(Icons.apartment_outlined, color: Theme.of(context).colorScheme.inversePrimary,size: 35,)),

          Padding(padding: const EdgeInsets.only(left: 25.0), child: ListTile(
            leading: Icon(Icons.home),
            title: Text("H O M E",style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            onTap: (){
              Navigator.pop(context);
            },
          ),),
          SizedBox(height: 50.0,),
          Padding(padding: const EdgeInsets.only(left: 25.0), child: ListTile(
            leading: Icon(Icons.person),
            title: Text("P R O F I L E",style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            onTap: (){
              Navigator.pop(context);
            },
          ),),
          SizedBox(height: 50.0,),
          Padding(padding: const EdgeInsets.only(left: 25.0), child: ListTile(
            leading: Icon(Icons.map),
            title: Text("H E A T M A P",style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            onTap: (){
              Navigator.pop(context);
            },
          ),)

        ],
      ),

    );
  }
}
