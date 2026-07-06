import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

// ── Time-of-day greeting ──────────────────────────────────────
String timeOfDayGreeting([DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

// ── YPV Level Badge ───────────────────────────────────────────
class LevelBadge extends StatelessWidget {
  final String level;
  const LevelBadge(this.level, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'Level 1':      [AppColors.greenTint,       AppColors.green],
      'Level 2':      [AppColors.blueTint,        AppColors.blue],
      'Level 3':      [AppColors.primaryTint,     AppColors.primary],
      'AUWA':         [AppColors.tealTint,        AppColors.teal],
      'Crystal/PSP':  [AppColors.primaryTint,     AppColors.primary],
      'HDP1':         [AppColors.tealTint,        AppColors.teal],
      'Arhat Trainer':[AppColors.primaryTint2,    AppColors.primary],
    };
    final pair = colors[level] ?? [AppColors.primaryTint, AppColors.primary];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pair[0], borderRadius: BorderRadius.circular(12),
      ),
      child: Text(level, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          letterSpacing: 0.5, color: pair[1])),
    );
  }
}

// ── Avatar (initials) ─────────────────────────────────────────
class YPVAvatar extends StatelessWidget {
  final String name;
  final double size;
  const YPVAvatar({super.key, required this.name, this.size = 40});

  Color _bg() {
    final bgs = [AppColors.primaryTint2, AppColors.tealTile,
                 AppColors.blueTile,     AppColors.greenTile];
    return bgs[(name.isNotEmpty ? name.codeUnitAt(0) : 65) % bgs.length];
  }

  String _initials() {
    final parts = name.trim().split(' ');
    return parts.map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join().substring(0, parts.length >= 2 ? 2 : 1);
  }

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: size / 2,
    backgroundColor: _bg(),
    child: Text(_initials(),
      style: TextStyle(fontSize: size * 0.34, fontWeight: FontWeight.w600,
          color: AppColors.ink, letterSpacing: 0.5)),
  );
}

// ── Primary Button ────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  const PrimaryButton({super.key, required this.label, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
        ? const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : Text(label),
    ),
  );
}

// ── Outlined Button ───────────────────────────────────────────
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  const SecondaryButton({super.key, required this.label, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 52,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color ?? AppColors.primary,
        side: BorderSide(color: color ?? AppColors.primary, width: 1.5),
      ),
      child: Text(label),
    ),
  );
}

// ── White Card ────────────────────────────────────────────────
class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  const WhiteCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(14),
        child: child,
      ),
    ),
  ).withShadow();
}

extension CardShadow on Card {
  Widget withShadow() => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
          blurRadius: 12, offset: const Offset(0, 2))],
    ),
    child: this,
  );
}

// ── Section Header ────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
          letterSpacing: 0.5, color: AppColors.ink)),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.primary)),
        ),
    ],
  );
}

// ── Detail Row (label + value) ────────────────────────────────
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const DetailRow({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, letterSpacing: 0.5, color: AppColors.muted)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
            letterSpacing: 0.5, color: valueColor ?? AppColors.ink)),
      ],
    ),
  );
}

// ── OTP Input row ─────────────────────────────────────────────
class OtpInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const OtpInput({super.key, required this.onChanged});
  @override State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes  = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes)  f.dispose();
    super.dispose();
  }

  void _onChanged(int i, String v) {
    if (v.length > 1) {
      _controllers[i].text = v[v.length - 1];
    }
    final otp = _controllers.map((c) => c.text).join();
    widget.onChanged(otp);
    if (v.isNotEmpty && i < 5) {
      _focusNodes[i + 1].requestFocus();
    } else if (v.isEmpty && i > 0) {
      _focusNodes[i - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(6, (i) => Container(
      width: 44, height: 52, margin: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        controller: _controllers[i],
        focusNode: _focusNodes[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true, fillColor: AppColors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: _controllers[i].text.isNotEmpty ? AppColors.primary : AppColors.line,
              width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
        onChanged: (v) => _onChanged(i, v),
      ),
    )),
  );
}

// ── Search Bar ────────────────────────────────────────────────
class YPVSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const YPVSearchBar({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search, color: AppColors.muted, size: 20),
      filled: true, fillColor: AppColors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ),
  );
}

// ── Pill Filter Chip ──────────────────────────────────────────
class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const PillChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Text(label, style: TextStyle(fontSize: 12, letterSpacing: 0.5,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? Colors.white : AppColors.muted)),
    ),
  );
}

// ── Segment Tabs ──────────────────────────────────────────────
class SegmentTabs extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;
  const SegmentTabs({super.key, required this.tabs, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(tabs.length, (i) => GestureDetector(
      onTap: () => onChanged(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: i == selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(tabs[i], style: TextStyle(fontSize: 14, letterSpacing: 0.5,
            fontWeight: i == selected ? FontWeight.w500 : FontWeight.w400,
            color: i == selected ? Colors.white : AppColors.muted)),
      ),
    )),
  );
}

// ── Info Banner ───────────────────────────────────────────────
class InfoBanner extends StatelessWidget {
  final String message;
  final Color? bg;
  final Color? textColor;
  const InfoBanner({super.key, required this.message, this.bg, this.textColor});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: bg ?? AppColors.primaryTint,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(message, style: TextStyle(fontSize: 12, letterSpacing: 0.5,
        color: textColor ?? AppColors.primary)),
  );
}

// ── Empty State ───────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButton;
  const EmptyState({super.key, required this.title, required this.subtitle,
    this.buttonLabel, this.onButton});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 64, height: 64, decoration: const BoxDecoration(
            shape: BoxShape.circle, color: AppColors.primaryTint),
          child: const Icon(Icons.info_outline, color: AppColors.primary, size: 28)),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
            letterSpacing: 0.5, color: AppColors.ink), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 13, letterSpacing: 0.5,
            color: AppColors.muted, height: 1.6), textAlign: TextAlign.center),
        if (buttonLabel != null) ...[
          const SizedBox(height: 20),
          SizedBox(width: 160, height: 44,
            child: ElevatedButton(onPressed: onButton, child: Text(buttonLabel!))),
        ],
      ]),
    ),
  );
}

// ── Toast helper ─────────────────────────────────────────────
void showYPVToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, style: const TextStyle(letterSpacing: 0.5)),
    backgroundColor: AppColors.ink,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
    duration: const Duration(seconds: 2),
  ));
}

// ── Session Gate (loading / error / content) ──────────────────
class SessionGate extends StatelessWidget {
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final Widget child;
  const SessionGate({super.key, required this.loading, required this.error,
      required this.onRetry, required this.child});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (error != null) {
      return EmptyState(title: 'Something went wrong', subtitle: error!,
          buttonLabel: 'Retry', onButton: onRetry);
    }
    return child;
  }
}

// ── Stat Card (KPI tile) ──────────────────────────────────────
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color valueColor;
  const StatTile({super.key, required this.label, required this.value,
    required this.bg, required this.valueColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600,
          letterSpacing: 0.5, color: valueColor)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 0.5,
          color: AppColors.muted, height: 1.3)),
    ]),
  );
}
