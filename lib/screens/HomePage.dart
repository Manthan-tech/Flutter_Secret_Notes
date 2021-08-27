import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:secret_notes/auth/user.dart';
import 'package:secret_notes/helpers/NoteModel.dart';
import 'package:secret_notes/helpers/screen_navigation.dart';
import 'package:secret_notes/screens/NotePage.dart';
import 'package:secret_notes/auth/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secret_notes/screens/editprofile.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color Darkblue = Color.fromRGBO(10, 23, 71, 1);
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool menuOpen = false;
  String _url = 'https://github.com/Manthan-tech/Flutter_Secret_Notes';
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserServices>(context);
    final auth = Provider.of<AuthProviderl>(context);
    if(user.user==null)
      user.getUser();
    return SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: (){changeScreen(context, NotePage(newNote: true,));},
            backgroundColor: Darkblue,),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap:(){setState(() {
                        menuOpen = !menuOpen;
                      });},
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(243, 244, 253, 1),
                          borderRadius: BorderRadius.all(Radius.circular(12))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(Icons.menu_rounded, color: Darkblue,),
                        ),
                      ),
                    ),
                    Text('MyNotes', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Darkblue),),
                    InkWell(
                      onTap: (){Fluttertoast.showToast(msg: 'This feature is not available' ,
                          backgroundColor: Color.fromRGBO(243, 244, 253, 1),
                          textColor: Darkblue);},
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(243, 244, 253, 1),
                            borderRadius: BorderRadius.all(Radius.circular(12))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(Icons.search, color: Darkblue,),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              menuOpen?ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ListTile(
                    tileColor: Darkblue,
                    leading: CircleAvatar(backgroundImage: NetworkImage(user.user.image),),
                    title: Text(user.user.name, style: TextStyle(color: Color.fromRGBO(243, 244, 253, 1),),),
                    subtitle: Text(user.user.email, style: TextStyle(color: Color.fromRGBO(243, 244, 253, 1),),),
                    trailing: Icon(Icons.edit,color: Colors.white),
                    onTap: (){changeScreen(context, EditProfile(user.user));},
                  ),
                  ListTile(
                    tileColor: Darkblue,
                    title: Text('New Note', style: TextStyle(color: Color.fromRGBO(243, 244, 253, 1),),),
                    onTap: (){changeScreen(context, NotePage(newNote: true,));},
                  ),
                  ListTile(
                    tileColor: Darkblue,
                    title: Text('Github Repository', style: TextStyle(color: Color.fromRGBO(243, 244, 253, 1),),),
                    onTap: () async => await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url',
                  ),
                  ListTile(
                    tileColor: Darkblue,
                    title: Text('Sign Out', style: TextStyle(color: Color.fromRGBO(243, 244, 253, 1),),),
                    onTap: (){auth.signOut(context: context);},
                  ),
                  ListTile(
                    tileColor: Darkblue,
                    title: Text('Rate app', style: TextStyle(color: Color.fromRGBO(243, 244, 253, 1),),),
                    onTap: (){Fluttertoast.showToast(msg: 'This feature is not available' ,
                        backgroundColor: Color.fromRGBO(243, 244, 253, 1),
                        textColor: Darkblue);},
                  ),
                ],
              ):Container(),
              Expanded(
                child: StreamBuilder(
                    stream: _firestore.collection('users').doc(user.user.id).collection('notes').orderBy('star', descending: true).snapshots(),
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        return ListView.separated(
                            itemBuilder: (context, index){
                              NoteModel note = NoteModel.fromSnapshot(snapshot.data.docs[index]);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text(snapshot.data.docs[index].data()['title'], maxLines: 1, semanticsLabel: '...', style: TextStyle(color: Darkblue, fontWeight: FontWeight.bold, fontSize: 18),),
                                  ),
                                  subtitle: Text(snapshot.data.docs[index].data()['note'],maxLines: 2,semanticsLabel: '...', style: TextStyle(color: Color.fromRGBO(130, 130, 130, 1), fontSize: 16),),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          note.star?InkWell(
                                            onTap: (){
                                              _firestore.collection('users').doc(user.user.id).collection('notes').doc(note.id).update(
                                                  {"star": false});
                                            },
                                              child: Icon(Icons.star, color: Color.fromRGBO(242, 160, 5, 1))):
                                          InkWell(
                                              onTap: (){
                                                _firestore.collection('users').doc(user.user.id).collection('notes').doc(note.id).update(
                                                    {"star": true});
                                              },child: Icon(Icons.star_border, color: Darkblue)),
                                          PopupMenuButton(
                                            itemBuilder:(context) => [
                                           PopupMenuItem(child: Text("Delete"),value: 1,),
                                           // PopupMenuItem(child: Text("Second"),value: 2,)
                                           ],
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: Icon(Icons.more_vert_rounded,color: Darkblue,),
                                            ),
                                            onSelected: (i){
                                              _firestore.collection('users').doc(user.user.id).collection('notes').doc(note.id).delete();
                                            },
                                          ),
                                        ],
                                      ),
                                    Text('${note.TimeDate.toDate().month}, ${note.TimeDate.toDate().day}, ${note.TimeDate.toDate().year}, ${note.TimeDate.toDate().hour}:${note.TimeDate.toDate().minute}', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color.fromRGBO(130, 130, 130, 1),),)
                                    ],
                                  ),
                                  // minVerticalPadding: 5,
                                  contentPadding: EdgeInsets.all(0),
                                  dense: false,
                                  visualDensity: VisualDensity.comfortable,
                                  isThreeLine: true,
                                  onTap: (){
                                    changeScreen(context, NotePage(note: note));
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (context, _){
                              return Divider(color: Color.fromRGBO(220, 220, 230, 1),);
                            },
                            itemCount: snapshot.data.docs.length,);
                      }else{
                        return Center(child: CircularProgressIndicator());
                      }
                    }),
              ),
            ],
          ),
        ));
  }
}
