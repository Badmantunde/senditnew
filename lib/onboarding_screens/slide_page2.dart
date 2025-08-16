import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SlidePage2 extends StatelessWidget {
  const SlidePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff1D4135),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55.0, vertical: 150),
        child: Column(
         children: [
           Image.asset('assets/images/pack.png',
           width: 200,),
           SizedBox(height: 40,),
           Text('Real time updates on every delivery',
           textAlign: TextAlign.center,
           style: GoogleFonts.instrumentSans(
             fontSize: 30,
             letterSpacing: -1,
             fontWeight: FontWeight.w700,
             color: Colors.white
             
           ),),
           SizedBox(height: 14,),
        
           Text('We guarantee fast and secure shipping to get your goods where they need to go, quickly and efficiently.',
           textAlign: TextAlign.center,
           style: GoogleFonts.dmSans(
             fontSize: 14,
             letterSpacing: 0.25,
             fontWeight: FontWeight.w400,
             color: Color(0xffF9F9F9)
           ),),
                
         ],
        ),
      )
    );
  }
}