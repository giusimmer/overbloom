import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overbloom/views/Home/home_screen.dart';
import 'package:overbloom/views/SendMenssage/send_message_screen.dart';

class ReceivedMessagesScreen extends StatefulWidget {
  final String? currentUserId;

  const ReceivedMessagesScreen({super.key, required this.currentUserId});

  @override
  State<ReceivedMessagesScreen> createState() => _ReceivedMessagesScreenState();
}

class _ReceivedMessagesScreenState extends State<ReceivedMessagesScreen> {
  late Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = _loadMessages();
  }

  Stream<QuerySnapshot> _loadMessages() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('messages')
        .where('recipientUser', isEqualTo: widget.currentUserId)
        .orderBy('sendingDate', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.asset('assets/images/fundo/mensagens.png'),
            ),
          ),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()),
                          );
                        },
                        icon: Image.asset(
                          'assets/images/icon/arrow_back.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        Positioned(
                          left: 4,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Image.asset(
                              'assets/images/cenario/name_app.png',
                              width: 250,
                              color: Colors.white.withOpacity(0.9),
                              colorBlendMode: BlendMode.srcATop,
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/cenario/name_app.png',
                          width: 250,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _messagesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('Nenhuma mensagem ainda.'));
                    }

                    final messages = snapshot.data!.docs;

                    return PageView.builder(
                      itemCount: messages.length,
                      controller: PageController(
                        viewportFraction: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final String text = message['messageText'];
                        final String userAvatar = message['senderUserAvatar'];
                        final String petAvatar = message['senderUserPet'];
                        final String userName = message['senderUser'];
                        final timestamp = message['sendingDate'] as Timestamp;
                        final date = timestamp.toDate();
                        final formattedTime =
                            "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Image.asset(
                                    'assets/images/cenario/balao_de_fala.png',
                                    width: double.infinity,
                                    height: 350,
                                    fit: BoxFit.contain,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 35, vertical: 80),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage:
                                                  AssetImage(userAvatar),
                                              radius: 30,
                                              backgroundColor:
                                                  Colors.transparent,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "$userName:",
                                                    style: const TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    text,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      child: Image.asset(
                                        petAvatar,
                                        height: 240,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
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
        ],
      ),
    );
  }
}
