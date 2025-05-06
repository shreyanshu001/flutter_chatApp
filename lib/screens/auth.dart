import 'package:chat_app/widget/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _islogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;
  var isAuthenticating = false;
  var _enteredUsername = '';
  void _submit() async {
    final isvalid = _form.currentState!.validate();
    if (!isvalid || !_islogin && _selectedImage == null) {
      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        isAuthenticating = true;
      });
      if (_islogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final storageRef = FirebaseStorage.instance //image storing in firebase.
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl
        }); //here we are creating a collection named users and specifying firestore which data should be stored in that document by sung set.
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // print('this email is in use');
        setState(() {
          isAuthenticating = false;
        });
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    left: 20, bottom: 20, right: 20, top: 30),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(16),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_islogin)
                        UserImagePicker(
                          onPickedImage: (p0) {
                            _selectedImage = p0;
                          },
                        ),
                      if (!_islogin)
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'username'),
                          validator: (value) {
                            if (value == null || value.trim().length < 4) {
                              return 'enter atleast 4 characters';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredUsername = newValue!;
                          },
                        ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: ' Email Address',
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@')) {
                            return 'not a valid Email Address';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredEmail = newValue!;
                        },
                        keyboardType: TextInputType.emailAddress,
                        keyboardAppearance: Brightness.light,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: ' Password',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'not a valid Password, must be atleast 6 characters';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredPassword = newValue!;
                        },
                        keyboardAppearance: Brightness.light,
                        obscureText: true,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      if (isAuthenticating) const CircularProgressIndicator(),
                      if (!isAuthenticating)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                          onPressed: _submit,
                          child: Text(_islogin ? 'login' : 'sign up'),
                        ),
                      if (!isAuthenticating)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _islogin = !_islogin;
                            });
                          },
                          child: Text(_islogin
                              ? 'Create an account'
                              : 'already have an account'),
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
