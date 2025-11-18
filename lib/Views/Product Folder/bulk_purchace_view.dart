import 'package:flutter/widgets.dart';
import 'package:graba2z/Utils/packages.dart';
import 'package:graba2z/Views/Product%20Folder/request_form.dart';

class BulkPurchaceView extends StatefulWidget {
  const BulkPurchaceView({super.key});

  @override
  State<BulkPurchaceView> createState() => _BulkPurchaceViewState();
}

class _BulkPurchaceViewState extends State<BulkPurchaceView> {
  final List<Map<String, String>> steps = [
    {'step': 'Step 1', 'desc': 'Bulk Requirement'},
    {'step': 'Step 2', 'desc': 'Request For Quote'},
    {'step': 'Step 3', 'desc': 'Best Price Quoted'},
    {'step': 'Step 4', 'desc': 'Proposals Evaluated'},
    {'step': 'Step 5', 'desc': 'Invoice'},
    {'step': 'Step 6', 'desc': 'Delivery & Payment'},
  ];
  final List<Map<String, String>> purchase = [
    {
      'step': 'Trusted Platform',
      'desc':
          'Dedicated to serving SMBs in the UAE. Trust and reliability are our priority.'
    },
    {
      'step': 'Authorized Sellers',
      'desc':
          'Over 100 authorized sellers ready to serve with better prices and availability.'
    },
    {
      'step': 'Learn About Trends',
      'desc':
          'Join webinars by global brands to stay ahead and grow your business'
    },
    {
      'step': 'Better Range and Information',
      'desc':
          'Access a wide range of products with accurate info from over 200 global brands.'
    },
    {
      'step': 'Quantity Discounts & RFQ',
      'desc':
          'Get better prices for larger quantities or request quotes from multiple sellers.'
    },
    {
      'step': 'Create Users & Manage Purchases',
      'desc':
          'Add team members and set buyer/approver roles for a seamless experience.'
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          AppImages.logoicon,
          height: 40,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Your One-Stop Solution for B2B Business Needs in UAE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: kPrimaryColor),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          'Graba2z- B2B Dedicated Wholesale Place',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 21, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Our trusted B2B wholesale place will cater to all your buisness needs',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Welcome to Grabatoz.com your one-stop sourcing platform for all your business needs. Grabatoz.com, the omnichannel retailer that was established in Dubai, UAE. We are a business focused marketplace where small and medium businesses (SMBs) discover, interact, and buy products and services by engaging with brands and authorized sellers.',
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/images/bulkP.jpeg'),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Benefits of being on Grabatoz.com',
                    // textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'As a customer and as a business buyer, the platform offers great benefits and opportunities for small and medium businesses.',
                    // textAlign: TextAlign.center,
                  ),
                ),
                // Container(
                //   height: 55,
                //   width: 200,
                //   margin: EdgeInsets.symmetric(horizontal: 8),
                //   decoration: BoxDecoration(
                //       color: kPrimaryColor,
                //       borderRadius: BorderRadius.circular(8)),
                //   child: Center(
                //     child: Text(
                //       'Contact Sales',
                //       style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 16,
                //           fontWeight: FontWeight.w600),
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Online BUYING journey',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                GridView.builder(
                  itemCount: steps.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(0xff8BC34A), width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            steps[index]['step']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            steps[index]['desc']!,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                const Text(
                  "Why Bulk Purchase from Grabatoz.com?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                ListView.builder(
                  itemCount: purchase.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xff8BC34A), width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: ListTile(
                          title: Text(
                            purchase[index]['step']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            purchase[index]['desc']!,
                            style: const TextStyle(fontSize: 12),
                            // textAlign: TextAlign.center,
                          ),
                        ));
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return RequestForm();
                      },
                    );
                  },
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    // width: 200,
                    // margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        'Contact Sales',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
