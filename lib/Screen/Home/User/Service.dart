import 'package:extracted_information/Models/photo.dart';
import 'package:extracted_information/Screen/Home/OCR/Collect.dart';
import 'package:flutter/material.dart';

class OCRservicePage extends StatelessWidget {
  OCRservicePage({super.key});

  final List<Data> _photos = [
    Data(image: "assets/invoice.png", text: "Invoices and Receipts"),
    Data(image: "assets/identification.png", text: "Identification Cards"),
    Data(image: "assets/contract.png", text: "Contracts"),
    Data(image: "assets/payroll.png", text: "Payroll Accounting"),
    Data(image: "assets/credit.png", text: "Account and Credit Card statements"),
    Data(image: "assets/document.png", text: "Many More Types"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3D3CD),
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: const Text('OCR Services'),),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              //Introduction
              Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const Text(
                        'INTERGATION',
                        style: TextStyle(color: Colors.deepPurple, fontSize: 24),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Currently we provide standardized solutions for the following document types.',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),

                      //Start OCR service
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[200], 
                          elevation: 15,
                          shadowColor: Colors.black,
                          side: const BorderSide(width: 0.5, color: Colors.black38)),
                        child: const Text(
                          'Start ->',
                          style: TextStyle(color: Colors.white, fontSize: 20),                         
                        ),
                        onPressed: () async {
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CameraAppState()
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
                
                // Images
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
                  child: GridView.builder(
                    shrinkWrap: true, 
                    physics:
                        const NeverScrollableScrollPhysics(), 
                    itemCount: _photos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 40,
                      mainAxisSpacing: 1,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 90, 
                            decoration: BoxDecoration(
                              color:  const Color(0x9EFED3B5),
                              borderRadius: BorderRadius.circular(20), 
                              border: Border.all(width: 1.0, color: Colors.black54),
                              image: DecorationImage(
                                image: AssetImage(_photos[index].image),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _photos[index].text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

