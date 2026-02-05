import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_reset_service.dart';

final appResetServiceProvider = Provider<AppResetService>((ref) {
  return AppResetService();
});
