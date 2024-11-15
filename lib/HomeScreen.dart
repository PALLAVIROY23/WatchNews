import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class Homescreen extends ConsumerWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
  body: Center(
    child: Text("HomeView is Working"),
  ),
    );
  }
}