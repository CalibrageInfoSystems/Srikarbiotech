import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Common/CommonUtils.dart';
import 'LoginScreen.dart';
import 'Model/CompanyModel.dart';
class Companiesselection extends StatefulWidget {
  @override
  Companies_selection createState() => Companies_selection();
}

class Companies_selection extends State<Companiesselection> {
  bool _isLoading = false;
  List<CompanyModel> companiesList = [];
   List<CompanyModel> companies= [];
   final TextStyle _titleStyle = const TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        fetchGetCompaniesData();
        print('The Internet Is Connected');
      } else {
        print('The Internet Is not  Connected');
      }
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select a Company',
                    style: _titleStyle,
                  ),
                  Text(
                    'to Proceed',
                    style: _titleStyle,
                  ),
                  // Display the fetched companies
                  const SizedBox(

                    height: 60,
                  ),
                  for (CompanyModel company in companies)
                    CardForScreenOne(
                      cardIndex: company.companyId - 1, // Adjust if needed
                      cardImage: '',
                      companyName: company.companyName,
                      companyAddress: company.companyAddress,
                        companyId: company.companyId
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // void fetchGetCompaniesData() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   final response = await http.get(
  //     Uri.parse('http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/GetCompanies/null'),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //
  //     final List<dynamic> listResult = responseData['response']['listResult'];
  //     final List<CompanyModel> fetchedCompanies = listResult.map((data) => CompanyModel.fromJson(data)).toList();
  //
  //     setState(() {
  //       companies = fetchedCompanies;
  //     });
  //   } else {
  //     throw Exception('Failed to load data from the API');
  //   }
  // }

  void fetchGetCompaniesData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/GetCompanies/null'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        final List<dynamic> listResult = responseData['response']['listResult'];
        final List<CompanyModel> fetchedCompanies =
        listResult.map((data) => CompanyModel.fromJson(data)).toList();

        setState(() {
          companies = fetchedCompanies;
        });
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {

    }
  }


}

class CardForScreenOne extends StatelessWidget {
  final int cardIndex;
  final String cardImage;
  final String companyName;
  final String companyAddress;
  final int companyId;
  CardForScreenOne({
    Key? key,
    required this.cardIndex,
    required this.cardImage,
    required this.companyName,
    required this.companyAddress, required this.companyId,
  }) : super(key: key);

  final List cardColors = [
    [HexColor('#ffefdf'), HexColor('#d9fde3')],
    [HexColor('#dd803a'), HexColor('#118630')],
    ['assets/srikar_biotech_logo.svg', 'assets/srikar-seed.png'],
  ];

  @override
  Widget build(BuildContext context) {
    return
      InkWell(
        onTap: () {
      // Handle card click here

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            companyName: companyName,
            companyId: companyId,
          ),
        ),
      );
    },

          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: cardIndex == 0 ? cardColors[0][0] : cardColors[0][1],
                ),
                child: Row(
                  children: [
                    // content
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       // crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
                        children: [
                          Container(
                            alignment: Alignment.center, // Center the text vertically
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: companyName.split(" ")[0] + "\n", // First word
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w600,
                                      color: cardIndex == 0
                                          ? cardColors[1][0]
                                          : cardColors[1][1],
                                    ),
                                  ),
                                  // WidgetSpan(
                                  //   child: SizedBox(height: 30),
                                  // ),
                                  TextSpan(
                                    text: companyName.split(" ").sublist(1).join(" "), // Remaining words
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w600,
                                      color: cardIndex == 0
                                          ? cardColors[1][0]
                                          : cardColors[1][1],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // const SizedBox(
                          //   height: 20,
                          // ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                        ],
                      ),
                    ),

                    // const SizedBox(
                    //   width: 10,
                    // ),
                    Spacer(),

                    // image
                    Expanded(
                      child: Container(
                        height: 100,
                        alignment: Alignment.bottomRight, // Center the image horizontally
                        child: cardIndex == 0
                            ? SvgPicture.asset(cardColors[2][0])
                            : Image.asset(cardColors[2][1]),
                      ),
                    ),
                  ],
                ),
              ),

              // card bottom space
              const SizedBox(
                height: 40,
              ),
            ],
          )

      );
  }
}

