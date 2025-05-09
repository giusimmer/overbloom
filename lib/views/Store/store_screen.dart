import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/animated_currency_counter.dart';
import '../../controller/store_controller.dart';
import '../../models/store_model.dart';
import '../Home/home_screen.dart';
import '../SendMenssage/send_message_screen.dart';

class StoreScreen extends StatefulWidget {
  final String type; // 'avatar' ou 'pet'

  const StoreScreen({super.key, required this.type});

  @override
  StoreScreenState createState() => StoreScreenState();
}

class StoreScreenState extends State<StoreScreen> {
  final StoreController _controller = StoreController();
  List<StoreModel> _products = [];
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.type == 'pet') {
      _checkForRewards();
    }
  }

  Future<void> _loadData() async {
    final products = _controller.loadLocalProducts(widget.type);
    final user = await _controller.loadUserInfoFromFirebase();

    final updatedProducts =
        _controller.updateProductsStatus(products, user, widget.type);

    setState(() {
      _products = updatedProducts;
      _user = user;
      _isLoading = false;
    });
  }

  void _checkForRewards() {
    _controller.checkAndRewardUser(() {
      _showRewardMessage();
    });
  }

  void _showRewardMessage() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFFE3F5F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              '🎉 Parabéns!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B74A7),
              ),
            ),
            content: const Text(
              'Você completou todas as atividades da semana passada e ganhou 1 estrela! ⭐',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6B74A7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  _loadData();
                  Navigator.pop(context);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  void _selectProduct(int index) {
    final product = _products[index];

    if (product.purchased) {
      _controller.selectProduct(product, _user!, widget.type, (updatedUser) {
        setState(() {
          _user = updatedUser;
          _products = _controller.updateProductsStatus(
              _products, updatedUser, widget.type);
        });
      }, (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      });
    } else {
      _showPurchaseConfirmation(product);
    }
  }

  void _showPurchaseConfirmation(StoreModel product) {
    int currentBalance =
        widget.type == 'avatar' ? _user!.numCoins : _user!.numStars;
    if (currentBalance < product.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Você não tem saldo suficiente!")),
      );
      return;
    }

    int newBalance = currentBalance - product.price;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFE3F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "🛒 Finalizar Compra",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B74A7),
            ),
          ),
          content: Text(
            "💰 Saldo atual: $currentBalance\n"
            "🛍️ Saldo após a compra: $newBalance\n\n"
            "Deseja finalizar a compra?",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6B74A7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
                _controller.selectProduct(product, _user!, widget.type,
                    (updatedUser) {
                  setState(() {
                    _user = updatedUser;
                    _products = _controller.updateProductsStatus(
                        _products, updatedUser, widget.type);
                  });
                }, (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                });
              },
              child: const Text(
                "Confirmar",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/fundo/principal_fundo.png',
                fit: BoxFit.cover,
              ),
            ),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo/principal_fundo.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              _buildCurrencyCounter(),
              _buildProductGrid(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
                    builder: (context) => widget.type == 'avatar'
                        ? const HomeScreen()
                        : SendMessageScreen(currentUserId: _controller.userId),
                  ),
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
    );
  }

  Widget _buildCurrencyCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/cenario/moldura_moeda.png',
              width: 120,
              height: 90,
            ),
            AnimatedCurrencyCounter(
              value:
                  widget.type == 'avatar' ? _user!.numCoins : _user!.numStars,
              currencyIcon: widget.type == 'avatar'
                  ? 'assets/images/icon/moeda.png'
                  : 'assets/images/icon/estrela.png',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          itemCount: _products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 0.0,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final product = _products[index];

            return GestureDetector(
              onTap: () => _selectProduct(index),
              child: Card(
                color: product.selected
                    ? Colors.green[200]
                    : Colors.white.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!product.selected)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            product.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!product.purchased && !product.selected)
                            Image.asset(
                              product.currencyIcon,
                              height: 20,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            product.selected
                                ? 'Selecionado'
                                : product.purchased
                                    ? 'Selecionar'
                                    : '${product.price}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
