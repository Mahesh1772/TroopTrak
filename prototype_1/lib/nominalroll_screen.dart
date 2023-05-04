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

var temp = contact.phones.elementAt(0);

class _NominalRollScreen extends State<NominalRollScreen> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _askPermissions(null);
    //getAllContacts();
  }

  /*
  getAllContacts() async{
    List<Contact> _contacts = await ContactsService.getContacts(withThumbnails: false);
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
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                Contact contact = contacts[index];
                temp = contact.phones.elementAt(0);
                return ListTile(
                  title: Text((contact.displayName).toString()),
                  subtitle: Text(
                    contact.phones.elementAt(0)
                    ),
                ),
              },
              )
          ],
        ),
      ),
    );
  }*/
  Future<void> _askPermissions(String routeName) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      if (routeName != null) {
        Navigator.of(context).pushNamed(routeName);
      }
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      const snackBar =  SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      const snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts Plugin Example')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Contacts list'),
              onPressed: () => _askPermissions('/contactsList'),
            ),
            ElevatedButton(
              child: const Text('Native Contacts picker'),
              onPressed: () => _askPermissions('/nativeContactPicker'),
            ),
          ],
        ),
      ),
    );
  }
}
