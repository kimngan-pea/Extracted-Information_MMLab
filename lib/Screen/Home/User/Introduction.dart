
import 'package:extracted_information/Models/photo.dart';
import 'package:flutter/material.dart';

class IntroductionPage extends StatelessWidget {
  IntroductionPage({super.key});

  final List<Datas> _photos = [
    Datas(image: "assets/phuc.jpg", text: "Quang Phuc", subtitle: "Web Developer"),
    Datas(image: "assets/tuan anh.jpg", text: "Tuan Anh", subtitle: "Web Developer"),
    Datas(image: "assets/ngan.jpg", text: "Kim Ngan", subtitle: "Mobile Developer"),
    Datas(image: "assets/huy.jpg", text: "Quang Huy", subtitle: "AI Trainer"),
    Datas(image: "assets/nguyen.jpg", text: "Thai Nguyen", subtitle: "Backend & API searcher"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3D3CD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3D3CD),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              const Text(
                'OUR TEAM MEMBERS',
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _photos.length.isOdd ? _photos.length - 1 : _photos.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 40,
                        mainAxisSpacing: 1,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ClipOval(
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: const Color(0x9EFED3B5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(width: 1.0, color: Colors.black54),
                                  image: DecorationImage(
                                    image: AssetImage(_photos[index].image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _photos[index].text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _photos[index].subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, color: Color(0xFF787878)),
                            ),
                          ],
                        );
                      },
                    ),
                    if (_photos.length.isOdd) // Add last image centered if odd
                      Center(
                        child: Column(
                          children: [
                            ClipOval(
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: const Color(0x9EFED3B5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(width: 1.0, color: Colors.black54),
                                  image: DecorationImage(
                                    image: AssetImage(_photos.last.image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _photos.last.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _photos.last.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, color: Color(0xFF787878)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Contact
              const SizedBox(height: 40),
              const Text('Contact Us', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 5),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email_rounded),
                  SizedBox(width: 10),
                  Text(
                    '21521725@gm.uit.edu.vn',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
