import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

List<Map<String , dynamic>> statusList = [];
List Outfield = ['Ex Sunlight','Ex grass', 'Ex Outfield' , 'Ex Outfield' , 'Ex Uniform' , 'Ex Boots'];
List Run = [ 'Ex RMJ' , 'Ex Lower Limb' , 'LD'];
List S_P = [ 'Ex Upper Limb' , 'LD'];
List Imt = ['Ex FLEGS' , 'Ex Uniform' , 'Ex Boots' , 'LD'];
List Atp = ['Ex FLEGS' , 'Ex Uniform' , 'Ex Boots' , 'LD' , 'Ex Lower Limb' , 'Ex RMJ'];
List Ippt = [ 'Ex Upper Limb' , 'LD', 'Ex Lower Limb' , 'Ex RMJ' , 'Ex Pushup' , 'Ex Situp'];
List soc = ['Ex Upper Limb' , 'LD', 'Ex Lower Limb' , 'Ex RMJ' ,'Ex Uniform' , 'Ex Boots' , 'Ex FLEGS'];
int i = 0;

class ParticipantAutoSelect extends StatelessWidget {
  ParticipantAutoSelect({
    super.key,
    required this.conductType,
    required this.documentIDs,
  });

  String conductType;
  List<String> documentIDs;

  Future getUserBooks() async {
    FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((querySnapshot) async {
      querySnapshot.docs.forEach((snapshot) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(snapshot.id)
            .collection("Statuses")
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((result) {
            Map<String, dynamic> data = result.data();
            if (DateFormat("d MMM yyyy")
                .parse(data['endDate'])
                .isAfter(DateTime.now())) {
              statusList.add(data);
              statusList[i].addEntries({'Name': snapshot.id}.entries);
              i++;
            }
          });
        });
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
