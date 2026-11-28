import 'package:flutter_test/flutter_test.dart';
import 'package:stockpro/main.dart';

void main() {
  group('canEditManualStockMovement', () {
    final date = DateTime.utc(2026, 11, 28);

    test('allows an unlinked manual receipt', () {
      final movement = Movement('أرز', 'استلام', 5, '', date);
      expect(canEditManualStockMovement(movement), isTrue);
    });

    test('allows an unlinked manual site issue', () {
      final movement = Movement('أرز', 'صرف للموقع', 2, '', date, 'مخزن الموقع');
      expect(canEditManualStockMovement(movement), isTrue);
    });

    test('rejects movements linked to a meal or source operation', () {
      final movement = Movement(
        'أرز', 'صرف', 2, '', date, 'مخزن الموقع', 'meal-day-1',
      );
      expect(canEditManualStockMovement(movement), isFalse);
    });

    test('rejects derived meal consumption and transfers', () {
      final mealConsumption = Movement(
        'أرز', 'استهلاك وجبات', 3, '', date, 'مخزن الموقع', 'meal-day-2',
      );
      final transfer = Movement('أرز', 'تحويل صادر', 4, '', date, 'المخزن الرئيسي');
      expect(canEditManualStockMovement(mealConsumption), isFalse);
      expect(canEditManualStockMovement(transfer), isFalse);
    });
  });
}
