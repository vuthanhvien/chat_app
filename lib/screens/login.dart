import 'package:chat_app/api.dart';
import 'package:chat_app/models/types.dart';
import 'package:chat_app/screens/main.dart';
import 'package:chat_app/socket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.put(AuthController());

  final isLogin = false.obs;
  final loading = false.obs;
  final currentUser = IUser(id: '1', name: 'Alice').obs;

  final username = ''.obs;
  final password = ''.obs;
  final passwordConfirm = ''.obs;

  final formCode = 'login'.obs;

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
          height: 400,
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ctr.formCode.value == 'login')
                const Text(
                  'Login to Chat App',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              if (ctr.formCode.value == 'register')
                const Text(
                  'Register to Chat App',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              const Text('Email'),
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
              const Text('Password'),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your password',
                ),
                onChanged: (value) {
                  ctr.password.value = value;
                  // Handle password input
                },
              ),
              const SizedBox(height: 20),
              if (ctr.formCode.value == 'register') ...[
                const Text('Password (Confirm)'),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your password',
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
                  child: const Text('Register'),
                ),
              ],
              if (ctr.formCode.value == 'login') ...[
                ElevatedButton(
                  onPressed: () {
                    ctr.login();
                  },
                  child: const Text('Login'),
                ),
              ],
              const SizedBox(height: 10),
              if (ctr.formCode.value == 'login')
                Row(
                  children: [
                    const Text('Don\'t have an account?'),
                    TextButton(
                      onPressed: () {
                        ctr.formCode.value = 'register';
                        // Handle registration
                      },
                      child: const Text('Register'),
                    ),
                  ],
                ),
              if (ctr.formCode.value == 'register')
                Row(
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        ctr.formCode.value = 'login';
                        // Handle login
                      },
                      child: const Text('Login'),
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
