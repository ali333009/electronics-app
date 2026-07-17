importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBclpJtVGJOgEoKIgHH8FpqOZ61i-1I8D4",
  authDomain: "electronics-3c376.firebaseapp.com",
  projectId: "electronics-3c376",
  storageBucket: "electronics-3c376.firebasestorage.app",
  messagingSenderId: "156963900259",
  appId: "1:156963900259:web:609d3ddb1a1f80f1232156",
  measurementId: "G-GXY6LT53GZ"
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[SW] Background message received:', payload);
  const { title, body } = payload.notification ?? {};
  if (title) {
    self.registration.showNotification(title, {
      body: body ?? '',
      icon: '/icons/Icon-192.png',
    });
  }
});
