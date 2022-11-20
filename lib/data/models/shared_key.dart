class SharedKey {
  final String id; // this either roomId or userId acc to keyType
  final String keyType;
  final String sharedKey;

  const SharedKey({
    required this.id,
    required this.keyType,
    required this.sharedKey,
  });
}

class SharedKeyRoomIdMap extends SharedKey {
  final String roomId;

  const SharedKeyRoomIdMap({
    required this.roomId,
    required String id,
    required String keyType,
    required String sharedKey,
  }) : super(
          id: id,
          keyType: keyType,
          sharedKey: sharedKey,
        );
}
