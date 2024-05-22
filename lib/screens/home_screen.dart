import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projestuaspab2/screens/add_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projestuaspab2/screens/sign_in_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
        backgroundColor: Theme.of(context).colorScheme.outlineVariant,
        actions: [
          IconButton(
            onPressed: () {
              signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('add_post').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Loading...');
            default:
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                  snapshot.data!.docs[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        'Descriptions: ${documentSnapshot['description']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      leading: Container(
                        width: 70,
                        height: 70,
                        child: Image.network(
                          documentSnapshot['image'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User: ${_auth.currentUser?.email == documentSnapshot['email'] ? _auth.currentUser?.email ?? 'Unknown' : documentSnapshot['user_email']}',
                          ),
                          Text(DateFormat.yMMMd().add_jm().format(
                            documentSnapshot['time'].toDate(),
                          )),
                        ],
                      ),
                    ),
                  );
                },
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (
            ) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context)  => AddPostScreen()));
        },
        backgroundColor: Colors.grey,
        tooltip: 'Add Post',
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }
}