import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'cart_counter.dart';

class CounterWithFavBtn extends StatelessWidget {
  const CounterWithFavBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[

        Container(
          padding: const EdgeInsets.all(8),
          height: 32,
          width: 32
        )
      ],
    );
  }
}
