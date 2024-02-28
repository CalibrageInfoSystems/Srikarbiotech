import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'Common/CommonUtils.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Model/card_collection.dart';

class ViewCollectionCheckOut extends StatefulWidget {
  final ListResult listResult;
  final int position;
  final Widget statusBar;

  const ViewCollectionCheckOut(
      {super.key,
        required this.listResult,
        required this.position,
        required this.statusBar});
  //const ViewCollectionCheckOut({super.key});

  @override
  State<ViewCollectionCheckOut> createState() => _ViewCollectionCheckOutState();
}

class _ViewCollectionCheckOutState extends State<ViewCollectionCheckOut> {
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
    ['Date', 'Payment Mode', 'Credit Bank', 'Purpose'],
    ['Total Amount', 'Credit Account No', 'UTR Number', 'Category', '']
    // ['Date', 'Payment Mode', 'Cheque Date', 'Purpose', '']
  ];
  List tableCellTitles2 = [
    ['Date', 'Payment Mode', 'Cheque Date', 'Purpose'],
    ['Total Amount', 'Cheque Number', 'Cheque Issued Bank', 'Category', '']
    // ['Date', 'Payment Mode', 'Cheque Date', 'Purpose', '']
  ];
  int CompneyId = 0;
  String checkdate = "";
  String payment_mode = "";
  @override
  void initState() {
    super.initState();

    getshareddata();
  }

  @override
  Widget build(BuildContext context) {
    //  final arguments = ModalRoute.of(context)?.settings?.arguments as ListResult;
    String dateString = widget.listResult.date;
    payment_mode = widget.listResult.paymentTypeName;
    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    String checkdateString = widget.listResult.checkDate;
    String checkdate = '';

    try {
      DateTime date2 = DateTime.parse(checkdateString);
      checkdate = DateFormat('dd-MM-yyyy').format(date2);
    } catch (e) {
      print('Error parsing date: $e');
      // Handle the error as needed, e.g., set a default date or display an error message
    }
    List tableCellValues = [
      [
        formattedDate,
        widget.listResult.paymentTypeName,
        widget.listResult.creditBank,
        widget.listResult.purposeName,
        widget.listResult.remarks
      ],
      [
        '₹${formatNumber( widget.listResult.amount)}',
        widget.listResult.creditAccountNo,
        widget.listResult.utrNumber,
        widget.listResult.categoryName,
        '' // int
      ]
    ];
    List tableCellValues2 = [
      [
        formattedDate,
        widget.listResult.paymentTypeName,
        checkdate,
        widget.listResult.purposeName,
        widget.listResult.remarks
      ],
      [
        '₹${formatNumber( widget.listResult.amount)}',
        widget.listResult.checkNumber,
        widget.listResult.checkIssuedBank,
        widget.listResult.categoryName,
        '' // int
      ]
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFe78337),
        automaticallyImplyLeading: false,
        // This line removes the default back arrow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: GestureDetector(
                    onTap: () {
                      // Handle the click event for the back button
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.chevron_left,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                const Text(
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

                  return GestureDetector(
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
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        // adject padding as you want
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // small box
              const SizedBox(height: 8.0),
              CommonUtils.buildCard(
                widget.listResult.partyName,
                widget.listResult.partyCode,
                widget.listResult.proprietorName,
                widget.listResult.partyGSTNumber,
                widget.listResult.address,
                Colors.white,
                BorderRadius.circular(5.0),
              ),
              const SizedBox(height: 16.0),
              // big box
              Card(
                elevation: 7,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      // Table
                      Row(
                        //  crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Collection ID',
                                    textAlign: TextAlign.start,
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  Text(
                                    widget.listResult.collectionNumber,
                                    style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 13,
                                        color: Color(0xFFe58338),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ]),
                          ),
                          // _collectionStatus(widget.listResult.statusName),
                          widget.statusBar,
                        ],
                      ),
                      if (payment_mode == "Online")
                        Table(
                          border: TableBorder.all(
                            width: 1,
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          children: List.generate(4, (index) {
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
                                          style: CommonUtils.txSty_14B_Fb,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          tableCellValues[0][index].toString(),
                                          style: CommonUtils.txSty_13O_F6,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Container(
                                    padding: _tableCellPadding,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          tableCellTitles[1][index],
                                          style: CommonUtils.txSty_14B_Fb,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          tableCellValues[1][index].toString(),
                                          // '₹${formatNumber(tableCellValues[1][index].toString() as double)}',
                                          style: CommonUtils.txSty_13O_F6,
                                        )
                                      ],
                                    ),
                                  ),
                                ),


                              ],
                            );
                          }),
                        ),

                      // Table for Cheque
                      if (payment_mode == "Cheque")
                        Table(
                          border: TableBorder.all(
                            width: 1,
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          children: List.generate(4, (index) {
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
                                          tableCellTitles2[0][index],
                                          style: CommonUtils.txSty_14B_Fb,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          tableCellValues2[0][index].toString(),
                                          style: CommonUtils.txSty_13O_F6,
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
                                          tableCellTitles2[1][index],
                                          style: CommonUtils.txSty_14B_Fb,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          tableCellValues2[1][index].toString(),
                                          style: CommonUtils.txSty_13O_F6,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      Visibility(
                        visible: widget.listResult.remarks != null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.listResult.remarks != null)
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Remarks',
                                      textAlign: TextAlign.start,
                                      style: CommonUtils.txSty_13B_Fb,
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      widget.listResult.remarks!,
                                      style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 13,
                                        color: Color(0xFFe58338),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),


                      // Space
                      const SizedBox(
                        height: 10,
                      ),

                      // Attachment
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ignore: prefer_const_constructors
                          Text(
                            'Attachment',
                            style: CommonUtils.txSty_14B_Fb,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: GestureDetector(
                                onTap: (){
                                  showZoomedAttachments(
                                      widget.listResult.fileUrl);
                                }
                                ,
                                child: widget.listResult.fileUrl != null
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
                          ),
                        ],
                      ),
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

  void _showZoomedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                // height: MediaQuery.of(context)
                //     .size
                //     .height,
                height: 600,

                // Adjust the height as needed
                child: IntrinsicHeight(
                    child: PhotoViewGallery.builder(
                      itemCount: 1, // Only one image in the gallery
                      builder: (context, index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider:
                          NetworkImage(widget.listResult.fileUrl ?? ''),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 2,
                        );
                      },
                      scrollDirection: Axis.vertical,
                      scrollPhysics: const PageScrollPhysics(),
                      allowImplicitScrolling: true,
                      //   scrollPhysics: PageScrollPhysics(),
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      // pageController: PageController(),
                      // onPageChanged: (index) {
                      //   // Handle page change if needed
                      // },
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _collectionStatus(String statusName) {
    final Color statusColor;
    final Color statusBgColor;
    switch (statusName) {
      case 'Pending':
        statusColor = const Color(0xFFe58338);
        statusBgColor = const Color(0xFFe58338).withOpacity(0.2);
        break;
      case 'Received':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 'Reject':
        statusColor = HexColor('#C42121');
        statusBgColor = HexColor('#C42121').withOpacity(0.2);
        break;

      default:
        statusColor = Colors.black26;
        statusBgColor = Colors.black26.withOpacity(0.2);
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: statusBgColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/shipping-fast.svg',
            fit: BoxFit.fill,
            width: 15,
            height: 15,
            color: statusColor,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            statusName,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  String formatNumber(double number) {
    NumberFormat formatter = NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
    return formatter.format(number);
  }


  void showZoomedAttachments(String imageString) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            width: double.infinity,
            height: 500,
            child: Stack(
              children: [
                Center(
                  child: PhotoViewGallery.builder(
                    itemCount: 1,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(imageString),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered,
                      );
                    },
                    scrollDirection: Axis.vertical,
                    scrollPhysics: const PageScrollPhysics(),
                    allowImplicitScrolling: true,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
