import "package:animated_text_kit/animated_text_kit.dart";
import "package:extracted_information/Screen/Home/OCR/Collect.dart";
import "package:extracted_information/Screen/Home/User/History.dart";
import "package:extracted_information/Screen/Home/User/Introduction.dart";
import "package:extracted_information/Screen/Home/User/Keys.dart";
import "package:extracted_information/Screen/Home/User/Service.dart";
import "package:extracted_information/Services/auth.dart";
import "package:flutter/material.dart";

class Home extends StatelessWidget {
  Home({super.key});

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFB3D3CD),
        appBar: AppBar(
          title: const Text('Home'),
          backgroundColor: Colors.green[300],
          elevation: 1.0,
          leading: PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onSelected: (value) {
              switch (value) {
                case 'Keys':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (text) => const KeyPage()));
                  break;
                case 'OCR Service':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (text) => OCRservicePage()));
                  break;
                case 'History':
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (text) => const HistoryPage()));
                  break;
                case 'Introduction':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (text) => IntroductionPage()));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(value: 'Keys', child: Text('Keys')),
              const PopupMenuItem<String>(
                  value: 'OCR Service', child: Text('OCR Service')),
              const PopupMenuItem<String>(
                  value: 'History', child: Text('History')),
              const PopupMenuItem<String>(
                  value: 'Introduction', child: Text('About Us')),
            ],
          ),
          actions: <Widget>[
            TextButton.icon(
              icon: const Icon(Icons.logout_outlined),
              label: const Text('Log out'),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () async {
                await _auth.signOut();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column( 
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Text introduction
                Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText('OCR SERVICES',
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'PAN extracts all data relevant to you from documents and provides it for use in your purposes, PAN is the right solution for you, if you:',
                        style:
                            TextStyle(color: Color(0xFF13313D), fontSize: 18),
                      ),
                      const SizedBox(height: 12.0),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF2D99AE),),
                          SizedBox(width: 5.0),
                          Flexible(
                            child: Text(
                                'Need a standard OCR, for example to extract invoices, or our solution fo rremittance advices',
                                style: TextStyle(
                                    color: Color(0xFF13313D), fontSize: 16)),
                          )
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF2D99AE),),
                          SizedBox(width: 5.0),
                          Flexible(
                            child: Text(
                                'Need to process a lot of documents and are looking for an individual solution to make your work easier',
                                style: TextStyle(
                                    color: Color(0xFF13313D), fontSize: 16)),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Image.asset('assets/bg.png'),
                const SizedBox(height: 20),

                //Start OCR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[200],
                      elevation: 15,
                      shadowColor: Colors.black,
                      side:
                          const BorderSide(width: 0.5, color: Colors.black38)),
                  child: const Text(
                    'Start OCR ->',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CameraAppState()),
                    );
                  },
                )
              ],
            ),
          ),
        ));
  }
}
