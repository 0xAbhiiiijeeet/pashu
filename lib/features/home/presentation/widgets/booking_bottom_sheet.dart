import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../bookings/presentation/providers/bookings_provider.dart';
import '../../../subscription/presentation/widgets/subscription_gate.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Time slot constants
// ─────────────────────────────────────────────────────────────────────────────

class _TimeSlot {
  static const String morning = 'morning';
  static const String afternoon = 'afternoon';
  static const String evening = 'evening';

  static const List<String> values = [morning, afternoon, evening];
}

extension _TimeSlotExt on String {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case _TimeSlot.morning:
        return l10n.morning;
      case _TimeSlot.afternoon:
        return l10n.afternoon;
      case _TimeSlot.evening:
        return l10n.evening;
      default:
        return 'Unknown';
    }
  }

  String range(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case _TimeSlot.morning:
        return l10n.between9to12;
      case _TimeSlot.afternoon:
        return l10n.between12to3;
      case _TimeSlot.evening:
        return l10n.between3to6;
      default:
        return 'Unknown';
    }
  }

  /// Returns the hour to use for scheduledTime based on the slot.
  int get startHour {
    switch (this) {
      case _TimeSlot.morning:
        return 9;
      case _TimeSlot.afternoon:
        return 12;
      case _TimeSlot.evening:
        return 15;
      default:
        return 9;
    }
  }

  /// Returns true if this slot is still available for today at [now].
  bool isAvailableToday(DateTime now) {
    switch (this) {
      case _TimeSlot.morning:
        // Morning ends at 12pm
        return now.hour < 12;
      case _TimeSlot.afternoon:
        // Afternoon ends at 3pm
        return now.hour < 15;
      case _TimeSlot.evening:
        // Evening ends at 18:30
        return now.hour < 18 || (now.hour == 18 && now.minute < 30);
      default:
        return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper to show the bottom sheet with subscription gate
// ─────────────────────────────────────────────────────────────────────────────

void showBookingBottomSheet(BuildContext context,
    {String? problemId, String? problemLabel}) async {
  // Check subscription access first
  final hasAccess = await SubscriptionGate.checkAccess(context);

  if (!hasAccess || !context.mounted) {
    return;
  }

  // User has access, show booking bottom sheet
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BookingBottomSheetContent(
      problemId: problemId,
      problemLabel: problemLabel,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet content — stateful for time-slot selection
// ─────────────────────────────────────────────────────────────────────────────

class _BookingBottomSheetContent extends StatefulWidget {
  final String? problemId;
  final String? problemLabel;

  const _BookingBottomSheetContent({
    this.problemId,
    this.problemLabel,
  });

  @override
  State<_BookingBottomSheetContent> createState() =>
      _BookingBottomSheetContentState();
}

class _BookingBottomSheetContentState
    extends State<_BookingBottomSheetContent> {
  String? _selected;
  bool _isBooking = false;

  // ── Time / date helpers ────────────────────────────────────────────────────

  DateTime get _now => DateTime.now();

  /// True when all today's slots are exhausted (past 6:30 pm).
  bool get _todayExhausted {
    final n = _now;
    return n.hour > 18 || (n.hour == 18 && n.minute >= 30);
  }

  /// The booking date (today or tomorrow).
  DateTime get _bookingDate =>
      _todayExhausted ? _now.add(const Duration(days: 1)) : _now;

  String get _dateLabel {
    final d = _bookingDate;
    final months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final base = '${d.day} ${months[d.month]}';
    return _todayExhausted ? '$base (Tomorrow)' : base;
  }

  String get _buttonDateLabel {
    final d = _bookingDate;
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month]}';
  }

  /// Full date label for the confirmation dialog, e.g. "February 26, Morning (9am-12pm)".
  String get _fullDateLabel {
    final d = _bookingDate;
    final months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[d.month]} ${d.day}';
  }

  /// First available slot for the booking date.
  String get _defaultSlot {
    if (_todayExhausted) return _TimeSlot.morning;
    for (final s in _TimeSlot.values) {
      if (s.isAvailableToday(_now)) return s;
    }
    return _TimeSlot.morning;
  }

  bool _isSlotDisabled(String slot) {
    if (_todayExhausted) return false; // tomorrow — all slots open
    return !slot.isAvailableToday(_now);
  }

  /// Shows the "Call booked" confirmation dialog.
  static void _showCallBookedDialog(
    BuildContext context, {
    required String dateLabel,
    required String slot,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Green check image
              Image.asset(
                'assets/images/call_booked_check.png',
                width: 81,
                height: 81,
              ),
              const SizedBox(height: 16),
              // "Call booked"
              Text(
                AppLocalizations.of(context).callBookedTitle,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 0.73,
                ),
              ),
              const SizedBox(height: 14),
              // "Pashu Mitra will call you"
              Text(
                AppLocalizations.of(context).friendWillCall,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              // Date + slot in blue
              Text(
                '$dateLabel, ${slot.label(context).toLowerCase()} (${slot.range(context)})',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1B71C8),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  height: 1.20,
                ),
              ),
              const SizedBox(height: 24),
              // Ok button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF666B42),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context).ok,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 0.92,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selected = _defaultSlot;
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  static const _green = Color(0xFF666B42);
  static const _greenLight = Color(0xFF838967);
  static const _textGrey = Color(0xFF777777);
  static const _cardBg = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header: Talk to MITR ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show problem label if provided
                if (widget.problemLabel != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7E4DA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xFF666B42),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            l10n.problem(widget.problemLabel!),
                            style: const TextStyle(
                              color: Color(0xFF666B42),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${l10n.talkTo} ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                      ),
                    ),
                    Text(
                      l10n.mitr,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w700,
                        height: 1.10,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Small leaf/verified icon placeholder
                    Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: Color(0xFF666B42),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Sub-info: availability | experience | solution (wrapping)
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.availability9to6,
                      style: const TextStyle(
                          color: _textGrey, fontSize: 12, height: 1.6),
                    ),
                    const SizedBox(
                        width: 0,
                        height: 14,
                        child: VerticalDivider(
                            color: Color(0xFF959595), thickness: 1)),
                    Text(
                      l10n.tenYearsExperience,
                      style: const TextStyle(
                          color: _textGrey, fontSize: 12, height: 1.6),
                    ),
                    const SizedBox(
                        width: 0,
                        height: 14,
                        child: VerticalDivider(
                            color: Color(0xFF959595), thickness: 1)),
                    Text(
                      l10n.exactSolution,
                      style: const TextStyle(
                          color: _textGrey, fontSize: 12, height: 1.6),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFC9C9C9)),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── "Time is up" warning (only when today is exhausted) ──
                if (_todayExhausted) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1D7),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: const Color(0xFFE6D0A9)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ⓘ',
                          style: TextStyle(
                            color: Color(0xFFF4A00C),
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.timeIsUpToday,
                            style: const TextStyle(
                              color: Color(0xFFF29E17),
                              fontSize: 16,
                              height: 1.38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Date label ───────────────────────────────────────────
                Text(
                  _dateLabel,
                  style: const TextStyle(
                    color: _green,
                    fontSize: 16,
                    height: 1.38,
                  ),
                ),
                const SizedBox(height: 2),

                // ── "What time…" ─────────────────────────────────────────
                Text(
                  l10n.whatTimeToTalk,
                  style: const TextStyle(
                    color: Color(0xFF252912),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.38,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Time slot chips ───────────────────────────────────────
                Row(
                  children: _TimeSlot.values.map((slot) {
                    final isSelected = _selected == slot;
                    final isDisabled = _isSlotDisabled(slot);
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: slot != _TimeSlot.evening ? 8 : 0,
                        ),
                        child: GestureDetector(
                          onTap: isDisabled
                              ? null
                              : () => setState(() => _selected = slot),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 55,
                            decoration: BoxDecoration(
                              color: isDisabled
                                  ? const Color(0xFFEEEEEE)
                                  : isSelected
                                      ? _green
                                      : _cardBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  slot.label(context),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDisabled
                                        ? Colors.grey
                                        : isSelected
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  slot.range(context),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDisabled
                                        ? Colors.grey
                                        : isSelected
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 12,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // ── Book a call button ────────────────────────────────────
                GestureDetector(
                  onTap: (_selected == null || _isBooking)
                      ? null
                      : () async {
                          setState(() => _isBooking = true);

                          final slot = _selected!;
                          final bookingDate = _bookingDate;

                          // Create scheduledTime with the slot's start hour
                          final scheduledTime = DateTime(
                            bookingDate.year,
                            bookingDate.month,
                            bookingDate.day,
                            slot.startHour,
                          );

                          // Call the API
                          final bookingsProvider =
                              context.read<BookingsProvider>();
                          final success = await bookingsProvider.bookCall(
                            problemId: widget.problemId ?? 'general',
                            scheduledTime: scheduledTime,
                          );

                          if (mounted) {
                            setState(() => _isBooking = false);
                          }

                          if (success && mounted) {
                            final dateLabel = _fullDateLabel;
                            Navigator.of(context).pop();
                            _showCallBookedDialog(
                              context,
                              dateLabel: dateLabel,
                              slot: slot,
                            );
                          } else if (mounted) {
                            // Show error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  bookingsProvider.errorMessage ??
                                      l10n.unableToBookCall,
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: (_selected == null || _isBooking)
                          ? _greenLight
                          : _green,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _isBooking
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Left: date + slot label
                              if (_selected != null)
                                Flexible(
                                  child: Text(
                                    '$_buttonDateLabel, ${_selected!.label(context)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.22,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (_selected != null) const SizedBox(width: 8),
                              // Right: "Book a call"
                              Text(
                                l10n.bookACall,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
