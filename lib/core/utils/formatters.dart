/* // lib/core/utils/formatters.dart

import 'package:intl/intl.dart';

class Formatters {
  // Money Formatting
  static String formatMoney(double amount, {String currency = 'F CFA'}) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} $currency';
  }

  static String formatMoneyCompact(double amount, {String currency = 'F CFA'}) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $currency';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $currency';
    }
    return formatMoney(amount, currency: currency);
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

// Extension for easier access
extension DateTimeFormatting on DateTime {
  String toRelativeString() => Formatters.formatRelativeDate(this);
  String toMonthYear() => Formatters.formatMonthYear(this);
  String toFormattedDate() => Formatters.formatDate(this);
  String toFormattedDateLong() => Formatters.formatDateLong(this);
}

extension DoubleFormatting on double {
  String toFormattedMoney({String currency = 'F CFA'}) =>
      Formatters.formatMoney(this, currency: currency);
  String toCompactMoney({String currency = 'F CFA'}) =>
      Formatters.formatMoneyCompact(this, currency: currency);
  String toPercentage() => Formatters.formatPercentage(this);
}
 */

// lib/core/utils/formatters.dart

import 'package:intl/intl.dart';

class Formatters {
  // Money Formatting
  static String formatMoney(int amount, {String currency = 'F CFA'}) {
    //final formatter = NumberFormat('#,##0.00', 'fr_FR');
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(amount)} $currency';
  }
  
  /*static String formatMoneyCompact(int amount, {String currency = 'F CFA'}) {
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $currency';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $currency';
    }
    return formatMoney(amount, currency: currency);
  }*/

  static String formatMoneyCompact(int amount, {String currency = 'F CFA'}) {
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).round()}M $currency';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).round()}K $currency';
    }
    return formatMoney(amount, currency: currency);
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
  String toFormattedMoney({String currency = 'F CFA'}) => 
    Formatters.formatMoney(toInt(), currency: currency);
  
  String toCompactMoney({String currency = 'F CFA'}) => 
    Formatters.formatMoneyCompact(toInt(), currency: currency);
  
  String toPercentage() => Formatters.formatPercentage(toDouble());
}

// Extension for easier access
extension DateTimeFormatting on DateTime {
  String toRelativeString() => Formatters.formatRelativeDate(this);
  String toMonthYear() => Formatters.formatMonthYear(this);
  String toFormattedDate() => Formatters.formatDate(this);
  String toFormattedDateLong() => Formatters.formatDateLong(this);
}

/*extension DoubleFormatting on double {
  String toFormattedMoney({String currency = 'F CFA'}) => 
    Formatters.formatMoney(this, currency: currency);
  String toCompactMoney({String currency = 'F CFA'}) => 
    Formatters.formatMoneyCompact(this, currency: currency);
  String toPercentage() => Formatters.formatPercentage(this);
}*/

// Extension pour int aussi
extension IntFormatting on int {
  String toFormattedMoney({String currency = 'F CFA'}) => 
    Formatters.formatMoney(toInt(), currency: currency);
  String toCompactMoney({String currency = 'F CFA'}) => 
    Formatters.formatMoneyCompact(toInt(), currency: currency);
}