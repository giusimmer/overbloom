import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overbloom/views/Info/info_screen.dart';
import '../../../service/firebase_service.dart';
import '../../Add/add_screen.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String? itemToDeleteId;
  String? itemToDeleteTitle;
  String? userId = FirebaseAuth.instance.currentUser?.uid;


  @override
  Widget build(BuildContext context) {
    FirebaseService firebaseService = FirebaseService();
    print('ID do usuário autenticado: $userId');
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/perfil.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/moldura_moeda.png',
                    width: 120,
                    height: 90,
                  ),
                  Row(
                    children: [
                      Image.asset('assets/images/moeda.png'),
                      const SizedBox(width: 5),
                      const Text(
                        "10",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("Botão pressionado");
                      },
                      child: Image.asset(
                        'assets/images/mensagem.png',
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Image.asset(
              'assets/images/bem_vindo.png',
              width: 250,
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Colors.black,
                size: 35,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: firebaseService.getUserActivitiesStream(userId!),
            builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Erro: ${snapshot.error}"));
              }

              List<Map<String, dynamic>> items = snapshot.data ?? [];

              List<Map<String, dynamic>> filteredItems = items.where((item) {
                var createdAtRaw = item['createdAt'];
                String frequency = item['frequency'] ?? "Once";

                DateTime? createdAt;
                if (createdAtRaw is Timestamp) {
                  createdAt = createdAtRaw.toDate();
                } else if (createdAtRaw is String) {
                  try {
                    createdAt = DateTime.parse(createdAtRaw);
                  } catch (e) {
                    return false;
                  }
                } else {
                  return false;
                }

                return shouldShowToday(createdAt, frequency);
              }).toList();

              filteredItems.sort((a, b) => (a['hour'] as int).compareTo(b['hour'] as int));

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: filteredItems.length + 1, // +1 para o botão ADD
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddScreen()),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xff5E64A9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff3A3F80),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "ADD",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  var item = filteredItems[index - 1];
                  String title = item['title'] ?? "Sem título";
                  int time = item['hour'] ?? 0;
                  int colorValue = item['color'] ?? 0x9B7591CF;
                  Color itemColor = Color(colorValue);

                  return Dismissible(
                    key: Key(item['id']),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        itemToDeleteId = item['id'];
                        itemToDeleteTitle = title;
                      });

                      showDeleteConfirmation(context, title, item['id'], firebaseService);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      height: 60,
                      decoration: BoxDecoration(
                        color: itemColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "$time:00",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  bool shouldShowToday(DateTime createdAt, String frequency) {
    DateTime today = DateTime.now();
    DateTime createdDate =
        DateTime(createdAt.year, createdAt.month, createdAt.day);

    switch (frequency) {
      case "Único":
        return createdDate == DateTime(today.year, today.month, today.day);

      case "Diário":
        return true;

      case "Semanal":
        return createdDate.weekday == today.weekday;

      case "Mensal":
        return createdDate.day == today.day;

      default:
        return false;
    }
  }

  void showDeleteConfirmation(BuildContext context, String title, String itemId,
      FirebaseService firebaseService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Exclusão"),
          content: Text("Você tem certeza que deseja excluir '$title'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                if (itemToDeleteId != null) {
                  await firebaseService.deleteActivity(
                      userId!, itemToDeleteId!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title excluído com sucesso!')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );
  }
}
