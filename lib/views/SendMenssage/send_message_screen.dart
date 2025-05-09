import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:overbloom/views/Home/home_screen.dart';
import 'package:overbloom/views/Store/store_screen.dart';
import 'package:overbloom/views/AddFriend/friend_management_screen.dart';
import '../../components/animated_currency_counter.dart';
import '../../models/friend_model.dart';
import '../../service/firebase_service.dart';
import '../../controller/send_message_controller.dart';

class SendMessageScreen extends StatefulWidget {
  final String? currentUserId;

  const SendMessageScreen({super.key, required this.currentUserId});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final SendMessageController _controller = SendMessageController();
  final TextEditingController _mensagemController = TextEditingController();

  bool _isSending = false;
  String? _selectedFriendId;
  String? _petVigente;
  List<FriendModel> _friends = [];
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final pet = await _controller.loadUserPet(widget.currentUserId!);
    final friends = await _controller.loadFriends(widget.currentUserId!);
    setState(() {
      _petVigente = pet;
      _friends = friends;
    });
  }

  Future<void> _enviarMensagem() async {
    if (_selectedFriendId == null || _mensagemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um amigo e escreva uma mensagem.')),
      );
      return;
    }

    setState(() => _isSending = true);

    final result = await _controller.sendMessage(
      senderId: widget.currentUserId!,
      recipientId: _selectedFriendId!,
      messageText: _mensagemController.text.trim(),
    );

    setState(() => _isSending = false);

    if (result) {
      setState(() {
        _selectedFriendId = null;
        _mensagemController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensagem enviada com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar mensagem')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fundo/mensagens.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                        },
                        icon: Image.asset('assets/images/icon/arrow_back.png', width: 50, height: 50),
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
                        Image.asset('assets/images/cenario/name_app.png', width: 250),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const StoreScreen(type: "pet")),
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset('assets/images/cenario/moldura_moeda.png', width: 120, height: 90),
                                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                        stream: firebaseService.getUserDocStream(userId!),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) return const Text('0');
                                          int moedas = snapshot.data?.data()?['numStars'] ?? 0;
                                          return AnimatedCurrencyCounter(
                                            value: moedas,
                                            currencyIcon: 'assets/images/icon/estrela.png',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FriendManagementScreen(currentUserId: userId),
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  'assets/images/buttons/add_friend_button.png',
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Card(
                          color: Colors.white.withOpacity(0.8),
                          margin: const EdgeInsets.symmetric(horizontal: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Text(
                                    "ENVIAR PARA:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedFriendId,
                                    hint: const Text("Selecione um amigo"),
                                    items: _friends.map((friend) {
                                      return DropdownMenuItem<String>(
                                        value: friend.id,
                                        child: Text(friend.userName, style: const TextStyle(color: Colors.black)),
                                      );
                                    }).toList(),
                                    onChanged: (value) => setState(() => _selectedFriendId = value),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                                    ),
                                    dropdownColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Image.asset(
                              'assets/images/cenario/balao_digita_msg.png',
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.contain,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 70),
                              child: TextField(
                                controller: _mensagemController,
                                maxLines: 2,
                                maxLength: 60,
                                style: const TextStyle(color: Colors.black, fontSize: 18),
                                textAlign: TextAlign.center,
                                textInputAction: TextInputAction.send,
                                decoration: const InputDecoration(
                                  hintText: "ESCREVA SUA MENSAGEM AQUI!",
                                  hintStyle: TextStyle(color: Colors.black),
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                onSubmitted: (_) => _enviarMensagem(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 150),
                              child: GestureDetector(
                                onTap: _isSending ? null : _enviarMensagem,
                                child: Image.asset(
                                  'assets/images/buttons/enviar_msg_button.png',
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_petVigente != null && _petVigente!.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(_petVigente!, height: 230, fit: BoxFit.contain),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}