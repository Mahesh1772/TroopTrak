import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_project_1/screens/home/read_items/read_status.dart';
import 'package:flutter/material.dart';

class EditUserDetails extends StatefulWidget {
  const EditUserDetails({super.key});

  @override
  State<EditUserDetails> createState() => _EditUserDetails();
}

const docIDs = 'Aakash Ramaswamy';
var _rank = TextEditingController();
var _name = TextEditingController();
var _appointment = TextEditingController();
var _rationType = TextEditingController();
var _status = TextEditingController();
var _mobileNumber = TextEditingController();
var _bloodgroup = TextEditingController();
var _dob = TextEditingController();
var _ord = TextEditingController();
var _attendence = TextEditingController();
List<String> documentIDs = [];
var snap;

class _EditUserDetails extends State<EditUserDetails> {
  Future getDocIDs() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(docIDs)
        .collection('Statuses')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        //print(element.data());
        documentIDs.add(element.reference.id);
      });
    });
    //.orderBy('rank', descending: false)
    print(documentIDs);
    setState(() {});
  }

  @override
  void initState() {
    getDocIDs();
    super.initState();
    documentIDs = [];
  }

  void display() {
    //snap.data.docs.forEach((f) => documentIDs.add(f));
    print(documentIDs);
    print(documentIDs.length);
  }

  var db = FirebaseFirestore.instance;

  Future adduser() async {
    //Adding user details
    updateUserDetails();
    //resetControllers();
    Navigator.pop(context);
  }

  Future updateUserDetails() async {
    await db.collection('Users').doc(docIDs).update({
      //User map formatting
      'rank': _rank.text.trim(),
      //'name': _name.text.trim(),
      'appointment': _appointment.text.trim(),
      'rationType': _rationType.text.trim(),
      'status': _status.text.trim(),
      'mobileNumber': _mobileNumber.text.trim(),
      'bloodgroup': _bloodgroup.text.trim(),
      'dob': _dob.text.trim(),
      'ord': _ord.text.trim(),
      'attendence': _attendence.text.trim(),
    });
  }

  void resetControllers() {
    _rank.clear();
    _name.clear();
    _appointment.clear();
    _rationType.clear();
    _status.clear();
    _mobileNumber.clear();
    _bloodgroup.clear();
    _dob.clear();
    _ord.clear();
    _attendence.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(docIDs)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    //We are trying to map the key and values pairs
                    //to a variable called "data" of Type Map
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;

                    // Populating the controllers with pre-existing value
                    _rank = TextEditingController(text: data['rank']);
                    _appointment =
                        TextEditingController(text: data['appointment']);
                    _rationType =
                        TextEditingController(text: data['rationType']);
                    _status = TextEditingController(text: data['status']);
                    _mobileNumber =
                        TextEditingController(text: data['mobileNumber']);
                    _bloodgroup =
                        TextEditingController(text: data['bloodgroup']);
                    _dob = TextEditingController(text: data['dob']);
                    _ord = TextEditingController(text: data['ord']);
                    _attendence =
                        TextEditingController(text: data['attendence']);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new),
                        ),
                        // rank
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextFormField(
                                autofocus: false,
                                controller: _rank,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter your Rank',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: TextEditingController(text: docIDs),
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter Name as in NRIC'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Appointment
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: _appointment,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Your Appointment'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ration type
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: _rationType,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Your Ration type'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // status
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: _status,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter Any statuses'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // mobile number
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: _mobileNumber,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Your Mobile Number'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // blood type
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: _bloodgroup,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Your blood group'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Date of Birth
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: _dob,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Date of Birth'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ORD date
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: _ord,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Your favourite ORD date'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Attendence to create the percentage indicator
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextField(
                                controller: _attendence,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Attendence: Inside or Out'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // sign in
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: GestureDetector(
                            onTap: adduser,
                            child: Container(
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade400,
                                    Colors.deepPurple.shade700,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                //color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Update Profile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    );
                  }
                  return const Text('Loading......');
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: documentIDs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditUserDetails(),
                          ),
                        );
                      },
                      child: ListTile(
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            width: 2,
                            color: Colors.indigo,
                          ),
                        ),
                        title: ReadUserStatus(
                            docIDs: docIDs, statusID: documentIDs[index]),
                        //subtitle: ReadUserRank(
                        //    docIDs: updated_documentIDs[index]),
                        tileColor: Colors.indigo.shade300,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
