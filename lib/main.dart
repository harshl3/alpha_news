import 'package:alpha_news/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALPHA NEWS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3290DD),//Color(0xff5b81dc), // AppBar color sab pages par same
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: Home(),
    );
  }
}




// /// ✅ Wrapper to apply gradient background safely
// class HomeWrapper extends StatelessWidget {
//   const HomeWrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return  GradientBackground(
//         child: const Home(),
//
//     );
//   }
// }
//
//
//
// /// 🔥 Reusable Gradient Background Wrapper
// class GradientBackground extends StatelessWidget {
//   final Widget child;
//   const GradientBackground({super.key, required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color(0xFFfbc2eb), // pink
//             Color(0xFFa6c1ee), // blue
//           ],
//           begin: Alignment.bottomCenter,
//           end: Alignment.topCenter,
//         ),
//       ),
//       child: child,
//     );
//   }
// }
