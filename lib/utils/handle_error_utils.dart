import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './snackbar_utils.dart';

void handleError(BuildContext context, dynamic error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        showSnackbar(context, '找不到對應於該電子郵件的使用者。');
        break;
      case 'wrong-password':
        showSnackbar(context, '您輸入的帳號或密碼錯誤。');
        break;
      case 'invalid-email':
        showSnackbar(context, '您輸入的電子郵件地址無效。');
        break;
      case 'user-disabled':
        showSnackbar(context, '該使用者的帳號已被停用。');
        break;
      case 'email-already-in-use':
        showSnackbar(context, '此電子郵件地址已被使用。');
        break;
      case 'operation-not-allowed':
        showSnackbar(context, '電子郵件/密碼註冊功能尚未啟用。');
        break;
      case 'weak-password':
        showSnackbar(context, '密碼強度不足。');
        break;
      default:
        showSnackbar(context, error.code);
        break;
    }
  } else if (error is FirebaseException) {
    showSnackbar(context, "Firebase Error: ${error.code}");
  } else {
    showSnackbar(context, "An error occurred: $error");
  }
}
