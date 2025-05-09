import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../components/base_screen.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  RankingScreenState createState() => RankingScreenState();
}

class RankingScreenState extends State<RankingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, _) => SafeArea(
        child: BaseScreen(
          fundo: "principal_fundo.png",
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 15.h, 0, 0),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Image.asset(
                          'assets/images/icon/arrow_back.png',
                          width: 50.w,
                          height: 50.h,
                        ),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 4.w,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Image.asset(
                              'assets/images/cenario/name_app.png',
                              width: 250.w,
                              color: Colors.white.withOpacity(0.9),
                              colorBlendMode: BlendMode.srcATop,
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/cenario/name_app.png',
                          width: 250.w,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Image.asset(
                  'assets/images/cenario/ranking.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('usersRanking')
                      .orderBy('numStars', descending: true)
                      .orderBy('numCoins', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Erro: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('Nenhum usuário encontrado.'));
                    }

                    List<Map<String, dynamic>> rankingList = [];

                    for (var doc in snapshot.data!.docs) {
                      var data = doc.data() as Map<String, dynamic>;

                      rankingList.add({
                        'usuario': data['userName'] ?? 'Sem nome',
                        'avatarUser': data['avatarUser'] ??
                            'assets/images/perfil/default.png',
                        'numCoins': data['numCoins'] ?? 0,
                        'numStars': data['numStars'] ?? 0,
                      });
                    }

                    return ListView.builder(
                      itemCount: rankingList.length,
                      itemBuilder: (context, index) {
                        var user = rankingList[index];
                        // Verifica se o usuário é o primeiro colocado
                        String itemBackground = index == 0
                            ? 'assets/images/cenario/fundo_item_list1.png' // 1º lugar
                            : 'assets/images/cenario/fundo_item_list2.png'; // Demais lugares

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 28.w, vertical: 15.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.w),
                            image: DecorationImage(
                              image: AssetImage(itemBackground),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(user['avatarUser']),
                                backgroundColor: Colors.transparent,
                                radius: 20.w,
                              ),
                              SizedBox(width: 5.w),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  user['usuario'].toString().toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Row(
                                children: [
                                  Text(
                                    '${user['numCoins']}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/icon/moeda.png',
                                    height: 30.h,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${user['numStars']}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.sp,
                                      // Usando .sp para o tamanho da fonte
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/icon/estrela.png',
                                    height: 25.h,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
