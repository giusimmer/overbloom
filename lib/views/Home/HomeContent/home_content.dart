import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:overbloom/repositories/home_activity_repository.dart';
import 'package:overbloom/repositories/home_user_repository.dart';
import '../../../components/animated_currency_counter.dart';
import '../../../controller/home_content_controller.dart';
import '../../../models/home_activity_model.dart';
import '../../../models/home_user_model.dart';
import '../../Add/add_screen.dart';
import '../../Info/info_screen.dart';
import '../../SendMenssage/send_message_screen.dart';
import '../../Store/store_screen.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String? itemToDeleteId;
  String? itemToDeleteTitle;
  late HomeContentController _controller;
  bool _isLoadingUser = true;
  bool _isUpdating = false;
  HomeUserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _setupController();
    _loadUserAndActivities();
  }

  void _setupController() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('No user logged in');
      return;
    }

    final homeUserRepository = HomeUserRepository();
    final homeActivityRepository = HomeActivityRepository(userId: userId);
    _controller = HomeContentController(
      homeUserRepository: homeUserRepository,
      homeActivityRepository: homeActivityRepository,
    );
  }

  Future<void> _loadUserAndActivities() async {
    try {
      await _controller.checkAndCreateRecurringActivities();
      final user = await _controller.getUserInfo();

      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
    } catch (e) {
      print('Error loading user info: $e');
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    return Column(
      children: [
        _buildUserHeader(userId),
        const SizedBox(height: 10),
        _buildWelcomeRow(),
        const SizedBox(height: 10),
        _buildActivityList(userId),
      ],
    );
  }

  Widget _buildUserHeader(String userId) {
    return Row(
      children: [
        _buildUserAvatar(),
        const SizedBox(width: 10),
        _buildCoinCounter(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildMessageButton(userId),
                const SizedBox(width: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: ClipOval(
        child: _isLoadingUser
            ? const SizedBox(
                width: 100,
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : Image.asset(
                _currentUser?.avatarPath ?? 'assets/images/perfil/defaut.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildCoinCounter() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => StoreScreen(type: "avatar")),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/cenario/moldura_moeda.png',
                width: 120,
                height: 90,
              ),
              StreamBuilder<HomeUserModel>(
                stream: _controller.getUserStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData) {
                    return const Text('0');
                  }

                  return AnimatedCurrencyCounter(
                    value: snapshot.data!.coins,
                    currencyIcon: 'assets/images/icon/moeda.png',
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageButton(String userId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendMessageScreen(currentUserId: userId),
          ),
        );
      },
      child: Image.asset(
        'assets/images/icon/mensagem.png',
        width: 80,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildWelcomeRow() {
    return Row(
      children: [
        Image.asset(
          'assets/images/cenario/bem_vindo.png',
          width: 250,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(
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
    );
  }

  Widget _buildActivityList(String userId) {
    return Expanded(
      child: StreamBuilder<List<HomeActivityModel>>(
        stream: _controller.getActivitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          List<HomeActivityModel> items = snapshot.data ?? [];

          List<HomeActivityModel> todayItems = items.where((item) {
            DateTime today = DateTime.now();
            return item.createdAt.year == today.year &&
                item.createdAt.month == today.month &&
                item.createdAt.day == today.day &&
                !item.archived;
          }).toList();

          todayItems.sort((a, b) => a.hour.compareTo(b.hour));

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: todayItems.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddButton();
              }

              return _buildActivityItem(todayItems[index - 1]);
            },
          );
        },
      ),
    );
  }

  Widget _buildAddButton() {
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

  Widget _buildActivityItem(HomeActivityModel activity) {
    return Dismissible(
      key: Key(activity.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          itemToDeleteId = activity.id;
          itemToDeleteTitle = activity.title;
        });

        showDeleteConfirmation(context, activity.title, activity.id);
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
          color: Color(activity.colorValue),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Transform.scale(
              scale: 1.6,
              child: Checkbox(
                  activeColor: Colors.black87,
                  value: activity.completed,
                  onChanged: (bool? value) async {
                    if (value == null ||
                        _isUpdating ||
                        _controller.isActivityExpired(activity)) return;

                    setState(() => _isUpdating = true);

                    try {
                      await _controller.toggleActivityCompletion(
                          activity, value);
                    } catch (e) {
                      print('Erro ao atualizar atividade: $e');
                    } finally {
                      if (mounted) {
                        setState(() => _isUpdating = false);
                      }
                    }
                  }),
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                activity.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              DateFormat('HH:mm').format(activity.hour),
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
  }

  void showDeleteConfirmation(
    BuildContext context,
    String title,
    String itemId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE2FBF7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 60,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Confirmar Exclusão",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF365782),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Você tem certeza que deseja excluir '$title'?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF365782),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF365782),
                          side: const BorderSide(color: Color(0xFF365782)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          try {
                            await _controller.deleteActivity(itemId);

                            Navigator.of(context).pop();
                            _loadUserAndActivities();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$title excluído com sucesso!'),
                              ),
                            );
                          } catch (e) {
                            print('Erro ao excluir tarefa: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Erro ao excluir a tarefa.'),
                              ),
                            );
                          }
                        },
                        child: const Text('Excluir'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
