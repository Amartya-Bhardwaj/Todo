import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: Myapp(),
  ));
}

class Myapp extends StatefulWidget {
  @override
  _MyappState createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  List todos = List();
  bool _hasbeenPressed = false; //TODO - Need to be fixed.
  String input = "";
  final messagecontroller = TextEditingController();
  createTodos() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(input);

    Map<String, String> todos = {"todoTitle": input};
    documentReference.set(todos).whenComplete(() {
      print('$input created');
    });
  }

  deleteTodos(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(item);
    documentReference.delete().whenComplete(() {
      print('$input deleted');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TODOs"),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messagecontroller,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: 'Write your TODOs',
                        border: InputBorder.none),
                    onChanged: (value) {
                      input = value;

                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          createTodos();
                          messagecontroller.clear();
                        });
                      }),
                )
              ],
            ),
            SizedBox(height: 10),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("MyTodos")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshots) {
                  return Expanded(
                    child: ListView.builder(
                        itemCount: snapshots.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot documentSnapshot =
                              snapshots.data.docs[index];
                          return Dismissible(
                              key: Key(index.toString()),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 18.0),
                                child: Card(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[

                                      Expanded(
                                        child: ListTile(
                                          leading: IconButton(icon: Icon(Icons.check),
                                          color: _hasbeenPressed? Colors.green:Colors.grey,
                                          onPressed: (){
                                            setState(() {
                                              _hasbeenPressed = !_hasbeenPressed;
                                            });
                                          },),
                                          title: Text(documentSnapshot['todoTitle']),
                                        ),
                                      ),
                                      SizedBox(width: 1),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        color: Colors.red,
                                        onPressed: () {
                                          setState(() {
                                            deleteTodos(documentSnapshot['todoTitle']);
                                          });
                                        },
                                      ),
                                      IconButton(icon: Icon(Icons.edit), onPressed: (){})
                                    ],
                                  ),
                                ),
                              ));
                        }),
                  );
                })
          ],
        ),
      ),
    );
  }
}
