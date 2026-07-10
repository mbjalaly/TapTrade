import 'package:flutter/material.dart';

class AvatarSlider extends StatefulWidget {
  const AvatarSlider({super.key});

  @override
  State<AvatarSlider> createState() => _AvatarSliderState();
}

class _AvatarSliderState extends State<AvatarSlider> {
  static const List<_AvatarItem> _males = [
    _AvatarItem('assets/avatarProfile/male_1_formal.png', 'Formal'),
    _AvatarItem('assets/avatarProfile/male_2_business.png', 'Business'),
    _AvatarItem('assets/avatarProfile/male_3_smart_casual.png', 'Smart'),
    _AvatarItem('assets/avatarProfile/male_4_casual.png', 'Casual'),
    _AvatarItem('assets/avatarProfile/male_5_streetwear.png', 'Street'),
  ];
  static const List<_AvatarItem> _females = [
    _AvatarItem('assets/avatarProfile/female_1_formal.png', 'Formal'),
    _AvatarItem('assets/avatarProfile/female_2_business.png', 'Business'),
    _AvatarItem('assets/avatarProfile/female_3_smart_casual.png', 'Smart'),
    _AvatarItem('assets/avatarProfile/female_4_casual.png', 'Casual'),
    _AvatarItem('assets/avatarProfile/female_5_sporty.png', 'Sporty'),
  ];

  String? _selected;

  Widget _row(List<_AvatarItem> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.map((a) {
        final sel = _selected == a.path;
        return GestureDetector(
          onTap: () => setState(() => _selected = a.path),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: sel ? const Color(0xFF00BCD4) : Colors.grey.shade300,
                    width: sel ? 3.0 : 1.5,
                  ),
                  boxShadow: sel
                      ? [
                    BoxShadow(
                      color: const Color(0xFF00BCD4).withOpacity(0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                      : null,
                ),
                child: ClipOval(child: Image.asset(a.path, fit: BoxFit.cover)),
              ),
              const SizedBox(height: 5),
              Text(
                a.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                  color: sel ? const Color(0xFF00BCD4) : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionHeader(String label, Color bg, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: Colors.grey[700]),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Choose Your Avatar',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          _sectionHeader('Male', const Color(0xFFE3F0FF), Icons.person_outline),
          const SizedBox(height: 10),
          _row(_males),
          const SizedBox(height: 20),
          _sectionHeader(
              'Female', const Color(0xFFFFE8F0), Icons.person_2_outlined),
          const SizedBox(height: 10),
          _row(_females),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () => Navigator.pop(context, _selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Select Avatar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarItem {
  final String path;
  final String label;
  const _AvatarItem(this.path, this.label);
}