import 'package:adobe_app/managers/auth_manager.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  @override
  Widget build(BuildContext context) {
    final currentUser = AuthManager.instance.currentUser();

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
        child: SizedBox(
          width: 150,
          child: Row(
            children: [
              Image(
                image: AssetImage('assets/logo-125x125.png'),
                height: 50,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 10),
              MyTitle(text: "LEALO", fontSize: 25),
            ],
          ),
        ),
      ),
      actions: [
        /*
          // THE GOAL PAGE BUTTON
          TextButton(
            onPressed: () {
              setState(() {
                pageIndex = 2;
              });
            },
            child: Text("The Goal"),
          ),

          // FEATURES PAGE BUTTON
          TextButton(
            onPressed: () {
              setState(() {
                pageIndex = 1;
              });
            },
            child: Text("Features"),
          ),
          */

        // LOGIN PAGE BUTTOn
        currentUser == null
            ? TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text("Login / Signup"),
              )
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "LOGOUT"){
                    setState(() {
                      AuthManager.instance.signOut();
                    });
                  }
                  else if (value == "DASHBOARD"){
                    Navigator.pushNamed(context, "/dashboard");
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'DASHBOARD', child: Text('My Dashboard')),
                  PopupMenuItem(value: 'LOGOUT', child: Text('Log Out')),
                ],
                child: Text(currentUser.email!),
              ),

        // CONTACT PAGE BUTTOn
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/contact');
          },
          child: Text("Contact"),
        ),
      ],
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Widget contactPage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: EdgeInsets.all(100),
              child: MyTitle(
                text:
                    "To learn more about the SDG, go to https://sdgs.un.org/goals/goal4 or email otocassius@gmail.com",
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: HomeAppBar(), body: contactPage(context));
  }
}

class WebHomePage extends StatelessWidget {
  const WebHomePage({super.key});

  Widget mainHomePage(BuildContext context) {
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

  /*
  Widget featuresPage() {
    return Center(
      child: SingleChildScrollView(
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
                    MyTitle(text: "Feature 2: Teacher Dashboard", fontSize: 18),
        
                    SizedBox(height: 15),
        
                    Text(
                      "LEALO has a teacher dashboard where every teacher can assign a topic to learn."
                      " They are also able to track how each student is doing in their learning process with the strengths and weaknesses of each student.",
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
                    MyTitle(
                      text: "Feature 3: Natural Language Processing (NLP)",
                      fontSize: 18,
                    ),
        
                    SizedBox(height: 15),
        
                    Text(
                      "LEALO's Artificial Intelligence uses NLP in order to process the text the user inputs."
                      " It turns text into rough contextual meanings stored as directional vectors.  "
                      " This way, the AI can process it because these vectors are just number."
                      " It then spits back out new vectors that are turned back into text for the user."
                      "",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
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

  Widget goalPage() {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
        child: Column(
          children: [
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
                      '"Ensure inclusive and equitable quality education and promote lifelong learning opportunities for all"\n'
                      '- United Nations SDG 4',
                      textAlign: TextAlign.center,
                      style: TextStyle(),
                    ),
                    SizedBox(height: 15),

                    MyTitle(text: "What it means: "),
                    Text(
                      'All students should get not just equal education, but the education they need.'
                      ' When one student is falling behind, they should get the individual attention they need.'
                      ' This way, each student recieves a valuable education where all end up with the same knowledge, just with different individual paths taken.',
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 50),

            MyTitle(text: "Where LEALO Comes In: ", fontSize: 18.0),

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
                      "LEALO Supports SDG 4 by giving each student an individual teacher's assistant,"
                      " that teaches a material to the student, answers answers any questions, and makes sure the student understands."
                      " It is used as a tool for the teacher to enable them to spread their influence."
                      " LEALO will additionally report back to the teacher any areas of struggle that the teacher can address in the classroom.",
                      textAlign: TextAlign.center,
                      style: TextStyle(),
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
  */

  @override
  Widget build(BuildContext context) {
    // than having to individually change instances of widgets.
    return Scaffold(appBar: HomeAppBar(), body: mainHomePage(context));
  }
}
