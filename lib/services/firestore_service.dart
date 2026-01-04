import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/reservation.dart';

/// Firestoreとのやり取りを担当するサービス
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // コレクション名
  static const String _eventsCollection = 'events';
  static const String _reservationsCollection = 'reservations';

  // ========== イベント関連 ==========

  /// 全イベントを取得（日付順）
  Stream<List<Event>> getEvents() {
    return _db
        .collection(_eventsCollection)
        .orderBy('date')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  /// イベントを1件取得
  Future<Event?> getEvent(String eventId) async {
    final doc = await _db.collection(_eventsCollection).doc(eventId).get();
    if (!doc.exists) return null;
    return Event.fromFirestore(doc);
  }

  /// イベントを作成
  Future<String> createEvent(Event event) async {
    final docRef = await _db.collection(_eventsCollection).add(event.toFirestore());
    return docRef.id;
  }

  /// イベントを更新
  Future<void> updateEvent(Event event) async {
    await _db
        .collection(_eventsCollection)
        .doc(event.eventId)
        .update(event.toFirestore());
  }

  /// イベントを削除
  Future<void> deleteEvent(String eventId) async {
    await _db.collection(_eventsCollection).doc(eventId).delete();
  }

  /// 複数イベントを一括作成（CSVインポート用）
  Future<void> createEvents(List<Event> events) async {
    final batch = _db.batch();
    for (final event in events) {
      final docRef = _db.collection(_eventsCollection).doc();
      batch.set(docRef, event.toFirestore());
    }
    await batch.commit();
  }

  // ========== 予約関連 ==========

  /// ユーザーの予約一覧を取得
  Stream<List<Reservation>> getUserReservations(String userId) {
    return _db
        .collection(_reservationsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Reservation.fromFirestore(doc)).toList());
  }

  /// イベントの参加者一覧を取得
  Stream<List<Reservation>> getEventReservations(String eventId) {
    return _db
        .collection(_reservationsCollection)
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Reservation.fromFirestore(doc)).toList());
  }

  /// 予約を作成（参加者数も更新）
  Future<String> createReservation({
    required String eventId,
    required String userId,
  }) async {
    // トランザクションで予約作成と参加者数更新を同時に行う
    return await _db.runTransaction<String>((transaction) async {
      // イベントを取得
      final eventDoc = await transaction.get(
        _db.collection(_eventsCollection).doc(eventId),
      );

      if (!eventDoc.exists) {
        throw Exception('イベントが見つかりません');
      }

      final currentParticipants = eventDoc.data()!['currentParticipants'] ?? 0;
      final capacity = eventDoc.data()!['capacity'] ?? 0;

      if (currentParticipants >= capacity) {
        throw Exception('定員に達しています');
      }

      // 予約を作成
      final reservationRef = _db.collection(_reservationsCollection).doc();
      transaction.set(reservationRef, {
        'eventId': eventId,
        'userId': userId,
        'reservedAt': Timestamp.now(),
        'attended': false,
      });

      // 参加者数を更新
      transaction.update(eventDoc.reference, {
        'currentParticipants': currentParticipants + 1,
      });

      return reservationRef.id;
    });
  }

  /// 予約をキャンセル（参加者数も更新）
  Future<void> cancelReservation(String reservationId) async {
    // まず予約情報を取得
    final reservationDoc = await _db
        .collection(_reservationsCollection)
        .doc(reservationId)
        .get();

    if (!reservationDoc.exists) {
      throw Exception('予約が見つかりません');
    }

    final eventId = reservationDoc.data()!['eventId'];

    // トランザクションで予約削除と参加者数更新
    await _db.runTransaction((transaction) async {
      final eventDoc = await transaction.get(
        _db.collection(_eventsCollection).doc(eventId),
      );

      if (eventDoc.exists) {
        final currentParticipants = eventDoc.data()!['currentParticipants'] ?? 0;
        transaction.update(eventDoc.reference, {
          'currentParticipants': (currentParticipants - 1).clamp(0, 999999),
        });
      }

      transaction.delete(reservationDoc.reference);
    });
  }

  /// 出席状況を更新
  Future<void> updateAttendance(String reservationId, bool attended) async {
    await _db.collection(_reservationsCollection).doc(reservationId).update({
      'attended': attended,
    });
  }

  /// ユーザーが特定イベントを予約済みか確認
  Future<Reservation?> getUserReservationForEvent({
    required String userId,
    required String eventId,
  }) async {
    final snapshot = await _db
        .collection(_reservationsCollection)
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Reservation.fromFirestore(snapshot.docs.first);
  }

  // ========== ユーザー関連 ==========

  /// ユーザー情報を取得
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return doc.data();
  }
}

