import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker picker = ImagePicker();
  int idUser = 1;

  File? selectedImage;

  pickImageFromGallery() async {
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }

  pickImageFromCamera() async {
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }

  uploadImageToFirebase() async {
    final ref = FirebaseStorage.instance.ref(
      'images/imageUser$idUser.png',
    );

    await ref.putFile(selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NOTE: IMAGE PICKER

              selectedImage != null ? Image.file(selectedImage!) : SizedBox(),

              GestureDetector(
                onTap: () {
                  pickImageFromGallery();
                },
                child: Icon(
                  Icons.upload,
                  size: 50,
                ),
              ),

              GestureDetector(
                onTap: () {
                  pickImageFromCamera();
                },
                child: Icon(
                  Icons.camera,
                  size: 50,
                ),
              ),

              TextButton(
                onPressed: () async {
                  print('upload image mulai');
                  await uploadImageToFirebase();
                  print('upload image selesai');
                },
                child: Text(
                  'Upload Image',
                ),
              ),

              // NOTE: SOCIAL AUTH

              TextButton(
                onPressed: () async {
                  final GoogleSignInAccount? googleUser =
                      await GoogleSignIn().signIn();

                  final GoogleSignInAuthentication? googleAuth =
                      await googleUser?.authentication;

                  final credential = GoogleAuthProvider.credential(
                    accessToken: googleAuth?.accessToken,
                    idToken: googleAuth?.idToken,
                  );

                  FirebaseAuth.instance.signInWithCredential(credential);
                },
                child: Text(
                  'Sign in with Google',
                ),
              ),
              TextButton(
                onPressed: () async {
                  final LoginResult loginResult =
                      await FacebookAuth.instance.login();
                  // Create a credential from the access token
                  final OAuthCredential facebookAuthCredential =
                      FacebookAuthProvider.credential(
                          loginResult.accessToken!.token);
                  // Once signed in, return the UserCredential
                  FirebaseAuth.instance
                      .signInWithCredential(facebookAuthCredential);
                },
                child: Text(
                  'Sign in with Facebook',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
