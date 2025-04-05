import 'package:flutter/material.dart';

class CustomRadioBtn extends StatefulWidget {
  CustomRadioBtn(
      {super.key, this.buttonLables,
      this.buttonValues,
      this.radioButtonValue,
      this.buttonColor,
      this.selectedColor,
      this.defaultValue,
      this.hight = 35,
      this.width = 100,
      this.horizontal = false,
      this.enableShape = false,
      this.elevation = 4,
      this.customShape,
      this.enableAll})
      : assert(buttonLables!.length == buttonValues!.length),
        assert(buttonColor != null),
        assert(selectedColor != null);

  final bool? horizontal;

  final List? buttonValues;

  final double? hight;
  final double? width;

  final List<String>? buttonLables;

  final Function(dynamic)? radioButtonValue;

  final Color? selectedColor;
  final String? defaultValue;

  final Color? buttonColor;
  final ShapeBorder? customShape;
  final bool? enableShape;
  final double? elevation;
  final bool? enableAll;


  @override
  _CustomRadioButtonState createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioBtn> {
  int currentSelected = 0;
  static String? currentSelectedLabel;


  @override
  void initState() {
    super.initState();

    currentSelectedLabel = widget.defaultValue ?? "";
  }

  List<Widget> buildButtonsColumn() {
    List<Widget> buttons = [];
    for (int index = 0; index < widget.buttonLables!.length; index++) {
      var button = Expanded(
        // flex: 1,
        child: Card(
          color: currentSelectedLabel == widget.buttonLables![index]
              ? widget.selectedColor
              : widget.buttonColor,
          elevation: widget.elevation,
          shape: widget.enableShape!
              ? widget.customShape ?? const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    )
              : null,
          child: SizedBox(
            height: widget.hight,
            child: MaterialButton(
              shape: widget.enableShape!
                  ? widget.customShape ?? OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor, width: 1),
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                        )
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
              onPressed: widget.enableAll!
                  ? () {
                      widget.radioButtonValue!(widget.buttonValues![index]);
                      setState(() {
                        currentSelected = index;
                        currentSelectedLabel = widget.buttonLables![index];
                      });
                    }
                  : () {},

              child: Text(
                widget.buttonLables![index],
                style: TextStyle(
                  color: currentSelectedLabel == widget.buttonLables![index]
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      );
      buttons.add(button);
    }
    return buttons;
  }

  List<Widget> buildButtonsRow() {
    List<Widget> buttons = [];
    for (int index = 0; index < widget.buttonLables!.length; index++) {
      var button = Expanded(
        // flex: 1,
        child: Card(
          color: currentSelectedLabel == widget.buttonLables![index]
              ? widget.selectedColor
              : widget.buttonColor,
          elevation: widget.elevation,
          shape: widget.enableShape!
              ? widget.customShape ?? const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    )
              : null,
          child: Container(
            height: widget.hight,
            // width: 200,
            constraints: const BoxConstraints(maxWidth: 200),
            child: MaterialButton(
              shape: widget.enableShape!
                  ? widget.customShape ?? OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor, width: 1),
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                        )
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
              onPressed: widget.enableAll!? () {
                widget.radioButtonValue!(widget.buttonValues![index]);
                setState(() {
                  currentSelected = index;
                  currentSelectedLabel = widget.buttonLables![index];
                });
              } : () {

                widget.radioButtonValue!(widget.buttonValues![currentSelected]);
              },
              child: Text(
                widget.buttonLables![index],
                style: TextStyle(
                  color: currentSelectedLabel == widget.buttonLables![index]
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      );
      buttons.add(button);
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.horizontal!
          ? widget.hight! * (widget.buttonLables!.length + 0.5)
          : null,
      child: Center(
        child: widget.horizontal!
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: buildButtonsColumn(),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buildButtonsRow(),
              ),
      ),
    );

    // return Container(
    //   height: 50,
    //   child: ListView.builder(
    //     itemCount: widget.buttonLables.length,
    //     scrollDirection: Axis.horizontal,
    //     itemBuilder: (context, index) => Card(
    //       color: index == currentSelected
    //           ? widget.selectedColor
    //           : widget.buttonColor,
    //       elevation: 10,
    //       shape: kRoundedButtonShape,
    //       child: Container(
    //         height: 40,
    //         // width: 200,
    //         constraints: BoxConstraints(maxWidth: 250),
    //         child: MaterialButton(
    //           // minWidth: 300,
    //           // elevation: 10,
    //           shape: kRoundedButtonShape,
    //           onPressed: () {
    //             widget.radioButtonValue(widget.buttonValues[index]);
    //             setState(() {
    //               currentSelected = index;
    //             });
    //           },
    //           child: Text(
    //             widget.buttonLables[index],
    //             style: TextStyle(
    //               color: index == currentSelected
    //                   ? Colors.white
    //                   : Theme.of(context).textTheme.body1.color,
    //               fontSize: 15,
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
