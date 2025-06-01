import 'package:chat_app/api.dart';
import 'package:chat_app/models/types.dart';
import 'package:chat_app/screens/main/index.dart';
import 'package:chat_app/socket.dart';
import 'package:chat_app/widgets/button.dart';
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
  'Kathy',
  'Linda',
  'Mike',
  'Nina',
  'Oscar',
  'Paul',
  'Quincy',
  'Rachel',
  'Sam',
  'Tina',
  'Ursula',
  'Victor',
  'Wendy',
  'Xander',
  'Yara',
  'Zane',
  'Bella',
  'Chris',
  'Diana',
  'Ethan',
  'Fiona',
  'George',
  'Hailey',
  'Isaac',
  'Julia',
  'Kevin',
  'Liam',
  'Mona',
  'Noah',
  'Olivia',
  'Peter',
];

class AuthController extends GetxController {
  static AuthController get to => Get.put(AuthController());

  final isLogin = false.obs;
  final loading = false.obs;
  final getting = true.obs;
  final currentUser = IUser(id: '1', name: 'Alice').obs;

  final username = ''.obs;
  final password = ''.obs;
  final passwordConfirm = ''.obs;

  final formCode = 'login'.obs;

  final errorText = ''.obs;

  registerGuest() async {
    loading.value = true;
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
    loading.value = false;
  }

  register() async {
    errorText.value = '';
    if (username.value.isEmpty || password.value.isEmpty) {
      errorText.value = 'Vui lòng nhập đầy đủ thông tin';
      return;
    }
    if (password.value != passwordConfirm.value) {
      errorText.value = 'Mật khẩu không khớp';
      return;
    }
    loading.value = true;
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
    loading.value = false;
  }

  login() async {
    errorText.value = '';

    if (username.value.isEmpty || password.value.isEmpty) {
      errorText.value = 'Vui lòng nhập đầy đủ thông tin';
      return;
    }
    loading.value = true;
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
    loading.value = false;
    // isLogin.value = true;
  }

  void logout() {
    isLogin.value = false;
    currentUser.value = IUser(id: '', name: '');
  }

  getMe() async {
    try {
      final res = await API.to.fetchData('/auth/me');
      currentUser.value = IUser.fromJson(res);
      currentUser.value.id = res['userId'] ?? '';

      SocketService.to.joinRoom(currentUser.value.id);
      isLogin.value = true;
    } catch (e) {
      print("Error fetching user data: $e");
    }
    getting.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    final token = GetStorage().read('token');
    if (token != null) {
      getMe(); // Fetch user data if token exists
    } else {
      isLogin.value = false;
      getting.value = false; // No token, so not getting user data
    }
  }
}

class LoginPage extends StatelessWidget {
  final ctr = AuthController.to;

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(
        () => ctr.getting.value
            ? const CircularProgressIndicator()
            // Show loading indicator while fetching user data
            : Container(
                height: 550,
                width: 400,
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ctr.formCode.value == 'login')
                      Text(
                        'Đăng Nhập APP '.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    if (ctr.formCode.value == 'register')
                      Text(
                        'Đăng Ký APP '.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 20),
                    Text('Email'.tr),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Nhập email'.tr,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10.0),
                          hintStyle: const TextStyle(color: Colors.white70),
                        ),
                        onChanged: (value) {
                          ctr.username.value = value;
                          // Handle email input
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Mật khẩu'.tr),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Nhập mật khẩu'.tr,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10.0),
                          hintStyle: const TextStyle(color: Colors.white70),
                        ),
                        obscureText: true,
                        onChanged: (value) {
                          ctr.password.value = value;
                          // Handle email input
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (ctr.errorText.value.isNotEmpty)
                      Text(
                        ctr.errorText.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 20),
                    if (ctr.formCode.value == 'register') ...[
                      Text('Mật khẩu (xác nhận)'.tr),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: ''.tr,
                        ),
                        onChanged: (value) {
                          ctr.passwordConfirm.value = value;
                          // Handle password input
                        },
                      ),
                      const SizedBox(height: 20),
                      Button(
                        onTap: () {
                          ctr.register();
                        },
                        isLoading: ctr.loading.value,
                        text: 'ĐĂNG KÝ'.tr,
                      ),
                    ],
                    if (ctr.formCode.value == 'login') ...[
                      Button(
                        onTap: () {
                          ctr.login();
                        },
                        isLoading: ctr.loading.value,
                        text: 'ĐĂNG NHẬP'.tr,
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
                            child: const Text('ĐĂNG NHẬP'),
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
                        SizedBox(
                          width: 100,
                          child: Button(
                            text: 'Khách'.tr,
                            isLoading: ctr.loading.value,
                            size: ButtonSize.small,
                            onTap: () {
                              ctr.registerGuest();
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
