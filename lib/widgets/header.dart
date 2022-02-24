import 'package:flutter/material.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> actions;

  const BaseAppBar({Key key, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: const Text(
            'Cerealis',
            style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                fontSize: 30
            )
        ),
      backgroundColor: Colors.amber.shade600,
      actions: actions,
      leading: Image.asset("assets/images/header.png")
    );
  }


  @override
  Size get preferredSize {
    var appBar = AppBar();
    return new Size.fromHeight(appBar.preferredSize.height);
  }
}
