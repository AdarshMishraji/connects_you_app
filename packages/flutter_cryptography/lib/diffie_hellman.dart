import 'package:cryptography/cryptography.dart';
import 'package:flutter_cryptography/helper.dart';

class DiffieHellman {
  DiffieHellman._();

  static final _instance = DiffieHellman._();
  static DiffieHellman get instance {
    return _instance;
  }

  List<int>? _alicePublicKey;
  List<int>? _alicePrivateKey;

  String? get alicePublicKey {
    if (_alicePublicKey != null) {
      return toHex(_alicePublicKey!);
    }
    return null;
  }

  String? get alicePrivateKey {
    if (_alicePrivateKey != null) {
      return toHex(_alicePrivateKey!);
    }
    return null;
  }

  set alicePublicKey(String? key) {
    if (key != null) {
      _alicePublicKey = fromHex(key);
    }
  }

  set alicePrivateKey(String? key) {
    if (key != null) {
      _alicePrivateKey = fromHex(key);
    }
  }

  Future<bool> generateKeyPair() async {
    try {
      final aliceKeys = await X25519().newKeyPair();
      final alicePublicKey =
          await aliceKeys.extractPublicKey().then((value) => value.bytes);
      final alicePrivateKey =
          await aliceKeys.extractPrivateKeyBytes().then((value) => value);
      _alicePrivateKey = alicePrivateKey;
      _alicePublicKey = alicePublicKey;
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  void setKeyPair({required String publicKey, required String privateKey}) {
    _alicePublicKey = fromHex(publicKey);
    _alicePrivateKey = fromHex(privateKey);
  }

  Future<String?> calculateSharedKey({
    required String bobPublicKey,
  }) async {
    if (_alicePrivateKey != null && _alicePublicKey != null) {
      try {
        final bobSimplePublicKey =
            SimplePublicKey(fromHex(bobPublicKey), type: KeyPairType.x25519);
        final aliceKeyPair = SimpleKeyPairData(_alicePrivateKey!,
            publicKey:
                SimplePublicKey(_alicePublicKey!, type: KeyPairType.x25519),
            type: KeyPairType.x25519);
        final sharedKey = await X25519()
            .sharedSecretKey(
                keyPair: aliceKeyPair, remotePublicKey: bobSimplePublicKey)
            .then((value) => value.extractBytes());
        return toHex(sharedKey);
      } catch (error) {
        print(error);
        return null;
      }
    } else {
      return null;
    }
  }
}
