import 'package:flutter/material.dart';

class PreferenceText extends StatelessWidget {
  final String text;

  final TextStyle? style;
  final Decoration? decoration;

  final Widget? leading;
  final Text? subtitle;

  final Function? onTap;

  final TextOverflow overflow;

  PreferenceText(
    this.text, {
    this.style,
    this.decoration,
    this.leading,
    this.subtitle,
    this.onTap,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      child: ListTile(
        leading: leading,
        onTap: onTap as void Function()?,
        title: Text(
          text,
          style: style,
          overflow: overflow,
        ),
        subtitle: subtitle,
      ),
    );
  }
}
