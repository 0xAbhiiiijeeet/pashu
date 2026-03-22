import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../bookings/presentation/providers/bookings_provider.dart';
import '../../../bookings/domain/models/booking_model.dart';
import 'booking_bottom_sheet.dart';

class BookingsTab extends StatefulWidget {
  final VoidCallback? onBookCallTap;
  
  const BookingsTab({super.key, this.onBookCallTap});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingsProvider>().fetchBooked();
    });
  }

  String _formatTimeSlot(DateTime scheduledTime, AppLocalizations l10n) {
    final hour = scheduledTime.hour;
    if (hour >= 9 && hour < 12) {
      return l10n.between9amTo12pm;
    } else if (hour >= 12 && hour < 15) {
      return l10n.between12pmTo3pm;
    } else if (hour >= 15 && hour < 18) {
      return l10n.between3pmTo6_30pm;
    }
    return l10n.between9amTo12pm;
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    if (l10n.isHindi) {
      return DateFormat('d MMMM yyyy', 'hi').format(date);
    }
    return DateFormat('d MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<BookingsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF666B42),
            ),
          );
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.fetchBooked(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF666B42),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.retry,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final bookings = provider.booked;

        return Container(
          color: const Color(0xFFF8F9FA),
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.yourCalls(bookings.length),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bookings.isEmpty 
                                ? l10n.noCallsBooked 
                                : '${bookings.length} ${bookings.length == 1 ? 'call' : 'calls'}',
                              style: const TextStyle(
                                color: Color(0xFF7A7A7A),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: widget.onBookCallTap ?? () => showBookingBottomSheet(context),
                          icon: const Icon(Icons.add, size: 20),
                          label: Text(
                            l10n.bookACall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF666B42),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Bookings List
              if (bookings.isEmpty)
                SliverFillRemaining(
                  child: Container(
                    color: const Color(0xFFF8F9FA),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F0EA),
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: const Icon(
                                Icons.phone_callback_outlined,
                                size: 56,
                                color: Color(0xFF666B42),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              l10n.noCallsBooked,
                              style: const TextStyle(
                                color: Color(0xFF2C2C2C),
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.isHindi 
                                ? 'अपनी पहली कॉल बुक करें और\nविशेषज्ञ सलाह प्राप्त करें'
                                : 'Book your first call and get\nexpert advice for your animals',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF7A7A7A),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: widget.onBookCallTap ?? () => showBookingBottomSheet(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF666B42),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  l10n.bookYourFirstCall,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final booking = bookings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _BookingCard(
                            booking: booking,
                            l10n: l10n,
                            formatDate: _formatDate,
                            formatTimeSlot: _formatTimeSlot,
                          ),
                        );
                      },
                      childCount: bookings.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final AppLocalizations l10n;
  final String Function(DateTime, AppLocalizations) formatDate;
  final String Function(DateTime, AppLocalizations) formatTimeSlot;

  const _BookingCard({
    required this.booking,
    required this.l10n,
    required this.formatDate,
    required this.formatTimeSlot,
  });

  Color get _statusColor {
    switch (booking.status) {
      case 'pending':
        return Colors.white;
      case 'completed':
        return const Color(0xFFE8F5E9);
      case 'cancelled':
        return const Color(0xFFFFEBEE);
      default:
        return Colors.white;
    }
  }

  Color get _statusBorderColor {
    switch (booking.status) {
      case 'pending':
        return const Color(0xFF666B42);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF666B42);
    }
  }

  IconData get _statusIcon {
    switch (booking.status) {
      case 'pending':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  String get _statusText {
    switch (booking.status) {
      case 'pending':
        return l10n.theCallIsBooked;
      case 'completed':
        return l10n.callCompleted;
      case 'cancelled':
        return l10n.callCancelled;
      default:
        return l10n.theCallIsBooked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _statusColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _statusBorderColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _statusBorderColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _statusIcon,
                  size: 20,
                  color: _statusBorderColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusText,
                    style: TextStyle(
                      color: _statusBorderColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.friendWillCallYou,
                            style: const TextStyle(
                              color: Color(0xFF2C2C2C),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (booking.problem != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4F1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: Color(0xFF666B42),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      l10n.isHindi 
                                        ? booking.problem!.title 
                                        : booking.problem!.titleEn,
                                      style: const TextStyle(
                                        color: Color(0xFF666B42),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Color(0xFF666B42),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    formatTimeSlot(booking.scheduledTime, l10n),
                                    style: const TextStyle(
                                      color: Color(0xFF666B42),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatDate(booking.scheduledTime, l10n),
                              style: const TextStyle(
                                color: Color(0xFF7A7A7A),
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
