// import 'package:flutter/material.dart';
// import 'package:health_example/src/utils/theme.dart';

// // Make sure this import is correct

// class VitalsDetailCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final String unit;
//   final String description;

//   const VitalsDetailCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.unit,
//     required this.description,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DetailView(
//               title: title,
//             ),
//           ),
//         );
//       },
//       child: Card(
//         color: AppColors.menuBackground,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title.toUpperCase(),
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: AppColors.mainTextColor2,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: value,
//                       style: const TextStyle(
//                         fontSize: 28,
//                         color: AppColors.mainTextColor1,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextSpan(
//                       text: unit,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: AppColors.mainTextColor2,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 description,
//                 style: const TextStyle(
//                   fontSize: 9,
//                   color: AppColors.mainTextColor2,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class VitalsDetailGridBox extends StatelessWidget {
//   const VitalsDetailGridBox({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Vitals",
//             style: TextStyle(
//               fontSize: 18,
//               color: AppColors.mainTextColor2,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: GridView.count(
//               crossAxisCount: 2,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 24,
//               children: const [
//                 VitalsDetailCard(
//                   //TODO - Add a if condition for this
//                   title: "Sleep",
//                   value: "7h 4m",
//                   unit: "",
//                   description: "Slept at 00:06 AM",
//                 ),
//                 VitalsDetailCard(
//                   title: "Heart Rate",
//                   value: "80",
//                   unit: " bpm",
//                   description: "Last measured 37min ago",
//                 ),
//                 VitalsDetailCard(
//                   title: "Blood Pressure",
//                   value: "125/68",
//                   unit: " mmHg",
//                   description: "Last measured 37min ago",
//                 ),
//                 VitalsDetailCard(
//                   title: "Blood Oxygen",
//                   value: "98%",
//                   unit: "",
//                   description: "Last measured 27 May'24",
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
