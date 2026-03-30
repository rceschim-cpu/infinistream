// ARQUIVO GERADO — substitua rodando:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Enquanto isso, este placeholder evita erros de compilação.
// O app NÃO funcionará com Firebase até você rodar flutterfire configure.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.linux:
        throw UnsupportedError('Linux não configurado ainda.');
      default:
        throw UnsupportedError('Plataforma não suportada.');
    }
  }

  // ⚠️  SUBSTITUA os valores abaixo pelos gerados pelo flutterfire configure

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'SUBSTITUA',
    appId: 'SUBSTITUA',
    messagingSenderId: 'SUBSTITUA',
    projectId: 'SUBSTITUA',
    authDomain: 'SUBSTITUA',
    storageBucket: 'SUBSTITUA',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUBSTITUA',
    appId: 'SUBSTITUA',
    messagingSenderId: 'SUBSTITUA',
    projectId: 'SUBSTITUA',
    storageBucket: 'SUBSTITUA',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'SUBSTITUA',
    appId: 'SUBSTITUA',
    messagingSenderId: 'SUBSTITUA',
    projectId: 'SUBSTITUA',
    storageBucket: 'SUBSTITUA',
    iosBundleId: 'com.infinistream.infiniStream',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'SUBSTITUA',
    appId: 'SUBSTITUA',
    messagingSenderId: 'SUBSTITUA',
    projectId: 'SUBSTITUA',
    authDomain: 'SUBSTITUA',
    storageBucket: 'SUBSTITUA',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'SUBSTITUA',
    appId: 'SUBSTITUA',
    messagingSenderId: 'SUBSTITUA',
    projectId: 'SUBSTITUA',
    storageBucket: 'SUBSTITUA',
    iosBundleId: 'com.infinistream.infiniStream',
  );
}
