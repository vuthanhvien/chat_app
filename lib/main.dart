import 'package:chat_app/screens/main/index.dart';
import 'package:chat_app/socket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "ChatAPP",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'ProductSans',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 14, color: Colors.white),
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MainScreen()),
      ],
      initialBinding: BindingsBuilder(() {
        Get.put(SocketService());
      }),
    );
  }
}
