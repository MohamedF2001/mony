// lib/core/utils/formatters.dart

import 'package:intl/intl.dart';

class Formatters {
  static String defaultCurrency = 'F CFA';

  // Money Formatting
  static String formatMoney(num amount, {String? currency}) {
    final effectiveCurrency = currency ?? defaultCurrency;
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} $effectiveCurrency';
  }

  static String formatMoneyCompact(num amount, {String? currency}) {
    final effectiveCurrency = currency ?? defaultCurrency;
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $effectiveCurrency';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $effectiveCurrency';
    }
    return formatMoney(amount, currency: effectiveCurrency);
  }

  // Date Formatting
  static String formatDate(DateTime date, {String pattern = 'd MMM yyyy'}) {
    return DateFormat(pattern, 'fr_FR').format(date);
  }
  
  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
  }
  
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yy', 'fr_FR').format(date);
  }
  
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'fr_FR').format(date);
  }
  
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Aujourd\'hui';
    } else if (dateOnly == yesterday) {
      return 'Hier';
    } else if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE', 'fr_FR').format(date);
    } else if (dateOnly.year == now.year) {
      return DateFormat('d MMM', 'fr_FR').format(date);
    }
    return DateFormat('d MMM yyyy', 'fr_FR').format(date);
  }
  
  // Period Formatting
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'fr_FR').format(date);
  }
  
  static String formatMonthShort(DateTime date) {
    return DateFormat('MMM', 'fr_FR').format(date).toUpperCase();
  }
  
  static String formatYear(DateTime date) {
    return date.year.toString();
  }
  
  // Number Formatting
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
  
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return formatter.format(number);
  }
}

extension NumFormatting on num {
  String toFormattedMoney({String? currency}) =>
    Formatters.formatMoney(this, currency: currency);
  
  String toCompactMoney({String? currency}) =>
    Formatters.formatMoneyCompact(this, currency: currency);
  
  String toPercentage() => Formatters.formatPercentage(toDouble());
}

// Extension for easier access
extension DateTimeFormatting on DateTime {
  String toRelativeString() => Formatters.formatRelativeDate(this);
  String toMonthYear() => Formatters.formatMonthYear(this);
  String toFormattedDate() => Formatters.formatDate(this);
  String toFormattedDateLong() => Formatters.formatDateLong(this);
}
