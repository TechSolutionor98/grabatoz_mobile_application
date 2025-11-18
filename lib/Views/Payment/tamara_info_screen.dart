import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TamaraInfoScreen extends StatelessWidget {
  final double price;
  const TamaraInfoScreen({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final two = (price / 2.0);
    final three = (price / 3.0);
    final four = (price / 4.0);
    final full = price;

    TextStyle label = const TextStyle(fontSize: 12, color: Color(0xFF374151));
    TextStyle bold = const TextStyle(fontSize: 12, color: Color(0xFF111827), fontWeight: FontWeight.w600);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Page content
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Close icon that scrolls with content
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.close, color: Colors.black87, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 0),
                      // Tamara pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFBC7B8), Color(0xFFD299F3)],
                          ),
                        ),
                        child: const Text(
                          'tamara',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                          children: [
                            const TextSpan(
                              text: 'Your payment,',
                              style: TextStyle(color: Colors.black),
                            ),
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text: 'your pace',
                              style: TextStyle(
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                                  ).createShader(const Rect.fromLTWH(0, 0, 220, 40)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Payment options
                      _optionRow(context, 'Ð ${two.toStringAsFixed(2)}', '/mo', 'No fees', '2 Payments'),
                      const SizedBox(height: 8),
                      _optionRow(context, 'Ð ${three.toStringAsFixed(2)}', '/mo', 'No fees', '3 Payments'),
                      const SizedBox(height: 8),
                      _optionRow(context, 'Ð ${four.toStringAsFixed(2)}', '/mo', 'No fees', '4 Payments'),
                      const SizedBox(height: 8),
                      _optionRow(context, 'Ð ${full.toStringAsFixed(2)}', '', 'No fees', 'Pay in Full'),

                      const SizedBox(height: 20),
                      // How it works
                      const Text('How it works?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: const [
                            _HowItWorksItem(
                              n: 1,
                              title: 'Pick a plan that works for you',
                              desc: 'Choose Tamara at checkout and select the payment plan that fits your needs.',
                            ),
                            SizedBox(height: 10),
                            SizedBox(height: 10),
                            _HowItWorksItem(
                              n: 2,
                              title: 'Pay your first payment securely',
                              desc: 'Enter your card details to make your first payment safely and instantly.',
                            ),
                            SizedBox(height: 10),
                            SizedBox(height: 10),
                            _HowItWorksItem(
                              n: 3,
                              title: 'Stay in control',
                              desc: 'Track and manage all your upcoming payments easily in the Tamara app.',
                            ),
                            SizedBox(height: 10),
                            SizedBox(height: 10),
                            _HowItWorksItem(
                              n: 4,
                              title: 'We’ve got your back',
                              desc: 'Get helpful reminders before each payment, no surprises.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Why Tamara
                      const Text('Why Tamara?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          _WhyIcon(icon: Icons.shield_outlined, color: Colors.green, text: '100%\nbuyer protection'),
                          _WhyIcon(icon: Icons.verified, color: Colors.blue, text: 'Sharia\ncompliant'),
                          _WhyIcon(icon: Icons.close, color: Colors.purple, text: 'No late\nfees'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Disclaimer
                      Text.rich(
                        TextSpan(
                          style: label,
                          children: [
                            const TextSpan(
                              text:
                                  'Payment plans shown are estimates. Actual offers may vary based on your eligibility and order details. Approval is subject to eligibility checks and may require a down payment. Final terms may exclude taxes, shipping, or other charges. For more information, see our ',
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {},
                                child: const Text(
                                  'Terms & Conditions',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Color(0xFF7C3AED),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Payment badges (visual only)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _badge('Pay'),
                          const SizedBox(width: 8),
                          _badge('MC', bg: const LinearGradient(colors: [Colors.orange, Colors.red]), color: Colors.white),
                          const SizedBox(width: 8),
                          _badge('VISA', solid: Colors.blue, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionRow(BuildContext context, String amount, String suffix, String sub, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                  if (suffix.isNotEmpty)
                    Text(' $suffix', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: const [
                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  Text('No fees', style: TextStyle(fontSize: 11, color: Colors.green)),
                ],
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(tag, style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  static Widget _howItWorksStep(int n, String title, String desc) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(999)),
            child: Text('$n', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
            ]),
          ),
        ],
      ),
    );
  }

  static Widget _badge(String text, {LinearGradient? bg, Color? solid, Color color = Colors.black}) {
    final decoration = bg != null
        ? BoxDecoration(gradient: bg, borderRadius: BorderRadius.circular(4))
        : BoxDecoration(color: solid ?? Colors.transparent, borderRadius: BorderRadius.circular(4), border: solid == null ? Border.all(color: Colors.black54) : null);
    return Container(
      width: 32,
      height: 24,
      alignment: Alignment.center,
      decoration: decoration,
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _WhyIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _WhyIcon({required this.icon, required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
      ],
    );
  }
}

class _HowItWorksItem extends StatelessWidget {
  final int n;
  final String title;
  final String desc;
  const _HowItWorksItem({required this.n, required this.title, required this.desc});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(999)),
          child: Text('$n', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
            ],
          ),
        ),
      ],
    );
  }
}
