import 'package:flutter/material.dart';

class FAQTile extends StatefulWidget {
  final String question;
  final String answer;

  const FAQTile({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33333333)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          // This keeps the tile divider color isolated if needed
          dividerColor: Colors.grey.shade200, 
        ),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          
          title: Text(
            widget.question,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _isExpanded ? const Color(0xFF1D4ED8) : const Color(0xFF0F172A),
            ),
          ),
          
          onExpansionChanged: (expanding) {
            setState(() {
              _isExpanded = expanding;
            });
          },
          
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isExpanded ? const Color(0xAA1D4ED8) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: _isExpanded ? Colors.white : const Color(0xFF64748B),
                size: 20,
              ),
            ),
          ),
          
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                height: 1,
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(
                left: 30,
                right: 30,
                top: 20, 
                bottom: 24,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.answer,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 40, 56, 65),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}