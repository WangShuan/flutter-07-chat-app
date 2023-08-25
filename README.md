# 使用 Flutter 創建聊天室 app

## 設置及初始化 Firebase

首先要安裝 Firebase SDK 以簡化使用 Firebase 的大部分流程，可參考官方文檔： <https://firebase.google.com/docs/flutter/setup?hl=zh-tw&platform=ios>

安裝步驟如下：

1. 執行指令 `npm install -g firebase-tools` 安裝 Firebase CLI
2. 執行指令 `firebase login` 登入你的 Firebase 帳號(會自動開啟瀏覽器讓你選擇登入的 Google 帳號)
3. 執行指令 `dart pub global activate flutterfire_cli` 安裝 Firebase CLI (有可能需要加上 sudo 才可執行)
4. 執行命令 `flutterfire configure` 讓 flutter 項目綁定 Firebase 專案(步驟依序為選擇 Firebase 專案、選擇要使用的平台(選 IOS 與 Android) 、直接 Enter Yes 同意自動變更檔案)

> 執行第四步時如果出現錯誤 `zsh: command not found: flutterfire` 請開啟 `.zshrc` 檔案，添加 `export PATH="$PATH":"$HOME/.pub-cache/bin"` 保存並重開終端機。
> 執行第四步時如果出現錯誤 `no active package flutterfire_cli.` 請執行命令 `sudo flutterfire configure` 即可正確運行。

最後回到 flutter 專案中開啟 `main.dart` 檔案，修改以下內容以進行初始化：

```dart
// 引入
import 'package:firebase_core/firebase_core.dart';
import './firebase_options.dart';

//改寫 main 函數
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}
```

完成後請將 flutter 執行中的應用程式完全關閉並重新啟動即可。

> 如出現錯誤找不到 `project.pbxproj` 檔案，請用 Finder 進入檔案所在位置，並點擊右鍵，選擇取得資訊，更改讀取與寫入權限，再將 flutter 項目重啟即可。

## 使用 Authentication 服務(package: firebase_auth)

這邊要通過 `firebase_auth` 使用 Firebase 的 Authentication 服務讓用戶可通過電子郵件及密碼進行登入、註冊等功能。

### 登入與註冊

先到 Firebase 控制台中，點擊進入 “建構 > Authentication” 啟用 “電子郵件/密碼” 登入供應商，接著回到 flutter 項目中安裝 `firebase_auth` 並將 flutter 執行中的應用程式完全關閉，重新啟動。

接下來即可到 `auth_screen.dart` 中，在 `_submit` 函數裡面藉由判斷 `isLogin` 分別處理登入與註冊事件：

```dart
// 引入
import 'package:firebase_auth/firebase_auth.dart';
// 宣告
final _firebase = FirebaseAuth.instance;

// 使用
Future<void> _submit() async {
  if (!formKey.currentState!.validate()) return; // 驗證表單
  formKey.currentState!.save(); // 儲存表單內容
  if (_isLogin) { // 判斷是否為登入
    try {
      // 通過 _firebase.signInWithEmailAndPassword 傳入信箱與密碼進行登入
      await _firebase.signInWithEmailAndPassword(email: _mail!, password: _pwd!);
    } on FirebaseAuthException catch (e) { // 處理 firebase 提供的錯誤內容
      switch (e.code) {
        case 'user-not-found':
          _showSnackBar('找不到對應於該電子郵件的使用者。');
          break;
        case 'wrong-password':
          _showSnackBar('您輸入的帳號或密碼錯誤。');
          break;
        case 'invalid-email':
          _showSnackBar('您輸入的電子郵件地址無效。');
          break;
        case 'user-disabled':
          _showSnackBar('該使用者的帳號已被停用。');
          break;
        default:
          _showSnackBar(e.code);
          break;
      }
    } catch (e) { // 處理其他錯誤
      _showSnackBar(e.toString());
    }
  } else {
    try {
      // 通過 _firebase.createUserWithEmailAndPassword 傳入信箱與密碼進行註冊
      await _firebase.createUserWithEmailAndPassword(email: _mail!, password: _pwd!);
    } on FirebaseAuthException catch (e) { // 處理 firebase 提供的錯誤內容
      switch (e.code) {
        case 'email-already-in-use':
          _showSnackBar('此電子郵件地址已被使用。');
          break;
        case 'invalid-email':
          _showSnackBar('您輸入的電子郵件地址無效。');
          break;
        case 'operation-not-allowed':
          _showSnackBar('電子郵件/密碼註冊功能尚未啟用。');
          break;
        case 'weak-password':
          _showSnackBar('密碼強度不足。');
          break;
        default:
          _showSnackBar(e.code);
          break;
      }
    } catch (e) { // 處理其他錯誤
      _showSnackBar(e.toString());
    }
  }
}
```

### 登出

建立 `chat_screen.dart` 檔案，簡單設置好 appBar 小部件，在 actions 中新增 IconButton 綁定點擊事件，使用 `FirebaseAuth.instance.signOut()` 進行登出：

```dart
appBar: AppBar(
  title: const Text('CHAT APP'),
  actions: [
    IconButton(
      onPressed: () => FirebaseAuth.instance.signOut(),
      icon: const Icon(Icons.logout_rounded),
    ),
  ],
)
```

### 判斷當前用戶資訊

在 `main.dart` 檔案中的 home 區塊內容改寫如下：

```dart
StreamBuilder(
  stream: FirebaseAuth.instance.authStateChanges(), // 獲取當前用戶資訊
  builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
      ? Scaffold( // 載入中顯示 loading 畫面
          appBar: AppBar(title: const Text('CHAT APP')),
          body: const Center(child: CircularProgressIndicator()),
        )
      : snapshot.hasData // 判斷有無資訊
          ? const ChatScreen() // 如果已登入則顯示 ChatScreen 畫面
          : const AuthScreen(), // 如果未登入則顯示 AuthScreen 畫面
)
```

## 使用 Storage 服務(package: firebase_storage)

這邊要透過 `firebase_storage` 及 `image_picker` 讓用戶於註冊時可拍攝上傳用戶頭像並將圖片保存到 Firebase 的 Storage 服務中。

先到 Firebase 控制台中，點擊進入 “建構 > Storage” 啟用服務(選擇正式版本、選個亞洲地區即可)，完成後點擊 `Rules` 修改規則，將 `if false` 更改為 `if request.auth != null` 限制已登入的用戶才可以進行讀取及寫入，並點擊發布規則，接下來回到 flutter 專案中，安裝 `firebase_storage` 及 `image_picker` 用來保存用戶頭像，安裝好 pub 記得要將 flutter 執行中的應用程式完全關閉並重新啟動。

接著回到 `auth_screen.dart` 中通過 `_submit` 方法，於註冊時，藉由 `createUserWithEmailAndPassword` 方法獲取回傳的結果為 `res` ，通過 `res.user.uid` 獲取用戶 `uid` ，即可將圖片檔案設置名稱為 `'$uid.jpg'` 後上傳到 `firebase_storage` 中，並通過 `firebase_storage` 提供的 `getDownloadURL` 方法得到圖片網址。

整體主要程式碼如下：

```dart
try {
  final userCredential = await _firebase.createUserWithEmailAndPassword(email: _mail!, password: _pwd!); // 獲取用戶資料

  final storageRef = FirebaseStorage.instance.ref().child("user_images").child("${userCredential.user!.uid}.jpg"); // 設置欲上傳的檔案路徑
  
  try {
    await storageRef.putFile(_selectedImg!); // 上傳文件
    final imgUrl = await storageRef.getDownloadURL(); // 獲取文件 URL
    
    await userCredential.user?.updatePhotoURL(imgUrl); // 設置用戶頭像
  } on FirebaseException catch (e) { // 處理 FirebaseStorage 的錯誤
    _handleError(e);
  }
} on FirebaseAuthException catch (e) { // 處理 FirebaseAuth 的錯誤
  _handleError(e);
} catch (e) { // 處理其他錯誤
  _handleError(e.toString());
}
```

## 使用 Firestore Database 服務(package: cloud_firestore)

首先要到 Firebase 控制台中，點擊進入 “建構 > Firestore Database” ，這邊會顯示要你到 Google Cloud 控制台，請先點擊進入 Google Cloud 控制台，並點擊切換到本地模式，，完成後回到 Firebase 控制台，點擊 `Rules` 修改規則，將 `if false` 更改為 `if request.auth != null` 限制已登入的用戶才可以進行讀取及寫入，並點擊發布規則，接下來回到 flutter 專案中，安裝 `cloud_firestore` 即可。

上述步驟皆完成後，請記得要將 flutter 執行中的應用程式完全關閉並重新啟動。

如果重啟服務時一直停在 pod install 可透過以下步驟改善：

1. 開啟 `ios/Podfile` 檔案
2. 找到 `target 'Runner' do` 的程式碼
3. 於下一行貼上 `pod 'FirebaseFirestore', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git', :tag => '7.11.0'`
4. 將 `'7.11.0'` 替換為 <https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core/ios/firebase_sdk_version.rb> 網址中顯示的版本
5. 再次重新啟動服務，即可縮短編譯時間

### 保存用戶資料

在 `auth_screen.dart` 的註冊函數中，需添加一段程式碼，將用戶註冊的資料保存到 Firestore Database ：

```dart
try {
  final userCredential = await _firebase.createUserWithEmailAndPassword(email: _mail!, password: _pwd!); // 獲取用戶資料

  final storageRef = FirebaseStorage.instance.ref().child("user_images").child("${userCredential.user!.uid}.jpg"); // 設置欲上傳的檔案路徑
  
  try {
    await storageRef.putFile(_selectedImg!); // 上傳文件
    final imgUrl = await storageRef.getDownloadURL(); // 獲取文件 URL
    
    await userCredential.user?.updatePhotoURL(imgUrl); // 設置用戶頭像

    final db = FirebaseFirestore.instance;

    // 添加的內容如下，透過 collection 建立集合 users => 透過 doc 建立文檔 uid => 透過 set 設置文檔內容
    await db.collection('users').doc(userCredential.user!.uid).set({
      'username': _name, // 添加一個 TextFormField 小部件用來設置姓名並傳到此處
      'email': _mail,
      'image_url': imgUrl, // 傳入上方通過 FirebaseStorage 獲取到的文件 URL
    });
  } on FirebaseException catch (e) { // 處理 FirebaseStorage 的錯誤
    _handleError(e);
  }
} on FirebaseAuthException catch (e) { // 處理 FirebaseAuth 的錯誤
  _handleError(e);
} catch (e) { // 處理其他錯誤
  _handleError(e.toString());
}
```

### 發送並保存訊息

回到 `chat_screen.dart` 中，在聊天屏幕上方應該要有一個可滾動的區塊，用以顯示所有訊息，而最下方則要有一個文字輸入框及傳送按鈕用來新增訊息，所以這邊總共要再建立兩個子部件，分別是 `chat_messages.dart` 以及 `new_message.dart` 。

在 `chat_messages.dart` 中可通過 `FirebaseFirestore.instance.collection('messages').snapshots()` 獲取 `stream` 即時顯示所有訊息： 

```dart
final user = FirebaseAuth.instance.currentUser; // 獲取當前登入者資訊
final Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream = FirebaseFirestore.instance.collection('messages').orderBy("create_at", descending: true).snapshots(); // 設置 stream，可通過 .orderBy("create_at", descending: true) 設置 data 排序方式

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: StreamBuilder( // 通過 StreamBuilder 獲取結果
    stream: messagesStream, // 傳入上方宣告好的 stream 
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else if (snapshot.hasError) {
        return const Center(
          child: Text('Something wrong here.'),
        );
      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { // 判斷是否有值&該值底下的文檔是否為空
        return const Center(
          child: Text('No messages here.'),
        );
      } else {
        return ListView.builder( // 使用 ListView.builder 建立滾動區域
          padding: const EdgeInsets.all(0),
          reverse: true, // 設置排序方式為倒敘，可確保最新的項目永遠為在畫面最下方
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) => MessageItem(user, snapshot.data!.docs[index].data()),
        );
      }
    },
  ),
);
```

在 `new_message.dart` 中則可通過 `FirebaseFirestore.instance.collection('messages').add()` 添加訊息到 Firestore Database 中：

```dart
Future<void> _sendMessage() async {
  final msg = _messageConntroller.text; // 獲取輸入的內容

  if (msg.isEmpty || msg.trim().isEmpty) return; // 判斷是否有值

  FocusScope.of(context).unfocus(); // 關閉鍵盤
  _messageConntroller.clear(); // 清空輸入框

  final User? user = FirebaseAuth.instance.currentUser; // 獲取當前登入用戶資訊

  final db = FirebaseFirestore.instance;

  await db.collection('messages').add({ // 添加訊息資料到 Firestore Database 中
    'user_id': user!.uid, // 傳入 uid
    'user_image': user.photoURL, // 傳入頭像
    'username': user.displayName, // 傳入姓名
    'text': msg, // 傳入輸入的內容
    'create_at': Timestamp.now(), // 傳入當前時間
  });
}
```

## 使用 Firebase Messaging 服務(package: firebase_messaging)

這邊用來再有人傳送新訊息時，向其他人的設備發送推播通知。

初始化設定，針對 ios 請先用 Xcode 開啟專案項目的 `ios/Runner.xcworkspace` 檔案，接著在左側檔案列表中點擊 `Runner` ，右側主畫面中點擊 `Signing & Capabilities` ，

首先要啟用推送通知，請點擊 `+ Capability` 於搜尋欄位輸入 `push` ，雙擊結果中的 `Push Notifications` 啟用它，然後會看到主畫面中顯示一些錯誤警告，請將 `Bundle Identifier` 設置成唯一值，接著點擊鍵盤的 Enter 鍵保存。

接著要啟用後台獲取和遠程通知後台執行模式，請點擊 `+ Capability` 於搜尋欄位輸入 `back` ，雙擊結果中的 `Background Modes` 啟用它，然後會看到出現一些可勾選的項目，請將 `Background fetch` 及 `Remote notifications` 打勾即可。

然後進入 Apple 開發者頁面，登入付費的開發者帳號，點擊進入 Certificates, IDs & Profiles 底下的 Keys 中，點擊左上角＋號新增 key ，設置可識別的名稱，並將 `Apple Push Notifications service (APNs)` 勾選，點擊右上角繼續，再點擊註冊，然後點擊下載檔案將金鑰的 `.p8` 檔案保存好，然後切記先不要關閉當前頁面。

接下來先進入 Firebase 控制台中，點擊專案設定，點擊雲端通訊，在 Apple 應用程式設定中選擇你的 ios 應用程式，於 APN 驗證金鑰處點擊上傳，選擇剛才的 `.p8` 檔案，輸入金鑰 ID (在 Apple 開發者頁面下載金鑰的 Key ID)與團隊 ID(在 Apple 開發者頁面的右上角你名字旁邊)，點擊上傳。

然後一樣在 Firebase 控制台中的專案設定，點進一般設定裡面，將目前已經存在的應用程式刪除，重新回到 flutter 項目中執行指令 `flutterfire configure` ，以更新稍早變更過的 `Bundle Identifier` 。

接著再執行指令 `flutter pub add firebase_messaging` 安裝 Messaging 用的 package ，安裝好後記得關閉應用程式並重新啟動，然後在 `chat_screen.dart` 中獲取設備 token 稍後用來測試發送通知：

```dart
void setupMsg() async {
  await FirebaseMessaging.instance.requestPermission();
  final t = await FirebaseMessaging.instance.getToken();
  print('token:$t');
}

@override
void initState() {
  setupMsg();
  super.initState();
}
```

接著於 flutter 應用程式中登入或註冊帳號，並將 chat app 滑到背景執行。

最後進入 Firebase 控制台中，點擊左側 “互動交流 > Messaging” ，點擊建立第一個廣告活動，選擇 Firebase 通知訊息，輸入通知標題及通知文字，點擊傳送測試訊息，將剛才的 token 貼到 “新增 FCM 註冊憑證” 上並點擊 “測試” 即可收到推播通知，點擊通知即可開啟應用程式。

## 使用 Firebase Functions 服務

這邊主要是用來自動化的發送推播通知，上一段我們都是通過 Firebase 控制台手動測試發送通知，實際上則需要藉由後端處理自動化的程式碼，所以要到 Firebase 中的 “建構 > Functions“ 點擊使用(需要升級付費版本，但可放心，有免費用量的扣打)。

首先會要求你安裝 firebase-tool 請執行指令 `sudo npm install -g firebase-tools` 進行安裝(必須先安裝 node)

接著按照步驟執行命令 `firebase init` 啟動專案，第一步是選擇要啟用的功能，這邊只需用空白鍵選取 Functions 即可，接著會問你專案，選擇現有專案即可，然後要選擇使用的編程語言，這邊選 JS ，接著會問要不要啟用 ESLint 選 No ，最後會問要不要安裝依賴項目，請選 Yes ，完成後 flutter 項目中會自動產生新的資料夾 `functions` 我們主要編寫的後端程式碼在 `functions/index.js` 檔案中，編寫完畢執行命令 `firebase deploy` 即可成功部署 Functions 。

`functions/index.js` 檔案內容如下：

```dart
const functions = require('firebase-functions'); // 引入 functions
const admin = require('firebase-admin'); // 引入 admin
admin.initializeApp(); // 初始化 admin 對象

// 定義 sendNotificationOnNewMessage 事件
exports.sendNotificationOnNewMessage = functions.firestore
  .document('messages/{messageId}')
  .onCreate(async (snapshot, context) => { // 在文檔被創建時觸發
    const messageData = snapshot.data();

    const payload = {
      notification: {
        title: messageData.username + '發送了一條訊息',
        body: messageData.text,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
    };

    return admin.messaging().sendToTopic("chatapp", payload); // 向主題 chatapp 發送 FCM 消息
  });
```

要使用主題發送消息，需要在 `chat_screen.dart` 中讓用戶訂閱主題，該行為應該是被動執行，且要確保用戶曾經登入或註冊過帳號，由於在 `chat_screen.dart` 的父層會確保用戶進行過身份驗證才能進入該畫面，所以將訂閱事件設置於此：

```dart
class _ChatScreenState extends State<ChatScreen> {
  void setupMsg() async { // 添加函數用來訂閱主題
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.subscribeToTopic("chatapp");
  }

  @override
  void initState() {
    setupMsg(); // 於 initState 中調用訂閱主題的事件
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
    );
  }
}
```

使用主題發送消息類似於群發的概念，會將消息發送給所有訂閱過該主題的設備。

另外也可以針對單個用戶進行發送，做法即為獲取該用戶的 token 後通過 sendToDevice() 方法將 FCM 消息發送到與提供的 token 相對應的單個設備。

其他發送的方法可參考[官方文件說明](https://firebase.google.com/docs/reference/admin/node/firebase-admin.messaging.messaging?hl=zh-tw)