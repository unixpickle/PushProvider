PushProvider
============

This is a light-weight Ruby-based Apple Push Notifications Provider. When run, `main.rb` will listen on the port 1337, accepting connections for administrators to send notifications to given devices, and for devices to register their device IDs.

One should place their private key and/or certificate *pem* file in resources/, and title it `cert.pem`. This will allow *PushProvider* to connect to Apple's APNS over an encrypted, SSL connection.

TCBPushAdmin
============

This small Cocoa application will connect to localhost, using the KeyedBits protocol to communicate with the locally running instance of *PushProvider*. It provides a simple interface for sending notifications, setting badge numbers, and playing sounds to a given device.
