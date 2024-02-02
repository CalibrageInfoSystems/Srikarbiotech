import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

import 'Common/CommonUtils.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Model/card_collection.dart';

class ViewCollectionCheckOut extends StatefulWidget {

  final ListResult listResult;
  final int position;

  ViewCollectionCheckOut({required this.listResult, required this.position});
  //const ViewCollectionCheckOut({super.key});

  @override
  State<ViewCollectionCheckOut> createState() => _ViewCollectionCheckOutState();
}

class _ViewCollectionCheckOutState extends State<ViewCollectionCheckOut> {
  final _orangeColor = HexColor('#e58338');

  final _titleTextStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: Colors.black,
    fontSize: 18,
  );

  final _tableCellPadding = const EdgeInsets.all(10);

  final _dataTextStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    color: Color(0xFFe78337),
    fontSize: 16,
  );

  List tableCellTitles = [
    ['Date', 'Payment Mode', 'Cheque Date', 'Purpose', 'Remarks'],
    [
      'Amount',
      'Cheque Number',
      'Cheque Issued Bank',
      'Category',
      ''
    ]
    // ['Date', 'Payment Mode', 'Cheque Date', 'Purpose', '']
  ];
  int CompneyId = 0;
  String checkdate = "";
  @override
  void initState() {
    super.initState();

    getshareddata();
    print("screenFrom: ${widget.listResult.phoneNumber}");



  }
  @override
  Widget build(BuildContext context) {
  //  final arguments = ModalRoute.of(context)?.settings?.arguments as ListResult;
    String dateString = widget.listResult.date;

    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    String checkdateString = widget.listResult.checkDate;
    String checkdate = '';

    if (checkdateString != null) {
      try {
        DateTime date2 = DateTime.parse(checkdateString);
        checkdate = DateFormat('dd-MM-yyyy').format(date2);
      } catch (e) {
        print('Error parsing date: $e');
        // Handle the error as needed, e.g., set a default date or display an error message
      }
    }
    List tableCellValues = [

      [
        formattedDate,
        widget.listResult.paymentTypeName,
        checkdate,
        widget.listResult.purposeName,
        widget.listResult.remarks
      ],
      [
        widget.listResult.amount, // double
        widget.listResult.checkNumber,
        widget.listResult.checkIssuedBank,
        widget.listResult.categoryName,
        ''// int
      ]
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFe78337),
        automaticallyImplyLeading: false,
        // This line removes the default back arrow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: GestureDetector(
                    onTap: () {
                      // Handle the click event for the back button
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.chevron_left,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  'View Collection',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            FutureBuilder(
              future: getshareddata(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // Access the companyId after shared data is retrieved

                  return   GestureDetector(
                    onTap: () {
                      // Handle the click event for the home icon
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    child: Image.asset(
                      CompneyId == 1
                          ? 'assets/srikar-home-icon.png'
                          : 'assets/seeds-home-icon.png',
                      width: 30,
                      height: 30,
                    ),
                  );

                } else {
                  // Return a placeholder or loading indicator
                  return SizedBox.shrink();
                }
              },
            ),

          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        // adject padding as you want
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children :[
              // small box
              SizedBox(height: 8.0),
              CommonUtils.buildCard(
                widget.listResult.partyName,
                widget.listResult.partyCode,
                widget.listResult.proprietorName,
                widget.listResult.partyGSTNumber,
                widget.listResult.address,
                Colors.white,
                BorderRadius.circular(10.0),
              ),
              SizedBox(height: 16.0),
              // big box
              Card(
                elevation: 7,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      // Table
                      Table(
                        border: TableBorder.all(
                          width: 1,
                          color: Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        children: [
                          ...List.generate(5, (index) {
                            return TableRow(
                              children: [
                                TableCell(
                                  child: Container(
                                    padding: _tableCellPadding,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          tableCellTitles[0][index],
                                          style: _titleTextStyle,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          tableCellValues[0][index].toString(),
                                          style: _dataTextStyle,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Container(
                                    padding: _tableCellPadding,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          tableCellTitles[1][index],
                                          style: _titleTextStyle,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          tableCellValues[1][index].toString(),
                                          style: _dataTextStyle,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          })
                        ],
                      ),

                      // space
                      const SizedBox(
                        height: 20,
                      ),

                      // Attachment
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attachment',
                            style: _titleTextStyle,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:  widget.listResult.fileUrl != null
                                  ? Image.network(
                                widget.listResult.fileUrl,
                                      fit: BoxFit.fill,
                                    )
                                  : Image.asset(
                                      'assets/sreekar_seeds.png',
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getshareddata() async {

    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");

    print('Company ID: $CompneyId');


  }
}
