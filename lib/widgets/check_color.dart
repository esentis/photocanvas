import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photocanvas/constants.dart';
import 'package:photocanvas/widgets/circle_color.dart';

class CheckColor extends StatefulWidget {
  const CheckColor({super.key});

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
          )
        else
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              height: 80,
              width: 80,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    'Check color hex',
                    style: kStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kColorText,
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  width: 150,
                  child: TextField(
                    cursorRadius: const Radius.circular(12),
                    cursorColor: kColorTextFieldBorder,
                    scrollPadding: EdgeInsets.zero,
                    cursorWidth: 5,
                    cursorHeight: 30,
                    maxLength: 8,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textAlign: TextAlign.center,
                    style: kStyle.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: kColorTextFieldBorder,
                      height: 1,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      fillColor: kColorAppBar,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: kColorTextFieldBorder,
                          width: 5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: kColorTextFieldBorder,
                          width: 2,
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
