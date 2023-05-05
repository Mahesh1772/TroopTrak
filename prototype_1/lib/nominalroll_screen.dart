
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:prototype_1/text_style.dart';
import 'package:permission_handler/permission_handler.dart';

class NominalRollScreen extends StatefulWidget {
  const NominalRollScreen({super.key});

  @override
  State<NominalRollScreen> createState() {
    return _NominalRollScreen();
  }
}

class _NominalRollScreen extends State<NominalRollScreen> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    getAllContacts();
  }
  
  getAllContacts() async{
    List<Contact> _contacts = (await ContactsService.getContacts(withThumbnails: false)).toList();
    setState(() {
      contacts = _contacts;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const StyledText('Nominal Roll', 25),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            const StyledText('let the fun begin', 15),
            ListView.builder(
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                Contact contact = contacts[index];
                ListTile(
                  title: Text(contact.displayName.toString()),
                  //subtitle: Text(
                    //contact.phones.elementAt().value!.isEmpty ? 
                  //), 
                  
                );
              },
              )
          ],
        ),
      ),
    );
  }
}
