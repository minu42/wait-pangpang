import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '음식점 정보',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF9B4D48, {
              50: Color(0xFFFFEBEE),
              100: Color(0xFFFFCDD2),
              200: Color(0xFFEF9A9A),
              300: Color(0xFFE57373),
              400: Color(0xFFEF5350),
              500: Color(0xFF9B4D48),
              600: Color(0xFFE53935),
              700: Color(0xFFD32F2F),
              800: Color(0xFFC62828),
              900: Color(0xFFB71C1C),
            }),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final CollectionReference storeCollection =
  FirebaseFirestore.instance.collection('store');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('음식점 목록'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: storeCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('데이터를 불러오는 중 오류가 발생했습니다.'),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var storeData = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(storeData['name']),
                  subtitle: Text(
                      '운영시간: ${storeData['starting time']} - ${storeData['closing time']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailPage(storeData), // 상세 페이지로 데이터 전달
                      ),
                    );
                  },
                );
              },
            );
          }
          return Center(
            child: Text('데이터가 없습니다.'),
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final QueryDocumentSnapshot storeData;

  DetailPage(this.storeData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('음식점 상세 정보'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '음식점 이름: ${storeData['name']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '운영시간: ${storeData['starting time']} - ${storeData['closing time']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '주소: ${storeData['adress']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
