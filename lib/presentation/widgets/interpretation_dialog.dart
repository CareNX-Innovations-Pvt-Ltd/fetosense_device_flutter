import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/widgets/custom_radio_btn.dart';
import 'package:flutter/material.dart';

class InterpretationDialog extends StatefulWidget {
  final Test? test;

  final String? value;

  Function(String, String, bool)? callback;

  InterpretationDialog(
      {super.key, required this.test, this.value, this.callback});

  @override
  State<StatefulWidget> createState() => _InterpretationDialog();
}

class _InterpretationDialog extends State<InterpretationDialog> {
  late String radioValue;

  late String comments;

  @override
  void initState() {
    super.initState();
    radioValue = widget.value ?? '';
    comments = widget.test!.interpretationExtraComments ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  Widget dialogContent(context) {
    return Wrap(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border(bottom: BorderSide(color: Colors.grey)),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 0, 8),
                  child: Text(
                    "Update Interpretations",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomRadioBtn(
                  buttonColor: Theme.of(context).canvasColor,
                  buttonLables: const [
                    "Normal",
                    "Abnormal",
                    "Atypical",
                  ],
                  buttonValues: const [
                    "Normal",
                    "Abnormal",
                    "Atypical",
                  ],
                  enableAll: true,
                  defaultValue: widget.value,
                  radioButtonValue: (value) => _handleRadioClick(value),
                  selectedColor: Colors.blue,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  maxLines: 4,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  initialValue: comments,
                  onChanged: (value) => comments = value.trim(),
                  decoration: const InputDecoration(hintText: 'Extra Comments'),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border(top: BorderSide(color: Colors.grey)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      // flex: 1,
                      child: MaterialButton(
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () {
                          widget.callback!(radioValue, comments, false);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const Text(
                      "|",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
                    Expanded(
                      // flex: 1,
                      child: MaterialButton(
                        child: const Text('Update',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 18)),
                        //shape: OutlineInputBorder(),
                        onPressed: () {
                          widget.callback!(radioValue, comments, true);
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void _handleRadioClick(String value) {
    if (radioValue == value) {
      return;
    } else {
      setState(() {
        radioValue = value;
      });
    }
  }
}
