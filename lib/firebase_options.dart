// IMPORTANTE: Este archivo debe ser generado con FlutterFire CLI.
// Sigue los pasos en README.md para configurar Firebase.
//
// Comando: flutterfire configure
//
// NO edites este archivo manualmente. Ejecuta el comando anterior
// después de crear tu proyecto en Firebase Console.

// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ⚠️  REEMPLAZA ESTOS VALORES con los de tu proyecto Firebase
  // Obtén estos valores en: Firebase Console > Configuración del proyecto > Tus apps
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TU_ANDROID_API_KEY',
    appId: 'TU_ANDROID_APP_ID',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
    storageBucket: 'TU_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TU_IOS_API_KEY',
    appId: 'TU_IOS_APP_ID',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
    storageBucket: 'TU_PROJECT_ID.appspot.com',
    iosBundleId: 'com.nextthing.mobile',
  );
}
