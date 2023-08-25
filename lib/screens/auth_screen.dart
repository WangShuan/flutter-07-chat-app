import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/handle_error_utils.dart';
import '../widgets/auth_image_picker.dart';

final _firebase = FirebaseAuth.instance;

InputDecoration _inputStyle(String text) {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    hintText: text,
    border: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    ),
  );
}

bool isEmail(String val) =>
    RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(val);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String? _name;
  String? _mail;
  String? _pwd;
  File? _selectedImg;

  void _submit() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    if (_isLogin) {
      try {
        await _firebase.signInWithEmailAndPassword(email: _mail!, password: _pwd!);
      } on FirebaseAuthException catch (e) {
        _handleError(e);
      } catch (e) {
        _handleError(e.toString());
      }
    } else {
      if (_selectedImg == null) return _handleError('請選擇頭像。');
      try {
        final userCredential = await _firebase.createUserWithEmailAndPassword(email: _mail!, password: _pwd!);
        await userCredential.user?.updateDisplayName(_name);

        final storageRef = FirebaseStorage.instance.ref().child("user_images").child("${userCredential.user!.uid}.jpg");
        try {
          await storageRef.putFile(_selectedImg!);
          final imgUrl = await storageRef.getDownloadURL();
          await userCredential.user?.updatePhotoURL(imgUrl);

          final db = FirebaseFirestore.instance;
          await db.collection('users').doc(userCredential.user!.uid).set(
            {
              'username': _name,
              'email': _mail,
              'image_url': imgUrl,
            },
          );
        } on FirebaseException catch (e) {
          _handleError(e);
        }
      } on FirebaseAuthException catch (e) {
        _handleError(e);
      } catch (e) {
        _handleError(e.toString());
      }
    }
  }

  void _handleError(dynamic error) {
    handleError(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 120,
            ),
            const SizedBox(height: 16),
            if (!_isLogin)
              AuthImagePicker(
                (img) => setState(() => _selectedImg = img),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    if (!_isLogin)
                      TextFormField(
                        decoration: _inputStyle('Name'),
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.text,
                        validator: (val) => val == null || val.isEmpty || val.trim().isEmpty ? '請輸入正確的電子信箱。' : null,
                        onSaved: (newValue) => _name = newValue,
                        textInputAction: TextInputAction.next,
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputStyle('Email'),
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      validator: (val) => val == null || val.isEmpty || !isEmail(val.trim()) ? '請輸入正確的電子信箱。' : null,
                      onSaved: (newValue) => _mail = newValue,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputStyle('Password'),
                      obscureText: true,
                      validator: (value) => value == null || value.isEmpty || value.length < 6 ? '密碼長度至少需要六個字元。' : null,
                      onSaved: (newValue) => _pwd = newValue,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _submit,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submit,
                        child: Text(_isLogin ? '登入' : '註冊'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      child: Text(_isLogin ? '還沒有帳號？註冊' : '已有帳號？登入'),
                      onTap: () => setState(() => _isLogin = !_isLogin),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
