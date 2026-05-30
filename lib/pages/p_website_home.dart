import 'package:adobe_app/pages/p_auth/p_login.dart';
import 'package:adobe_app/pages/p_how_it_works.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key, required this.title});

  final String title;

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  int pageIndex = 0;

  Widget mainHomePage() {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
        child: Column(
          children: [
            SizedBox(height: 50),

            MyTitle(
              text: "Welcome to LEALO",
              fontSize: 30,
              color: Theme.of(context).primaryColor,
            ),

            SizedBox(height: 15),

            Container(
              width: 1000,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 25.0,
                ),
                child: Column(
                  children: [
                    Text(
                      "LEALO is devoted to raising the equity in education in schools"
                      " without enough teachers so that students get the support they need.",
                      textAlign: TextAlign.center,
                      style: TextStyle(),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 50),

            MyTitle(text: "Sustainable Development Goal 4", fontSize: 18.0),

            SizedBox(height: 15),

            Container(
              width: 1000,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 25.0,
                ),
                child: Column(
                  children: [
                    Text(
                      "SDG 4 is all about equitable education in schools."
                      "This means giving all students the education they need in order to thrive and learn appropriately. "
                      "\nThe goal is to make it so all students recieve the individual attention they need from a teacher in order to learn at their own pace\n",
                      textAlign: TextAlign.center,
                      style: TextStyle(),
                    ),

                    MyTitle(text: "The Problem: "),
                    Text(
                      "Right now U.S schools are underfunded, and there's not enough teachers. "
                      "Teachers have to focus on 20+ kids who all have different levels of background knowledge who learn at different paces. ",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget featuresPage() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 50),

          Container(
            width: 1000,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 25.0,
              ),
              child: Column(
                children: [
                  MyTitle(text: "Feature 1: AI Direct Teaching", fontSize: 18),

                  SizedBox(height: 15),

                  Text(
                    "LEALO directly connects the AI to the student, and teaches the student to their own pace."
                    " While the curriculum is preset, the AI can pace out and assign to the student based off of how the student is doing,"
                    " and will review with the student as it sees fit.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 75),

          Container(
            width: 1000,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 25.0,
              ),
              child: Column(
                children: [
                  MyTitle(text: "Feature 1: AI Direct Teaching", fontSize: 18),

                  SizedBox(height: 15),

                  Text(
                    "LEALO directly connects the AI to the student, and teaches the student to their own pace."
                    " While the curriculum is preset, the AI can pace out and assign to the student based off of how the student is doing,"
                    " and will review with the student as it sees fit.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 75),

          Container(
            width: 1000,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 25.0,
              ),
              child: Column(
                children: [
                  MyTitle(text: "Feature 1: AI Direct Teaching", fontSize: 18),

                  SizedBox(height: 15),

                  Text(
                    "LEALO directly connects the AI to the student, and teaches the student to their own pace."
                    " While the curriculum is preset, the AI can pace out and assign to the student based off of how the student is doing,"
                    " and will review with the student as it sees fit.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = {
      0: mainHomePage(),
      1: featuresPage(),
      4: HowItWorks(),
      5: LoginPage(),
    };

    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: TextButton(
          onPressed: () {
            setState(() {
              pageIndex = 0;
            });
          },
          child: MyTitle(text: widget.title, fontSize: 25),
        ),
        actions: [
          // HOW IT WORKS BUTTON
          TextButton(
            onPressed: () {
              setState(() {
                pageIndex = 4;
              });
            },
            child: Text("How it Works"),
          ),

          TextButton(
            onPressed: () {
              setState(() {
                pageIndex = 1;
              });
            },
            child: Text("Features"),
          ),

          // LOGIN PAGE BUTTOn
          TextButton(
            onPressed: () {
              setState(() {
                pageIndex = 5;
              });
            },
            child: Text("Login / Signup"),
          ),
        ],
      ),
      body: pages[pageIndex],
    );
  }
}
