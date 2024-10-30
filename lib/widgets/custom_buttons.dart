import 'package:flutter/material.dart';

import '../master.dart';

class CreateGradientButton extends StatelessWidget {
  final String text;
  final GestureTapCallback onTap;
  final double width;
  final bool isRounded;

  const CreateGradientButton(
      {Key? key,
      required this.text,
      required this.onTap,
      required this.width,
      this.isRounded = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [blue, blueGrey],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(isRounded ? 25 : 10),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: width, minHeight: 50.0),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class CreateMaterialButton extends StatelessWidget {
  final String text;
  final GestureTapCallback onTap;
  final double width;

  const CreateMaterialButton(
      {Key? key, required this.text, required this.onTap, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
          side: const BorderSide(color: black)),
      minWidth: width,
      height: getHeight(context) * .05,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: pColor, fontSize: 15, fontWeight: FontWeight.w400),
      ),
    );
  }
}

class CreateCustomButton extends StatelessWidget {
  final String text;
  final Color textColor, buttonColor;
  final GestureTapCallback onTap;
  final double? width, height;
  final bool isRound;

  const CreateCustomButton(
      {Key? key,
      required this.text,
      this.textColor = white,
      this.buttonColor = pColor,
      required this.onTap,
      this.width,
      this.height,
      this.isRound = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      shape: RoundedRectangleBorder(
          borderRadius:
              isRound ? BorderRadius.circular(20) : BorderRadius.circular(5)),
      minWidth: width,
      height: height,
      color: buttonColor,
      textColor: textColor,
      elevation: 0,
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}

class CreateSearchButton extends StatelessWidget {
  const CreateSearchButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TextButton(
          onPressed: () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => const SearchPage()));
          },
          child: const Row(
            children: [
              Icon(Icons.search, color: grey),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Type here for search..',
                  style: TextStyle(fontWeight: FontWeight.w500, color: grey),
                ),
              )
            ],
          )),
    );
  }
}

class CustomRoundedButton extends StatelessWidget {
  final String buttonText;
  final double width;
  final Function onpressed;
  final LinearGradient linearGradient;

  const CustomRoundedButton({
    Key? key,
    required this.buttonText,
    this.width = 120,
    required this.onpressed,
    this.linearGradient = blueLinearGradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 5.0,
            )
          ],
          gradient: linearGradient,
          borderRadius: BorderRadius.circular(40),
        ),
        child: ElevatedButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            splashFactory: NoSplash.splashFactory,
            minimumSize: WidgetStateProperty.all(Size(width, 0)),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
          ),
          onPressed: () {
            onpressed();
          },
          child: Text(
            buttonText,
            style: const TextStyle(
              color: white,
            ),
          ),
        ),
      ),
    );
  }
}

const LinearGradient blueLinearGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 1.0],
  colors: [
    Color(0xffFF912C),
    Color(0xffAB6211),
  ],
);
