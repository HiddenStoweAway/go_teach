import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Nav{
  static void go(BuildContext context, String route){
    if (GoRouterState.of(context).matchedLocation == route) return;
    context.go(route);
  }
}