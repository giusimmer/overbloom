import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:overbloom/components/base_screen.dart';
import 'package:overbloom/views/Home/home_screen.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreen();
}

class _InfoScreen extends State<InfoScreen> {
  final PageController _pageController = PageController();
  int _paginaAtual = 0;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      fundo: "principal_fundo.png",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
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
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                setState(() {
                  _paginaAtual = index;
                });
              },
                children: [
                  _buildPage([
                    _buildMessageContainer(
                      text: "A CADA TAREFA CUMPRIDA VOCÊ RECEBE MOEDAS",
                      imagePath: 'assets/images/icon/moeda.png',
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _buildMessageContainer(
                      text:
                          "A cada semana concluindo todas as tarefas você ganha estrelas",
                      imagePath: 'assets/images/icon/estrela.png',
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _buildMessageContainer(
                      text: "Com estrelas você pode mudar a cor do seu pet",
                      imagePath: 'assets/images/pets/verde.png',
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _buildMessageContainer(
                      text:
                          "com moedas você pode mudar para avatares especiais",
                      imagePath: 'assets/images/perfil/defaut.png',
                    ),
                  ]),
                  _buildPage([
                    _buildMessageContainer2(
                      text: "Clicando na ",
                      imagePath: 'assets/images/icon/estrela.png',
                      text2:
                          " você poderá ter acesso a tela de compras para alterar seu \n pet ",
                      imagePath2: 'assets/images/pets/verde.png',
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _buildMessageContainer3(
                      text:
                          "Clicando no seu avatar \n você terá acesso a \n suas moedas, onde \n pode realizar a \n compra de novos \n avatares ",
                      imagePath: 'assets/images/perfil/defaut.png',
                      text2: "",
                      imagePath2: 'assets/images/icon/moeda.png',
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _buildMessageContainer4(
                      text:
                          "clicando no icone de \n carta você pode enviar \n uma mensagem a um \n amigo",
                      imagePath: 'assets/images/icon/mensagem.png',
                    ),
                  ]),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                if (_paginaAtual == 0) {
                  _pageController.animateToPage(
                    1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _pageController.animateToPage(
                    0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: AnimatedRotation(
                turns: _paginaAtual == 1 ? 0.5 : 0,
                duration: Duration(milliseconds: 300),
                child: Image.asset(
                  'assets/images/buttons/next_button.png',
                  width: 280,
                  height: 95,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 2,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.black,
                  dotColor: Colors.grey.withOpacity(0.5),
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(List<Widget> cards) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cards,
        ),
      ),
    );
  }

  Widget _buildMessageContainer({
    required String text,
    required String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              text.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Image.asset(imagePath),
        ],
      ),
    );
  }

  Widget _buildMessageContainer2({
    required String text,
    required String imagePath,
    required String text2,
    required String imagePath2,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: text.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              // Imagem estrela
              WidgetSpan(
                child: Image.asset(
                  imagePath,
                  width: 30,
                  height: 30,
                ),
              ),
              TextSpan(
                text: text2.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              WidgetSpan(
                child: Image.asset(
                  imagePath2,
                  width: 30,
                  height: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContainer3({
    required String text,
    required String imagePath,
    required String text2,
    required String imagePath2,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              width: 60,
              height: 60,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: text.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: text2.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  WidgetSpan(
                    child: Image.asset(
                      imagePath2,
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContainer4({
    required String text,
    required String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
          child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 50,
            height: 50,
          ),
          Text(
            textAlign: TextAlign.center,
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      )),
    );
  }
}
