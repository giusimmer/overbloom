import 'dart:developer';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../components/base_screen.dart';
import '../../service/firebase_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  AddScreenState createState() => AddScreenState();
}

class AddScreenState extends State<AddScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _titleController = TextEditingController();

  final List<Color> colorOptions = [
    Color(0xFF9563BD),
    Color(0xFF6080AF),
    Color(0xFF84AB66),
    Color(0xFFDC6666),
    Color(0xFFD9C143),
  ];
  Color selectedColor = Color(0xFF9563BD);
  int selectedHour = TimeOfDay.now().hour;
  int selectedDurationIndex = 0;
  final List<String> durationOptions = ["1m", "15m", "30m", "45m", "1h"];
  int selectedFrequencyIndex = 0;
  List<String> frequencyOptions = [
    "Único",
    "Diário",
    "Semanal",
    "Mensal"
  ];

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = selectedColor;
        return AlertDialog(
          title: const Text("Escolha uma Cor"),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                tempColor = color;
              },
              showLabel: false,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Selecionar"),
              onPressed: () {
                setState(() {
                  selectedColor = tempColor;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildColorSelectorCard() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...colorOptions.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = color;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: _openColorPicker,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.indigo,
                    Colors.purple,
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 5),
          child: Text(
            "Quando?",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF686868),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 160,
                  height: 100,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController:
                        FixedExtentScrollController(initialItem: selectedHour),
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        selectedHour = index;
                      });
                    },
                    selectionOverlay: Container(),
                    children: List<Widget>.generate(24, (int index) {
                      bool isSelected = index == selectedHour;
                      return Center(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          alignment: Alignment.center,
                          decoration: isSelected
                              ? BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                )
                              : null,
                          child: Text(
                            '${index.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    // Ação do botão
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        "Notificar",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDurationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 5),
          child: Text(
            "Duração",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF686868),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          decoration: BoxDecoration(
            color: Color(0xFF5C5C5C),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: durationOptions.asMap().entries.map((entry) {
              int index = entry.key;
              String text = entry.value;
              bool isSelected = index == selectedDurationIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDurationIndex = index;
                  });
                },
                child: Container(
                padding: const EdgeInsets.fromLTRB(15, 3, 15, 3),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              );
            },
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildFrequencyPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 5),
          child: Text(
            "Frequência",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF686868),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          decoration: BoxDecoration(
            color: Color(0xFF5C5C5C),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: frequencyOptions.asMap().entries.map((entry) {
              int index = entry.key;
              String text = entry.value;
              bool isSelected = index == selectedFrequencyIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFrequencyIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Image.asset(
                                'assets/images/arrow_back.png',
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                left: 4,
                                child: ImageFiltered(
                                  imageFilter:
                                      ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Image.asset(
                                    'assets/images/name_app.png',
                                    width: 250,
                                    color: Colors.white.withOpacity(0.9),
                                    colorBlendMode: BlendMode.srcATop,
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/images/name_app.png',
                                width: 250,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: selectedColor,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      textAlign: TextAlign.right,
                                      controller: _titleController,
                                      decoration: InputDecoration(
                                        hintText: "Título",
                                        hintStyle: const TextStyle(
                                            color: Color(0xFF5C5C5C),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                        enabledBorder:
                                            const UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        fillColor: Colors.transparent,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),
                              buildColorSelectorCard(),
                              const SizedBox(height: 25),
                              buildTimePicker(),
                              const SizedBox(height: 25),
                              buildDurationPicker(),
                              const SizedBox(height: 25),
                              buildFrequencyPicker(),
                              const SizedBox(height: 60),
                              ElevatedButton(
                                onPressed: () async {
                                  String? userId =
                                      FirebaseAuth.instance.currentUser?.uid;

                                  if (userId != null &&
                                      _titleController.text.isNotEmpty) {
                                    Map<String, dynamic> newItem = {
                                      "title": _titleController.text,
                                      "color": selectedColor.value,
                                      "hour": selectedHour,
                                      "duration": durationOptions[
                                          selectedDurationIndex],
                                      "frequency": frequencyOptions[
                                          selectedFrequencyIndex],
                                      "createdAt": DateTime.now(),
                                    };

                                    await _firebaseService.addActivity(
                                        userId, newItem);

                                    Navigator.pop(context);
                                  } else {
                                    log("Erro: Usuário não autenticado ou título vazio.");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 70),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(45),
                                  ),
                                ),
                                child: const Text(
                                  "Adicionar",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF797777),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
