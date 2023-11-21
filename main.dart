import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
        primarySwatch: MaterialColor(0xFF801723, {
          50: Color(0xFFFFEBEE),
          100: Color(0xFFFFCDD2),
          200: Color(0xFFEF9A9A),
          300: Color(0xFFE57373),
          400: Color(0xFFEF5350),
          500: Color(0xFF35091E),
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

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CollectionReference storeCollection =
      FirebaseFirestore.instance.collection('store');

  List<String> bookmarkedStores = [];

  void toggleBookmark(String storeId) {
    setState(() {
      if (bookmarkedStores.contains(storeId)) {
        bookmarkedStores.remove(storeId);
      } else {
        bookmarkedStores.add(storeId);
      }
    });
  }

  bool isStoreBookmarked(String storeId) {
    return bookmarkedStores.contains(storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('팡팡이, 기다려!'),
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
                var storeId = storeData.id;
                bool isBookmarked = isStoreBookmarked(storeId);
                return Container(
                  height: 150,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [ //스택으로 바꾸기
                        Container(
                          width: 120,
                          height: 120,
                          child: Center(child: Text('image')),
    /*Image.network(
                            storeData['gs://wait-pang.appspot.com/pang.png'], // 사진의 URL
                            fit: BoxFit.cover,
                          ),
     */
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(storeData['name']),
                            subtitle: Container(
                              width: 40,
                              height: 35,
                              //color: Colors.blueAccent,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            contentPadding: EdgeInsets.all(0),

                            /*Text(
                                '운영시간: ${storeData['starting time']} - ${storeData['closing time']}'),

                             */
                            trailing: IconButton(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isBookmarked
                                    ? Color(0xFF801723)
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                toggleBookmark(storeId);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailPage(storeData), // 상세 페이지로 데이터 전달
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
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
