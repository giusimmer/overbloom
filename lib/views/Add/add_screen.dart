import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../components/base_screen.dart';
import '../../controller/activity_controller.dart';
import '../Home/home_screen.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  AddScreenState createState() => AddScreenState();
}

class AddScreenState extends State<AddScreen> {
  final ActivityController _controller = ActivityController();
  final TextEditingController _titleController = TextEditingController();

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = _controller.selectedColor;
        return AlertDialog(
          title: const Text("Escolha uma Cor"),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _controller.selectedColor,
              onColorChanged: (color) {
                tempColor = color;
              },
              // showLabel: false,
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
                  _controller.setSelectedColor(tempColor);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorSelectorCard() {
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
          ..._controller.colorOptions.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _controller.setSelectedColor(color);
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
                    color: _controller.selectedColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
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
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hora picker
                SizedBox(
                  width: 80,
                  height: 100,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: _controller.selectedHour,
                    ),
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        _controller.setSelectedHour(index);
                      });
                    },
                    selectionOverlay: Container(),
                    children: List<Widget>.generate(24, (int index) {
                      final isSelected = index == _controller.selectedHour;
                      return Center(
                        child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          decoration: isSelected
                              ? BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                )
                              : null,
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // ":" centralizado com mesma altura e estilo
                SizedBox(
                  width: 40,
                  height: 100,
                  child: Center(
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Text(
                        ':',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Minuto picker
                SizedBox(
                  width: 80,
                  height: 100,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: _controller.selectedMinute ~/ 30,
                    ),
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        _controller.setSelectedMinute(index * 30);
                      });
                    },
                    selectionOverlay: Container(),
                    children: List<Widget>.generate(2, (int index) {
                      final minute = (index * 30).toString().padLeft(2, '0');
                      final isSelected =
                          _controller.selectedMinute == (index * 30);
                      return Center(
                        child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          decoration: isSelected
                              ? BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                )
                              : null,
                          child: Text(
                            minute,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationPicker() {
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
            children: _controller.durationOptions.asMap().entries.map(
              (entry) {
                int index = entry.key;
                String text = entry.value;
                bool isSelected = index == _controller.selectedDurationIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.setSelectedDurationIndex(index);
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

  Widget _buildFrequencyPicker() {
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
            children: _controller.frequencyOptions.asMap().entries.map((entry) {
              int index = entry.key;
              String text = entry.value;
              bool isSelected = index == _controller.selectedFrequencyIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.setSelectedFrequencyIndex(index);
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Image.asset(
                          'assets/images/icon/arrow_back.png',
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
                                color: _controller.selectedColor,
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
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  fillColor: Colors.transparent,
                                  filled: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        _buildColorSelectorCard(),
                        const SizedBox(height: 25),
                        _buildTimePicker(),
                        const SizedBox(height: 25),
                        _buildDurationPicker(),
                        const SizedBox(height: 25),
                        _buildFrequencyPicker(),
                        const SizedBox(height: 60),
                        ElevatedButton(
                          onPressed: () async {
                            if (_titleController.text.isNotEmpty) {
                              bool success = await _controller
                                  .addActivity(_titleController.text);

                              if (success) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Horário já ocupado por outra atividade.'),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Coloque um Título para sua tarefa!'),
                                ),
                              );
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
                        SizedBox(height: 10)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
