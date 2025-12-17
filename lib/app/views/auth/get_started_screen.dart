// // import 'package:flutter/material.dart';

// // class GetStartedScreen extends StatefulWidget {
// //   const GetStartedScreen({super.key});

// //   @override
// //   State<GetStartedScreen> createState() => _GetStartedScreenState();
// // }

// // class _GetStartedScreenState extends State<GetStartedScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           image: DecorationImage(
// //             fit: BoxFit.cover,
// //           ),
// //         ),
// //         child: SafeArea(
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 30.0),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               crossAxisAlignment: CrossAxisAlignment.stretch,
// //               children: [
// //                 // Top Content
// //                 Expanded(
// //                   flex: 7,
// //                   child: Container(
// //                     width: double.infinity,
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.end,
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                       children: [
// //                         Image.asset(
// //                           'assets/images/GetStarted-1.png',
// //                           width: double.infinity,
// //                           fit: BoxFit.contain,
// //                         ),
// //                         const SizedBox(height: 10),
// //                         const Padding(
// //                           padding: EdgeInsets.symmetric(horizontal: 0.0),
// //                           child: Text(
// //                             'The Smart Way to Remember People.',
// //                             textAlign: TextAlign.center,
// //                             style: TextStyle(
// //                               fontFamily: 'Inter',
// //                               fontWeight: FontWeight.w600,
// //                               fontSize: 18,
// //                               color: AppColors.white,
// //                               height: 1.4,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
                
// //                 // Bottom Button Section
// //                 Expanded(
// //                   flex: 4,
// //                   child: Container(
// //                     padding: const EdgeInsets.only(bottom: 80.0),
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.end,
// //                       crossAxisAlignment: CrossAxisAlignment.stretch,
// //                       children: [
// //                         // Get Started Button - UPDATED
// //                         SizedBox(
// //                           height: 60,
// //                           child: Material(
// //                             borderRadius: BorderRadius.circular(16),
// //                             clipBehavior: Clip.antiAlias,
// //                             child: InkWell(
// //                               onTap: () {
// //                                 print('Get Started button pressed');
// //                               },
// //                               child: Container(
// //                                 decoration: BoxDecoration(
// //                                   borderRadius: BorderRadius.circular(16),
// //                                   gradient: const LinearGradient(
// //                                     begin: Alignment.centerLeft,
// //                                     end: Alignment.centerRight,
// //                                     colors: [
// //                                       Color(0xFF00BDE8),
// //                                       Color(0xFF00FFD0),
// //                                     ],
// //                                   ),
// //                                   boxShadow: [
// //                                     BoxShadow(
// //                                       color: AppColors.shadowBlackHeavy,
// //                                       blurRadius: 12,
// //                                       offset: const Offset(0, 6),
// //                                       spreadRadius: 1,
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 child: const Stack(
// //                                   alignment: Alignment.center,
// //                                   children: [
// //                                     // Centered Text
// //                                     Text(
// //                                       "Let's Get Started",
// //                                       style: TextStyle(
// //                                         color: AppColors.primaryBlue,
// //                                         fontSize: 18,
// //                                         fontWeight: FontWeight.w700,
// //                                         fontFamily: 'PolySans',
// //                                         letterSpacing: 0.5,
// //                                       ),
// //                                     ),
                                    
// //                                     // Icon at the end
// //                                     Positioned(
// //                                       right: 20,
// //                                       child: Icon(
// //                                         Icons.arrow_forward_rounded,
// //                                         color: AppColors.primaryBlue,
// //                                         size: 24,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
                        
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'login_screen.dart'; // Import the LoginScreen

// class GetStartedScreen extends StatefulWidget {
//   const GetStartedScreen({super.key});

//   @override
//   State<GetStartedScreen> createState() => _GetStartedScreenState();
// }

// class _GetStartedScreenState extends State<GetStartedScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/Bg_splash.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 30.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Top Content
//                 Expanded(
//                   flex: 7,
//                   child: Container(
//                     width: double.infinity,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           'assets/images/GetStarted-1.png',
//                           width: double.infinity,
//                           fit: BoxFit.contain,
//                         ),
//                         const SizedBox(height: 10),
//                         const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 0.0),
//                           child: Text(
//                             'The Smart Way to Remember People.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontFamily: 'Inter',
//                               fontWeight: FontWeight.w600,
//                               fontSize: 18,
//                               color: AppColors.white,
//                               height: 1.4,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
                
//                 // Bottom Button Section
//                 Expanded(
//                   flex: 4,
//                   child: Container(
//                     padding: const EdgeInsets.only(bottom: 80.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // Get Started Button - UPDATED
//                         SizedBox(
//                           height: 60,
//                           child: Material(
//                             borderRadius: BorderRadius.circular(16),
//                             clipBehavior: Clip.antiAlias,
//                             child: InkWell(
//                               onTap: () {
//                                 // Navigate to LoginScreen
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => const LoginScreen(),
//                                   ),
//                                 );
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(16),
//                                   gradient: const LinearGradient(
//                                     begin: Alignment.centerLeft,
//                                     end: Alignment.centerRight,
//                                     colors: [
//                                       Color(0xFF00BDE8),
//                                       Color(0xFF00FFD0),
//                                     ],
//                                   ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: AppColors.shadowBlackHeavy,
//                                       blurRadius: 12,
//                                       offset: const Offset(0, 6),
//                                       spreadRadius: 1,
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Stack(
//                                   alignment: Alignment.center,
//                                   children: [
//                                     // Centered Text
//                                     Text(
//                                       "Let's Get Started",
//                                       style: TextStyle(
//                                         color: AppColors.primaryBlue,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w700,
//                                         fontFamily: 'PolySans',
//                                         letterSpacing: 0.5,
//                                       ),
//                                     ),
                                    
//                                     // Icon at the end
//                                     Positioned(
//                                       right: 20,
//                                       child: Icon(
//                                         Icons.arrow_forward_rounded,
//                                         color: AppColors.primaryBlue,
//                                         size: 24,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'login_screen.dart'; // Import the LoginScreen

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Bg_splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Content
                Expanded(
                  flex: 7,
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/GetStarted-1.png',
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Text(
                            'The Smart Way to Remember People.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: AppColors.white,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Button Section
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Get Started Button - UPDATED with slide transition
                        SizedBox(
                          height: 60,
                          child: Material(
                            borderRadius: BorderRadius.circular(16),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                // Navigate to LoginScreen with GetX
                                Get.toNamed('/login');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      AppColors.lightBlue,
                                      AppColors.cyan,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowBlackHeavy,
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Centered Text
                                    Text(
                                      "Let's Get Started",
                                      style: TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'PolySans',
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    
                                    // Icon at the end
                                    Positioned(
                                      right: 20,
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        color: AppColors.primaryBlue,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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