import 'package:chat_app/api.dart';
import 'package:chat_app/models/types.dart';
import 'package:chat_app/screens/main/index.dart';
import 'package:chat_app/socket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

const randomeName = [
  'Alice',
  'Bob',
  'Charlie',
  'David',
  'Eve',
  'Frank',
  'Grace',
  'Hannah',
  'Ian',
  'Jack',
];

class AuthController extends GetxController {
  static AuthController get to => Get.put(AuthController());

  final isLogin = false.obs;
  final loading = false.obs;
  final currentUser = IUser(id: '1', name: 'Alice').obs;

  final username = ''.obs;
  final password = ''.obs;
  final passwordConfirm = ''.obs;

  final formCode = 'login'.obs;

  registerGuest() async {
    try {
      final res = await API.to.postData(
        '/auth/register',
        {
          'name':
              'Guest ${randomeName[DateTime.now().second % randomeName.length]}',
          'email': 'guest_${DateTime.now()}@fake.com',
          'password': '123123',
          'passwordConfirm': '123123',
        },
      );
      // Assuming the response contains a token
      final token = res['token'];
      GetStorage().write('token', token);
      getMe(); // Fetch user data
    } catch (e) {
      print("Error during guest registration: $e");
    }
  }

  register() async {
    try {
      final res = await API.to.postData(
        '/auth/register',
        {
          'name': username.value,
          'email': username.value,
          'password': password.value,
          'passwordConfirm': passwordConfirm.value,
        },
      );
      // Assuming the response contains a token
      final token = res['token'];
      GetStorage().write('token', token);
      getMe(); // Fetch user data after login
    } catch (e) {
      print("Error during registration: $e");
    }
  }

  login() async {
    try {
      final res = await API.to.postData(
        '/auth/login',
        {
          'email': username.value,
          'password': password.value,
        },
      );
      // Assuming the response contains a token
      final token = res['token'];
      GetStorage().write('token', token);
      getMe(); // Fetch user data after login
    } catch (e) {
      print("Error during login: $e");
    }
    // isLogin.value = true;
  }

  void logout() {
    isLogin.value = false;
    currentUser.value = IUser(id: '', name: '');
  }

  getMe() async {
    final res = await API.to.fetchData('/auth/me');
    currentUser.value = IUser.fromJson(res);
    currentUser.value.id = res['userId'] ?? '';

    SocketService.to.joinRoom(currentUser.value.id);
    isLogin.value = true;
  }

  @override
  void onInit() {
    super.onInit();
    final token = GetStorage().read('token');
    if (token != null) {
      getMe(); // Fetch user data if token exists
    } else {
      isLogin.value = false;
    }
  }
}

class LoginPage extends StatelessWidget {
  final ctr = AuthController.to;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(
        () => Container(
          height: 500,
          width: 400,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ctr.formCode.value == 'login')
                Text(
                  'Đăng Nhập APP '.toUpperCase(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              if (ctr.formCode.value == 'register')
                Text(
                  'Đăng Ký APP '.toUpperCase(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              Text('Email'.tr),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your email',
                ),
                onChanged: (value) {
                  ctr.username.value = value;
                  // Handle email input
                },
              ),
              const SizedBox(height: 10),
              Text('Mật khẩu'.tr),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập mật khẩu'.tr,
                ),
                onChanged: (value) {
                  ctr.password.value = value;
                  // Handle password input
                },
              ),
              const SizedBox(height: 20),
              if (ctr.formCode.value == 'register') ...[
                Text('Mật khẩu (xác nhận)'.tr),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: ''.tr,
                  ),
                  onChanged: (value) {
                    ctr.passwordConfirm.value = value;
                    // Handle password input
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ctr.register();
                  },
                  child: Text('ĐĂNG KÝ'.tr),
                ),
              ],
              if (ctr.formCode.value == 'login') ...[
                ElevatedButton(
                  onPressed: () {
                    ctr.login();
                  },
                  child: Text('ĐĂNG NHẬP'.tr),
                ),
              ],
              const SizedBox(height: 10),
              if (ctr.formCode.value == 'login')
                Row(
                  children: [
                    Text('Bạn không có tài khoản?'.tr),
                    TextButton(
                      onPressed: () {
                        ctr.formCode.value = 'register';
                        // Handle registration
                      },
                      child: Text('ĐĂNG KÝ'.tr),
                    ),
                  ],
                ),
              if (ctr.formCode.value == 'register')
                Row(
                  children: [
                    Text('Bạn đã có tài khoản?'.tr),
                    TextButton(
                      onPressed: () {
                        ctr.formCode.value = 'login';
                        // Handle login
                      },
                      child: Text('ĐĂNG NHẬP'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Container(
                height: 2,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sử dụng tư cách khách'.tr),
                  ElevatedButton(
                    onPressed: () {
                      // ctr.currentUser.value = IUser(id: 'guest', name: 'Guest');

                      ctr.registerGuest();
                    },
                    child: Text('GUEST'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
