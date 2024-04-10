import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/custom_widgets/custom_button.dart';
import 'package:goa_dental_clinic/custom_widgets/tooth.dart';

class ToothSelectionWidget extends StatefulWidget {
  final int numberOfTeeth;
  Function(List<dynamic>) onDone;
  List<dynamic>? tList;
  ToothSelectionWidget(
      {required this.numberOfTeeth, required this.onDone, this.tList = null});

  @override
  State<ToothSelectionWidget> createState() => _ToothSelectionWidgetState();
}

class _ToothSelectionWidgetState extends State<ToothSelectionWidget> {
  List<dynamic> toothList = [];

  bool isSelected(toothNumber) {
    bool selected = true;
    toothList.forEach((element) {
      if (element == toothNumber) {
        selected = false;
      }
    });
    return selected;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    if (widget.tList != null) {
      toothList = widget.tList!;
    }

    Fluttertoast.showToast(
        msg: "For wider view, switch to landscape mode!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    print(orientation);
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            height: (orientation == Orientation.portrait) ? MediaQuery.of(context).size.height * 0.5 : MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: (orientation == Orientation.portrait)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListView.builder(
                              itemBuilder: (context, index) {
                                var newIndex = 28 - index;
                                bool initialValue = false;
                                toothList.forEach((element) {
                                  if (element == newIndex) {
                                    initialValue = true;
                                  }
                                });
                                return Padding(
                                  padding: const EdgeInsets.all(0.5),
                                  child: Tooth(
                                      index: newIndex,
                                      initialValue: initialValue,
                                      onTap: (toothNumber, isSelected) {
                                        // print(toothNumber);
                                        if (!isSelected) {
                                          toothList.remove(toothNumber);
                                        } else {
                                          toothList.add(toothNumber);
                                        }
                                        // toothList.add(toothNumber);
                                      }),
                                );
                              },
                              itemCount: 8,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListView.builder(
                              itemBuilder: (context, index) {
                                var newIndex = 11 + index;
                                bool initialValue = false;
                                toothList.forEach((element) {
                                  if (element == newIndex) {
                                    initialValue = true;
                                  }
                                });
                                return Padding(
                                  padding: const EdgeInsets.all(1.5),
                                  child: Tooth(
                                      index: newIndex,
                                      initialValue: initialValue,
                                      onTap: (toothNumber, isSelected) {
                                        // print(toothNumber);
                                        if (!isSelected) {
                                          toothList.remove(toothNumber);
                                        } else {
                                          toothList.add(toothNumber);
                                        }
                                        // toothList.add(toothNumber);
                                      }),
                                );
                              },
                              itemCount: 8,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListView.builder(
                              itemBuilder: (context, index) {
                                var newIndex = 38 - index;
                                bool initialValue = false;
                                toothList.forEach((element) {
                                  if (element == newIndex) {
                                    initialValue = true;
                                  }
                                });
                                return Tooth(
                                    index: newIndex,
                                    initialValue: initialValue,
                                    onTap: (toothNumber, isSelected) {
                                      // print(toothNumber);
                                      if (!isSelected) {
                                        toothList.remove(toothNumber);
                                      } else {
                                        toothList.add(toothNumber);
                                      }
                                      // toothList.add(toothNumber);
                                    });
                              },
                              itemCount: 8,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListView.builder(
                              itemBuilder: (context, index) {
                                var newIndex = 41 + index;
                                bool initialValue = false;
                                toothList.forEach((element) {
                                  if (element == newIndex) {
                                    initialValue = true;
                                  }
                                });
                                return Tooth(
                                    index: newIndex,
                                    initialValue: initialValue,
                                    onTap: (toothNumber, isSelected) {
                                      // print(toothNumber);
                                      if (!isSelected) {
                                        toothList.remove(toothNumber);
                                      } else {
                                        toothList.add(toothNumber);
                                      }
                                      // toothList.add(toothNumber);
                                    });
                              },
                              itemCount: 8,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                            ),
                          ],
                        ),
                      ), //
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: CustomButton(
                              text: 'Done',
                              backgroundColor: kPrimaryColor,
                              onPressed: () {
                                  widget.onDone(toothList);
                                  Navigator.pop(context);
                              }),
                          height: 60,
                        ),
                      ),
                    ],
                  )
                : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemBuilder: (context, index) {
                                      var newIndex = 28 - index;
                                      bool initialValue = false;
                                      toothList.forEach((element) {
                                        if (element == newIndex) {
                                          initialValue = true;
                                        }
                                      });
                                      return Padding(
                                        padding: const EdgeInsets.all(0.5),
                                        child: Tooth(
                                            index: newIndex,
                                            initialValue: initialValue,
                                            onTap: (toothNumber, isSelected) {
                                              // print(toothNumber);
                                              if (!isSelected) {
                                                toothList.remove(toothNumber);
                                              } else {
                                                toothList.add(toothNumber);
                                              }
                                              // toothList.add(toothNumber);
                                            }),
                                      );
                                    },
                                    itemCount: 8,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      ListView.builder(
                                        itemBuilder: (context, index) {
                                          var newIndex = 11 + index;
                                          bool initialValue = false;
                                          toothList.forEach((element) {
                                            if (element == newIndex) {
                                              initialValue = true;
                                            }
                                          });
                                          return Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Tooth(
                                                index: newIndex,
                                                initialValue: initialValue,
                                                onTap: (toothNumber, isSelected) {
                                                  // print(toothNumber);
                                                  if (!isSelected) {
                                                    toothList.remove(toothNumber);
                                                  } else {
                                                    toothList.add(toothNumber);
                                                  }
                                                  // toothList.add(toothNumber);
                                                }),
                                          );
                                        },
                                        itemCount: 8,
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemBuilder: (context, index) {
                                      var newIndex = 38 - index;
                                      bool initialValue = false;
                                      toothList.forEach((element) {
                                        if (element == newIndex) {
                                          initialValue = true;
                                        }
                                      });
                                      return Tooth(
                                          index: newIndex,
                                          initialValue: initialValue,
                                          onTap: (toothNumber, isSelected) {
                                            // print(toothNumber);
                                            if (!isSelected) {
                                              toothList.remove(toothNumber);
                                            } else {
                                              toothList.add(toothNumber);
                                            }
                                            // toothList.add(toothNumber);
                                          });
                                    },
                                    itemCount: 8,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          itemBuilder: (context, index) {
                                            var newIndex = 41 + index;
                                            bool initialValue = false;
                                            toothList.forEach((element) {
                                              if (element == newIndex) {
                                                initialValue = true;
                                              }
                                            });
                                            return Tooth(
                                                index: newIndex,
                                                initialValue: initialValue,
                                                onTap: (toothNumber, isSelected) {
                                                  // print(toothNumber);
                                                  if (!isSelected) {
                                                    toothList.remove(toothNumber);
                                                  } else {
                                                    toothList.add(toothNumber);
                                                  }
                                                  // toothList.add(toothNumber);
                                                });
                                          },
                                          itemCount: 8,
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: CustomButton(
                                  text: 'Done',
                                  backgroundColor: kPrimaryColor,
                                  onPressed: () {
                                    var ori = MediaQuery.of(context).orientation;

                                    if(ori == Orientation.landscape) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Switch back to Portrait Mode to Submit"),),);
                                      Fluttertoast.showToast(
                                          msg: "Switch back to Portrait Mode to Submit",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0
                                      );
                                    }
                                    else{
                                      widget.onDone(toothList);
                                      Navigator.pop(context);
                                    }
                                  }),
                              height: 60,
                            ),
                          ),
                        ],
                      ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class ToothBlock extends StatelessWidget {
  final int number;

  const ToothBlock({Key? key, required this.number}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
