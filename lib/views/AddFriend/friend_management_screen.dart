import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overbloom/models/friend_model.dart';
import '../../controller/friend_controller.dart';
import '../../models/friend_request_model.dart';
import '../../repositories/friend_repository.dart';
import '../SendMenssage/send_message_screen.dart';

class FriendManagementScreen extends StatefulWidget {
  final String? currentUserId;

  const FriendManagementScreen({super.key, required this.currentUserId});

  @override
  FriendManagementScreenState createState() => FriendManagementScreenState();
}

class FriendManagementScreenState extends State<FriendManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  late FriendController _controller;
  List<FriendModel> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = FriendController(repository: FriendRepository());
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() async {
    setState(() => _isLoading = true);
    final me = widget.currentUserId!;
    final query = _searchController.text;

    // 1) Lista inicial de todos que batem com a query
    final friends = await _controller.searchFriends(query, me);

    // 2) Quem eu ENVIEI request
    final sentSnap = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('senderId', isEqualTo: me)
        .where('status', isEqualTo: 'pending') // só pendentes, se quiser evitar duplicata
        .get();

    // 3) Quem eu RECEBI request
    final recvSnap = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('receiverId', isEqualTo: me)
        .where('status', isEqualTo: 'pending')
        .get();

    // 4) Extrai todos os IDs opostos
    final blocked = <String>{ me };
    blocked.addAll(sentSnap.docs.map((d) => (d.data() as Map)['receiverId'] as String));
    blocked.addAll(recvSnap.docs.map((d) => (d.data() as Map)['senderId']   as String));

    // 5) IDs de amigos já confirmados
    final friendsSnap = await FirebaseFirestore.instance
        .collection('friends')
        .doc(me)
        .collection('userFriends')
        .get();
    blocked.addAll(friendsSnap.docs.map((d) => d.id));

    // 6) Filtra
    final filtered = friends.where((f) => !blocked.contains(f.id)).toList();

    setState(() {
      _results = filtered;
      _isLoading = false;
    });
  }

  void _sendRequest(String receiverId) async {
    try {
      await _controller.sendRequest(widget.currentUserId!, receiverId);

      setState(() {
        _results.removeWhere((friend) => friend.id == receiverId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Solicitação enviada com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao enviar solicitação, verifique sua internet e tente novamente!")),
      );
    }
  }

  void _acceptRequest(FriendRequest request) async {
    await _controller.acceptRequest(
        request.id, request.senderId, widget.currentUserId!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Solicitação aceita")),
    );
  }

  void _rejectRequest(FriendRequest request) async {
    await _controller.rejectRequest(
        request.id, request.senderId, widget.currentUserId!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Solicitação recusada")),
    );
  }

  void _showRequestOptions(FriendRequest request, String senderName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white.withOpacity(0.9),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nova Conexão!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B74A7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '$senderName enviou uma solicitação de amizade!',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF6B74A7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.check),
                            label: const Text(
                              'Aceitar',
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _acceptRequest(request);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.close),
                            label: const Text(
                              'Recusar',
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _rejectRequest(request);
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/fundo/principal_fundo.png',
            fit: BoxFit.cover,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
                              builder: (context) => SendMessageScreen(
                                  currentUserId: widget.currentUserId)),
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Color(0xFF6B74A7),
                  fontSize: 19,
                ),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ADICIONAR AMIGOS',
                  hintStyle: const TextStyle(
                    color: Color(0xFF6B74A7),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    height: 2.0,
                  ),
                  filled: true,
                  fillColor: const Color(0xffE3F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(
                      color: Color(0xFF6B74A7),
                      width: 2,
                    ),
                  ),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(0.0),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Image.asset(
                            'assets/images/icon/add_friend.png',
                            height: 35,
                            width: 35,
                          ),
                        ),
                ),
              ),
            ),
            if (_results.isNotEmpty)
              ..._results.map((friend) => Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: const Color(0xffE3F5F5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              friend.userName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B74A7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () => _sendRequest(friend.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B74A7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              "ADICIONAR",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            Divider(
              height: 20,
              color: Color(0xFF6B74A7),
            ),
            StreamBuilder<List<FriendRequest>>(
              stream: _controller.getPendingRequests(widget.currentUserId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                var requests = snapshot.data ?? [];
                return Column(
                  children: requests.map((request) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(request.senderId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(title: Text("Carregando..."));
                        }
                        var userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        var senderName =
                            userData['userName'] ?? 'Nome não disponível';
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          color: Color(0xffE3F5F5),
                          child: GestureDetector(
                            onTap: () =>
                                _showRequestOptions(request, senderName),
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    senderName.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6B74A7),
                                    ),
                                  ),
                                ),
                                if (request.status == 'pending')
                                  Positioned(
                                    top: 22,
                                    right: 8,
                                    child: Image.asset(
                                      'assets/images/icon/pending.png',
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
            StreamBuilder<List<FriendModel>>(
              stream: _controller.getFriends(widget.currentUserId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                var friends = snapshot.data ?? [];
                return Column(
                  children: friends.map((friend) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      color: Color(0xffE3F5F5),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            child: Text(
                              friend.userName.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B74A7),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 22,
                            right: 8,
                            child: Image.asset(
                              'assets/images/icon/friend.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        )
      ]),
    );
  }
}
