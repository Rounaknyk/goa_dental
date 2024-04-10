import 'package:flutter/material.dart';


class SearchBox extends StatefulWidget {
  SearchBox({required this.onChanged, this.text = '',});
  String text;
  Function onChanged;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Color(0xFFF4F2FD), borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: TextField(
          onChanged: (newValue){
            widget.onChanged(newValue);
          },
          controller: _controller,
          decoration: InputDecoration(
              hintText: 'Search medical...',
              border: InputBorder.none,
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              suffixIcon: Image.asset('assets/tooth.png'),
              suffixIconColor: Colors.black,
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.4))),
        ),
      ),
    );
  }
}