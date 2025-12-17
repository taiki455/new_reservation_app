import '../models/event.dart';
import '../models/reservation.dart';
import '../models/user.dart';

// モックユーザー
final mockCurrentUser = AppUser(
  uid: 'user1',
  name: '山田 太郎',
  email: 'taro@example.com',
  role: 'user',
);

final mockAdminUser = AppUser(
  uid: 'admin1',
  name: '管理者',
  email: 'admin@example.com',
  role: 'admin',
);

// モックイベント
final mockEvents = [
  Event(
    eventId: 'event1',
    title: '春のBBQパーティー🍖',
    description:
        '毎年恒例の春のBBQパーティーです！\n\n美味しいお肉と野菜を用意しています。飲み物は各自持参でお願いします。\n\n初めての方も大歓迎！みんなで楽しみましょう！',
    date: DateTime(2025, 4, 15, 11, 0),
    capacity: 30,
    currentParticipants: 18,
    createdBy: 'admin1',
    location: '代々木公園 BBQエリア',
  ),
  Event(
    eventId: 'event2',
    title: 'プログラミング勉強会 vol.12',
    description:
        'Flutterの基礎から応用まで学べる勉強会です。\n\n今回のテーマは「状態管理」。Riverpodを使った実践的なアプリ開発を学びます。\n\nノートPC持参必須です。',
    date: DateTime(2025, 3, 22, 14, 0),
    capacity: 20,
    currentParticipants: 20,
    createdBy: 'admin1',
    location: 'コワーキングスペース渋谷',
  ),
  Event(
    eventId: 'event3',
    title: '映画鑑賞会🎬',
    description: '話題の新作映画をみんなで観に行きましょう！\n\n上映後はカフェで感想会も予定しています。',
    date: DateTime(2025, 3, 30, 18, 30),
    capacity: 15,
    currentParticipants: 8,
    createdBy: 'admin1',
    location: 'TOHOシネマズ新宿',
  ),
  Event(
    eventId: 'event4',
    title: 'ボードゲーム会🎲',
    description:
        '人気のボードゲームを楽しむ会です！\n\nカタン、人狼、コードネームなど様々なゲームを用意しています。\n\n初心者の方にはルール説明から行います。',
    date: DateTime(2025, 4, 5, 13, 0),
    capacity: 12,
    currentParticipants: 5,
    createdBy: 'admin1',
    location: 'ボードゲームカフェ池袋',
  ),
  Event(
    eventId: 'event5',
    title: 'ランニング部 朝活🏃',
    description: '皇居周回コースを一緒に走りましょう！\n\nペースは5:30〜6:00/kmくらいを予定。\n\n走った後は近くのカフェでモーニング！',
    date: DateTime(2025, 3, 25, 7, 0),
    capacity: 10,
    currentParticipants: 6,
    createdBy: 'admin1',
    location: '皇居 桜田門集合',
  ),
];

// モック予約
final mockReservations = [
  Reservation(
    reservationId: 'res1',
    eventId: 'event1',
    userId: 'user1',
    reservedAt: DateTime(2025, 3, 10, 10, 30),
    attended: false,
  ),
  Reservation(
    reservationId: 'res2',
    eventId: 'event3',
    userId: 'user1',
    reservedAt: DateTime(2025, 3, 12, 15, 45),
    attended: false,
  ),
  Reservation(
    reservationId: 'res3',
    eventId: 'event5',
    userId: 'user1',
    reservedAt: DateTime(2025, 3, 15, 20, 0),
    attended: false,
  ),
];

// 参加者モック（管理者画面用）
final mockParticipants = [
  AppUser(uid: 'user1', name: '山田 太郎', email: 'taro@example.com', role: 'user'),
  AppUser(uid: 'user2', name: '佐藤 花子', email: 'hanako@example.com', role: 'user'),
  AppUser(uid: 'user3', name: '鈴木 一郎', email: 'ichiro@example.com', role: 'user'),
  AppUser(uid: 'user4', name: '田中 美咲', email: 'misaki@example.com', role: 'user'),
  AppUser(uid: 'user5', name: '高橋 健太', email: 'kenta@example.com', role: 'user'),
];

