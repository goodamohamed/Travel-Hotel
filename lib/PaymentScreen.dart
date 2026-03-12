import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCard = 0;
  bool _showAddCard = false;

  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _slideAnim;

  final List<Map<String, dynamic>> _savedCards = [
    {
      'number': '**** **** **** 4242',
      'name': 'Ahmed Mohamed',
      'expiry': '12/26',
      'type': 'visa',
      'color': [Color(0xFF1A73E8), Color(0xFF0D47A1)]
    },
    {
      'number': '**** **** **** 8888',
      'name': 'Ahmed Mohamed',
      'expiry': '09/27',
      'type': 'mastercard',
      'color': [Color(0xFFFF6B35), Color(0xFFE55A2B)]
    },
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _toggleAddCard() {
    setState(() => _showAddCard = !_showAddCard);
    if (_showAddCard)
      _animCtrl.forward();
    else
      _animCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F1117) : const Color(0xFFF6F8FF);
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final textPrimary = isDark ? Colors.white : AppTheme.textPrimary;
    final textSecondary = isDark ? Colors.white60 : AppTheme.textSecondary;
    final dividerColor = isDark ? Colors.white12 : AppTheme.divider;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── Header
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1A73E8), const Color(0xFF0A2472)]
                          : [const Color(0xFF1A73E8), const Color(0xFF0D47A1)],
                    ),
                  ),
                ),
                Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06)))),
                Positioned(
                    top: 50,
                    right: 70,
                    child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.04)))),
                SafeArea(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.arrow_back_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Payment Methods',
                                    style: GoogleFonts.playfairDisplay(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                const Text('Manage your cards & wallets',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                              ]),
                        ),
                      ]),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Digital Wallets
                        Text('Digital Wallets',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textSecondary)),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                              child: _WalletButton(
                            icon: Icons.apple_rounded,
                            label: 'Apple Pay',
                            isDark: isDark,
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _WalletButton(
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Google Pay',
                            isDark: isDark,
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                            isGoogle: true,
                          )),
                        ]),
                        const SizedBox(height: 28),

                        // ── Saved Cards
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Saved Cards',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: textSecondary)),
                              GestureDetector(
                                onTap: _toggleAddCard,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xFF1A73E8),
                                      Color(0xFF0D47A1)
                                    ]),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                            _showAddCard
                                                ? Icons.close_rounded
                                                : Icons.add_rounded,
                                            color: Colors.white,
                                            size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                            _showAddCard
                                                ? 'Cancel'
                                                : 'Add Card',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ]),
                                ),
                              ),
                            ]),
                        const SizedBox(height: 14),

                        // Cards list
                        ..._savedCards.asMap().entries.map((e) =>
                            _SavedCardTile(
                              index: e.key,
                              card: e.value,
                              isSelected: _selectedCard == e.key,
                              onTap: () =>
                                  setState(() => _selectedCard = e.key),
                              onDelete: () =>
                                  setState(() => _savedCards.removeAt(e.key)),
                              isDark: isDark,
                              cardBg: cardBg,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              dividerColor: dividerColor,
                            )),

                        // ── Add Card Form
                        SizeTransition(
                          sizeFactor: _slideAnim,
                          child: _AddCardForm(
                            cardNumberCtrl: _cardNumberCtrl,
                            cardNameCtrl: _cardNameCtrl,
                            expiryCtrl: _expiryCtrl,
                            cvvCtrl: _cvvCtrl,
                            isDark: isDark,
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onSave: () {
                              if (_cardNumberCtrl.text.isNotEmpty &&
                                  _cardNameCtrl.text.isNotEmpty) {
                                setState(() {
                                  _savedCards.add({
                                    'number':
                                        '**** **** **** ${_cardNumberCtrl.text.replaceAll(' ', '').substring((_cardNumberCtrl.text.replaceAll(' ', '').length - 4).clamp(0, 100))}',
                                    'name': _cardNameCtrl.text,
                                    'expiry': _expiryCtrl.text,
                                    'type': 'visa',
                                    'color': [
                                      const Color(0xFF10B981),
                                      const Color(0xFF059669)
                                    ],
                                  });
                                  _cardNumberCtrl.clear();
                                  _cardNameCtrl.clear();
                                  _expiryCtrl.clear();
                                  _cvvCtrl.clear();
                                  _showAddCard = false;
                                });
                                _animCtrl.reverse();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        const Text('Card added successfully!'),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wallet Button
class _WalletButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final bool isGoogle;
  const _WalletButton(
      {required this.icon,
      required this.label,
      required this.isDark,
      required this.cardBg,
      required this.textPrimary,
      this.isGoogle = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white12 : AppTheme.divider),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(children: [
          Icon(icon,
              size: 28,
              color: isGoogle ? const Color(0xFF4285F4) : textPrimary),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: textPrimary)),
        ]),
      ),
    );
  }
}

// ── Saved Card Tile
class _SavedCardTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> card;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color dividerColor;

  const _SavedCardTile({
    required this.index,
    required this.card,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = card['color'] as List<Color>;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? Colors.white12 : AppTheme.divider),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(children: [
          // Card chip visual
          Container(
            width: 52,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.credit_card_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(card['number'],
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: textPrimary)),
              const SizedBox(height: 3),
              Text('${card['name']}  •  ${card['expiry']}',
                  style: TextStyle(fontSize: 11, color: textSecondary)),
            ]),
          ),
          if (isSelected)
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                  color: AppTheme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 14),
            )
          else
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 16),
              ),
            ),
        ]),
      ),
    );
  }
}

// ── Add Card Form
class _AddCardForm extends StatelessWidget {
  final TextEditingController cardNumberCtrl;
  final TextEditingController cardNameCtrl;
  final TextEditingController expiryCtrl;
  final TextEditingController cvvCtrl;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onSave;

  const _AddCardForm({
    required this.cardNumberCtrl,
    required this.cardNameCtrl,
    required this.expiryCtrl,
    required this.cvvCtrl,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('New Card',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
        const SizedBox(height: 18),
        _CardField(
            ctrl: cardNumberCtrl,
            label: 'Card Number',
            hint: '0000 0000 0000 0000',
            icon: Icons.credit_card_rounded,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            inputType: TextInputType.number,
            formatter: _CardNumberFormatter()),
        const SizedBox(height: 14),
        _CardField(
            ctrl: cardNameCtrl,
            label: 'Cardholder Name',
            hint: 'Full name on card',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: _CardField(
                  ctrl: expiryCtrl,
                  label: 'Expiry',
                  hint: 'MM/YY',
                  icon: Icons.calendar_today_rounded,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  inputType: TextInputType.number,
                  formatter: _ExpiryFormatter())),
          const SizedBox(width: 14),
          Expanded(
              child: _CardField(
                  ctrl: cvvCtrl,
                  label: 'CVV',
                  hint: '•••',
                  icon: Icons.lock_outline_rounded,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  inputType: TextInputType.number,
                  obscure: true)),
        ]),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onSave,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Center(
                child: Text('Save Card',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15))),
          ),
        ),
      ]),
    );
  }
}

class _CardField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final IconData icon;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final TextInputType inputType;
  final TextInputFormatter? formatter;
  final bool obscure;

  const _CardField({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    this.inputType = TextInputType.text,
    this.formatter,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    final fieldBg = isDark ? const Color(0xFF262A3E) : const Color(0xFFF6F8FF);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white12 : AppTheme.divider),
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: inputType,
          obscureText: obscure,
          inputFormatters: formatter != null ? [formatter!] : [],
          style: TextStyle(
              color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: textSecondary.withOpacity(0.5), fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: AppTheme.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ]);
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final text = next.text.replaceAll(' ', '');
    if (text.length > 16) return old;
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final string = buffer.toString();
    return next.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    var text = next.text.replaceAll('/', '');
    if (text.length > 4) return old;
    if (text.length >= 2) text = '${text.substring(0, 2)}/${text.substring(2)}';
    return next.copyWith(
        text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
