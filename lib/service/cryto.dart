// 📱 Flutter (Client Side)

import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:pointycastle/asymmetric/api.dart' as pointy;

class CryptoService {
  final Map<String, Uint8List> groupKeys = {}; // Cache group keys theo groupId

  // Giải mã GroupKey từ server (bằng private key của client)
  Uint8List decryptGroupKey(
      String encryptedKeyBase64, pointy.RSAPrivateKey privateKey) {
    final encrypter = encrypt.Encrypter(encrypt.RSA(privateKey: privateKey));
    final decrypted = encrypter.decrypt64(encryptedKeyBase64);
    return Uint8List.fromList(utf8.encode(decrypted));
  }

  // Mã hóa nội dung tin nhắn với AES
  String encryptMessage(String plainText, Uint8List groupKeyBytes) {
    final key = encrypt.Key(groupKeyBytes);
    final iv = encrypt.IV.fromLength(16); // random nếu cần
    final aes = encrypt.Encrypter(encrypt.AES(key));
    return aes.encrypt(plainText, iv: iv).base64;
  }

  // Giải mã nội dung tin nhắn
  String decryptMessage(String encryptedBase64, Uint8List groupKeyBytes) {
    final key = encrypt.Key(groupKeyBytes);
    final iv = encrypt.IV.fromLength(16); // khớp với iv khi mã hóa
    final aes = encrypt.Encrypter(encrypt.AES(key));
    return aes.decrypt64(encryptedBase64, iv: iv);
  }
}

// 🧪 Sử dụng:
// final decryptedGroupKey = cryptoService.decryptGroupKey(encryptedGroupKey, myPrivateKey);
// final encryptedMsg = cryptoService.encryptMessage("Hello", decryptedGroupKey);
// final decryptedMsg = cryptoService.decryptMessage(encryptedMsg, decryptedGroupKey);
