import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/widgets/circle_color.dart';

class CheckColor extends StatefulWidget {
  const CheckColor({Key? key}) : super(key: key);

  @override
  State<CheckColor> createState() => _CheckColorState();
}

class _CheckColorState extends State<CheckColor> {
  Color? pickedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pickedColor != null)
          CircleColor(
            color: pickedColor!,
            showText: false,
            height: 80,
            width: 80,
          ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check color hex',
                  style: kStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 100,
                  width: 150,
                  child: TextField(
                    cursorRadius: const Radius.circular(12),
                    cursorColor: const Color(0xff6C4AB6),
                    scrollPadding: EdgeInsets.zero,
                    cursorWidth: 5,
                    cursorHeight: 30,
                    maxLength: 8,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textAlign: TextAlign.center,
                    style: kStyle.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xffB9E0FF),
                          width: 5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length < 6) {
                        setState(() {
                          pickedColor = null;
                        });
                        return;
                      }
                      if (value.startsWith('#')) {
                        value = value.substring(1);
                        value = '0xff$value';
                      } else if (value.startsWith('0x')) {
                        value = '0x$value';
                      } else {
                        value = '0xff$value';
                      }

                      setState(() {
                        try {
                          pickedColor = Color(int.parse(value));
                        } catch (e) {
                          pickedColor = null;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
