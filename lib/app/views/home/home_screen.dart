// // import 'package:flutter/material.dart';
// // import 'package:rememberme/widgets/customAppbar.dart';

// // class HomeScreen extends StatelessWidget {
// //   const HomeScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: NestedScrollView(
// //         headerSliverBuilder: (context, innerBoxIsScrolled) {
// //           return [
// //             // Custom AppBar with HomeScreen-specific content
// //             CustomAppBar(
// //               appBarContent: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 mainAxisAlignment: MainAxisAlignment.end,
// //                 children: [
// //                   // User Greeting Row
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       // User Greeting Column
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             "Hey Rio!",
// //                             style: TextStyle(
// //                               color: AppColors.primaryTealAlt,
// //                               fontSize: 32,
// //                               fontFamily: 'PolySans',
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                           const SizedBox(height: 0),
// //                           Text(
// //                             "Ready to remember?",
// //                             style: TextStyle(
// //                               color: AppColors.primaryTealAlt,
// //                               fontSize: 16,
// //                               fontFamily: 'PolySans',
// //                               fontWeight: FontWeight.w300,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //               backgroundColor: AppColors.primaryBlue,
// //             ),
// //           ];
// //         },
// //         body: Container(
// //           color: Colors.white,
// //           child: FractionallySizedBox(
// //             widthFactor: 0.4, // 50% of parent width
// //             child: Padding(
// //               padding: const EdgeInsets.only(bottom: 50),
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.end,
// //                 children: [
// //                   Text(
// //                     "You're in!",
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.w600,
// //                       color: Color(0xFF025786),
// //                       fontFamily: 'PolySans',
// //                     ),
// //                   ),
// //                   Text(
// //                     "Start saving the details that make connections meaningful.",
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.w400,
// //                       color: Color.fromARGB(177, 0, 0, 0),
// //                       fontFamily: 'PolySans',
// //                     ),
// //                   ),
// //                   SizedBox(height: 20),
// //                   Image(image: 
// //                   AssetImage('assets/images/Direction.png'),
// //                     fit: BoxFit.contain,
// //                     alignment: Alignment.centerRight,
// //                     width: double.infinity,
// //                     height: 160,
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:rememberme/app/data/contacts_data.dart';
// import 'package:rememberme/widgets/customAppbar.dart';
// import 'package:rememberme/widgets/saved_contacts_section.dart';


// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Check if there are any contacts
//     final hasContacts = ContactsData.contacts.isNotEmpty;

//     return Scaffold(
//       body: NestedScrollView(
//         headerSliverBuilder: (context, innerBoxIsScrolled) {
//           return [
//             CustomAppBar(
//               appBarContent: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Hey Rio!",
//                             style: TextStyle(
//                               color: AppColors.primaryTealAlt,
//                               fontSize: 32,
//                               fontFamily: 'PolySans',
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 0),
//                           Text(
//                             "Ready to remember?",
//                             style: TextStyle(
//                               color: AppColors.primaryTealAlt,
//                               fontSize: 16,
//                               fontFamily: 'PolySans',
//                               fontWeight: FontWeight.w300,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               backgroundColor: AppColors.primaryBlue,
//             ),
//           ];
//         },
//         body: Container(
//           color: Colors.white,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (!hasContacts)
//                   // Show "You're in!" section only when there are NO contacts
//                   Align(
//                     alignment: Alignment.center,
//                     child: FractionallySizedBox(
//                       widthFactor: 0.4,
//                       child: Padding(
//                         padding: const EdgeInsets.only(bottom: 50, top: 40),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Text(
//                               "You're in!",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.primaryBlue,
//                                 fontFamily: 'PolySans',
//                               ),
//                             ),
//                             Text(
//                               "Start saving the details that make connections meaningful.",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w400,
//                                 color: Color.fromARGB(177, 0, 0, 0),
//                                 fontFamily: 'PolySans',
//                               ),
//                             ),
//                             SizedBox(height: 20),
//                             Image(
//                               image: AssetImage('assets/images/Direction.png'),
//                               fit: BoxFit.contain,
//                               alignment: Alignment.centerRight,
//                               width: double.infinity,
//                               height: 160,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
//                 else
//                   // Show contacts section when there ARE contacts
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: 20),
//                         SavedContactsSection(),
//                         SizedBox(height: 40),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/data/contacts_data.dart';
import 'package:rememberme/widgets/customAppbar.dart';
import 'package:rememberme/widgets/saved_contacts_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if there are any contacts
    final hasContacts = ContactsData.contacts.isNotEmpty;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CustomAppBar(
              appBarContent: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hey Rio!",
                            style: TextStyle(
                              color: AppColors.primaryTealAlt,
                              fontSize: 32,
                              fontFamily: 'PolySans',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 0),
                          Text(
                            "Ready to remember?",
                            style: TextStyle(
                              color: AppColors.primaryTealAlt,
                              fontSize: 16,
                              fontFamily: 'PolySans',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              backgroundColor: AppColors.primaryBlue,
            ),
          ];
        },
        body: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasContacts)
                  // Show "You're in!" section only when there are NO contacts
                  Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      widthFactor: 0.4,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50, top: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "You're in!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                                fontFamily: 'PolySans',
                              ),
                            ),
                            Text(
                              "Start saving the details that make connections meaningful.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(177, 0, 0, 0),
                                fontFamily: 'PolySans',
                              ),
                            ),
                            SizedBox(height: 20),
                            Image(
                              image: AssetImage('assets/images/Direction.png'),
                              fit: BoxFit.contain,
                              alignment: Alignment.centerRight,
                              width: double.infinity,
                              height: 160,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  // Show contacts section when there ARE contacts
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        SavedContactsSection(),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}