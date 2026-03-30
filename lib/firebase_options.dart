// Gerado manualmente a partir do Firebase Console.
// Para Android: adicione o app Android no Firebase Console,
// baixe google-services.json e coloque em android/app/

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
        throw UnsupportedError('Linux não configurado.');
      default:
        throw UnsupportedError('Plataforma não suportada.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAH2jd4XuAg5WMtWmnmubo6cK9j5e9Ur8k',
    authDomain: 'infinistream-dfbb9.firebaseapp.com',
    projectId: 'infinistream-dfbb9',
    storageBucket: 'infinistream-dfbb9.firebasestorage.app',
    messagingSenderId: '190806287273',
    appId: '1:190806287273:web:4289163054aceb46ca9ab8',
  );

  // Windows usa o mesmo SDK do Web internamente
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAH2jd4XuAg5WMtWmnmubo6cK9j5e9Ur8k',
    authDomain: 'infinistream-dfbb9.firebaseapp.com',
    projectId: 'infinistream-dfbb9',
    storageBucket: 'infinistream-dfbb9.firebasestorage.app',
    messagingSenderId: '190806287273',
    appId: '1:190806287273:web:4289163054aceb46ca9ab8',
  );

  // Android: requer google-services.json em android/app/
  // Adicione o app Android no Firebase Console (package: com.infinistream.infini_stream)
  // e baixe o google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAH2jd4XuAg5WMtWmnmubo6cK9j5e9Ur8k',
    appId: '1:190806287273:android:SUBSTITUA_APOS_ADICIONAR_APP_ANDROID',
    messagingSenderId: '190806287273',
    projectId: 'infinistream-dfbb9',
    storageBucket: 'infinistream-dfbb9.firebasestorage.app',
  );

  // iOS: requer GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAH2jd4XuAg5WMtWmnmubo6cK9j5e9Ur8k',
    appId: '1:190806287273:ios:SUBSTITUA_APOS_ADICIONAR_APP_IOS',
    messagingSenderId: '190806287273',
    projectId: 'infinistream-dfbb9',
    storageBucket: 'infinistream-dfbb9.firebasestorage.app',
    iosBundleId: 'com.infinistream.infiniStream',
  );

  // macOS: requer GoogleService-Info.plist
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAH2jd4XuAg5WMtWmnmubo6cK9j5e9Ur8k',
    appId: '1:190806287273:ios:SUBSTITUA_APOS_ADICIONAR_APP_IOS',
    messagingSenderId: '190806287273',
    projectId: 'infinistream-dfbb9',
    storageBucket: 'infinistream-dfbb9.firebasestorage.app',
    iosBundleId: 'com.infinistream.infiniStream',
  );
}
