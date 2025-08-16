import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? expandedIndex;

  final List<Map<String, String>> faqs = [
    {
      'question': 'Can I cancel or modify my shipment?',
      'answer': 'Yes, you can cancel or modify your shipment before it’s picked up. Contact support for help.'
    },
    {
      'question': 'What precautions do you take when handling sensitive items ?',
      'answer': 'We use special packaging, trained personnel, and track every step for fragile and sensitive items.'
    },
    {
      'question': 'Do you offer warehousing and storage services?',
      'answer': 'Yes, we offer secure warehousing and flexible storage options for various needs.'
    },
    {
      'question': 'Do you provide insurance for shipments?',
      'answer': 'Absolutely. All shipments are insured based on declared value and chosen plan.'
    },
    {
      'question': 'How do I file a claim for a lost or damaged shipment?',
      'answer': 'Go to the Help Center, tap “Report an issue”, and follow the steps to file your claim.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8FA),
      appBar: AppBar(
        title: Text('Frequently Asked Questions', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
             const SizedBox(height: 16),
             Container(
              width: 357, 
              height: 144,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/faq-banner.png'),
                  fit: BoxFit.cover)
              ),
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Text(
                'Frequently Asked Questions', style: GoogleFonts.instrumentSans(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xff1D4135)),
              ),
             ),
           
            const SizedBox(height: 30),
            ...List.generate(faqs.length, (index) {
              final isExpanded = expandedIndex == index;
              return Container(
  margin: const EdgeInsets.only(bottom: 12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    
  ),
  child: ExpansionTile(
    onExpansionChanged: (expanded) {
      setState(() {
        expandedIndex = expanded ? index : null;
      });
    },
    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    title: Text(
      faqs[index]['question']!,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        color: Color(0xff18332F),
        fontWeight: FontWeight.w600,
      ),
    ),
    trailing: Container(
      decoration: BoxDecoration(
        color: isExpanded ? Color(0xffE28E3C) : Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(6),
      child: Icon(
        isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
        size: 16,
        color: isExpanded ? Colors.white : Color(0xff18332F),
      ),
    ),
    children: [
      Text(
        faqs[index]['answer']!,
        style: GoogleFonts.dmSans(fontSize: 13, color: Color(0xff4A4A4A)),
      ),
    ],
  ),
);

            }),
          ],
        ),
      ),
    );
  }
}
