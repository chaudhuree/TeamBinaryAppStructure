# 09 — Socket Integration (Real-Time Communication)

This chapter shows how to add WebSocket / Socket.IO support for real-time features like chat, live notifications, or live data updates.

---

## When to Use Sockets vs REST APIs

| Feature | REST API (HTTP) | WebSocket / Socket.IO |
|---------|----------------|----------------------|
| Chat messages | ❌ Need to poll repeatedly | ✅ Instant delivery |
| Notifications | ❌ Delayed | ✅ Real-time push |
| Live scores/prices | ❌ Stale data | ✅ Always up to date |
| CRUD operations | ✅ Perfect fit | ❌ Overkill |
| File uploads | ✅ Built for it | ❌ Not ideal |

**Rule of thumb:** Use REST for request-response. Use sockets when the server needs to **push** data to the client.

---

## Option A: Raw WebSocket (No Extra Package Needed)

Dart has built-in WebSocket support via `dart:io`.

### Step 1: Create the Socket Service

Create `lib/core/services/socket_service.dart`:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class SocketService {
  static SocketService? _instance;
  WebSocket? _socket;
  bool _isConnected = false;

  // Singleton pattern — one connection for the whole app
  static SocketService get instance {
    _instance ??= SocketService();
    return _instance!;
  }

  bool get isConnected => _isConnected;

  // ──────── CONNECT ────────
  Future<void> connect(String url) async {
    try {
      _socket = await WebSocket.connect(url);
      _isConnected = true;
      debugPrint("✅ WebSocket connected to $url");

      // Listen for incoming messages
      _socket!.listen(
        (data) {
          debugPrint("📩 Received: $data");
          _onMessage(data);
        },
        onDone: () {
          debugPrint("❌ WebSocket disconnected");
          _isConnected = false;
        },
        onError: (error) {
          debugPrint("⚠️ WebSocket error: $error");
          _isConnected = false;
        },
      );
    } catch (e) {
      debugPrint("❌ WebSocket connection failed: $e");
    }
  }

  // ──────── SEND MESSAGE ────────
  void send(Map<String, dynamic> data) {
    if (_isConnected && _socket != null) {
      _socket!.add(jsonEncode(data));
      debugPrint("📤 Sent: $data");
    } else {
      debugPrint("⚠️ Cannot send — not connected");
    }
  }

  // ──────── HANDLE INCOMING MESSAGES ────────
  void _onMessage(dynamic data) {
    // Parse and handle the message
    try {
      final Map<String, dynamic> message = jsonDecode(data);
      // You can use GetX to broadcast this to controllers:
      // Get.find<ChatController>().onNewMessage(message);
    } catch (e) {
      debugPrint("Parse error: $e");
    }
  }

  // ──────── DISCONNECT ────────
  void disconnect() {
    _socket?.close();
    _isConnected = false;
    debugPrint("🔌 WebSocket disconnected manually");
  }
}
```

### Step 2: Connect on App Start

In `main.dart` (or in a controller's `onInit`):

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to your WebSocket server
  await SocketService.instance.connect("ws://your-server.com/ws");

  runApp(BinaryDemoApp());
}
```

### Step 3: Send & Receive in a Controller

```dart
class ChatController extends GetxController {
  RxList<String> messages = <String>[].obs;

  void sendMessage(String text) {
    SocketService.instance.send({
      "type": "chat",
      "message": text,
    });
    messages.add("Me: $text");
  }

  void onNewMessage(Map<String, dynamic> data) {
    messages.add("Server: ${data['message']}");
  }
}
```

---

## Option B: Socket.IO (Recommended for Most Projects)

Socket.IO is more feature-rich than raw WebSockets — it auto-reconnects, supports rooms/namespaces, and works with event names.

### Step 1: Add the Package

```yaml
# pubspec.yaml
dependencies:
  socket_io_client: ^2.0.3+1
```

```bash
flutter pub get
```

### Step 2: Create the Socket.IO Service

Create `lib/core/services/socket_service.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;

  // Singleton
  static SocketService get instance {
    _instance ??= SocketService();
    return _instance!;
  }

  IO.Socket? get socket => _socket;

  // ──────── CONNECT ────────
  void connect(String serverUrl) {
    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])    // Use WebSocket transport
          .disableAutoConnect()            // We'll connect manually
          .build(),
    );

    _socket!.connect();

    // Connection events
    _socket!.onConnect((_) {
      debugPrint("✅ Socket.IO connected");
    });

    _socket!.onDisconnect((_) {
      debugPrint("❌ Socket.IO disconnected");
    });

    _socket!.onConnectError((error) {
      debugPrint("⚠️ Socket.IO connection error: $error");
    });
  }

  // ──────── LISTEN TO AN EVENT ────────
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  // ──────── EMIT (SEND) AN EVENT ────────
  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
    debugPrint("📤 Emitted '$event': $data");
  }

  // ──────── DISCONNECT ────────
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    debugPrint("🔌 Socket.IO disconnected manually");
  }
}
```

### Step 3: Connect on App Start

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to Socket.IO server
  SocketService.instance.connect("http://your-server.com:3000");

  runApp(BinaryDemoApp());
}
```

### Step 4: Use in a Controller

```dart
import 'package:get/get.dart';
import 'package:binary_demo_app/core/services/socket_service.dart';

class ChatController extends GetxController {
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenForMessages();
  }

  // Listen for incoming chat messages
  void _listenForMessages() {
    SocketService.instance.on("new_message", (data) {
      messages.add(data);
    });
  }

  // Send a chat message
  void sendMessage(String text) {
    final messageData = {
      "sender": "user123",
      "text": text,
      "timestamp": DateTime.now().toIso8601String(),
    };

    SocketService.instance.emit("send_message", messageData);
    messages.add(messageData);
  }

  // Join a room
  void joinRoom(String roomId) {
    SocketService.instance.emit("join_room", {"room": roomId});
  }

  @override
  void onClose() {
    // Clean up when controller is destroyed
    SocketService.instance.disconnect();
    super.onClose();
  }
}
```

### Step 5: Build the Chat View

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatView extends StatelessWidget {
  ChatView({super.key});

  final ChatController controller = Get.put(ChatController());
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live Chat")),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  return ListTile(
                    title: Text(msg['text'] ?? ''),
                    subtitle: Text(msg['sender'] ?? 'Unknown'),
                  );
                },
              );
            }),
          ),
          // Message input
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      controller.sendMessage(textController.text);
                      textController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Socket.IO Event Cheat Sheet

| Action | Client Code |
|--------|-------------|
| Connect | `SocketService.instance.connect(url)` |
| Listen to event | `SocketService.instance.on("event_name", (data) { ... })` |
| Send/emit event | `SocketService.instance.emit("event_name", data)` |
| Disconnect | `SocketService.instance.disconnect()` |

### Common Server Events to Listen For

```dart
// User typing indicator
SocketService.instance.on("user_typing", (data) {
  // Show "User is typing..."
});

// New notification
SocketService.instance.on("notification", (data) {
  Get.snackbar("New Notification", data['message']);
});

// Live data update (prices, scores, etc.)
SocketService.instance.on("price_update", (data) {
  // Update reactive variable
});
```

---

## Folder Structure After Adding Socket

```
lib/
└── core/
    └── services/
        ├── api_service.dart      ← REST API calls (Chapter 08)
        └── socket_service.dart   ← Socket connection (this chapter)
```

---

## Which Option Should You Choose?

| | Raw WebSocket | Socket.IO |
|---|---|---|
| **Auto-reconnect** | ❌ Manual | ✅ Built-in |
| **Event names** | ❌ Raw strings | ✅ Named events |
| **Rooms/namespaces** | ❌ No | ✅ Yes |
| **Fallback transports** | ❌ No | ✅ Long-polling fallback |
| **Extra dependency** | ✅ None (built-in) | ❌ Needs `socket_io_client` |
| **Best for** | Simple use cases | Production apps |

> **Speaker Note:** *"Sockets are like a phone call — the connection stays open and both sides can talk anytime. REST APIs are like sending letters — you send a request and wait for a reply. Use sockets when you need instant, two-way communication."*

---

**← Previous:** [08 — API Integration](08_API_INTEGRATION.md) · **Next →** [10 — Full Example Walkthrough](10_FULL_EXAMPLE_WALKTHROUGH.md)
