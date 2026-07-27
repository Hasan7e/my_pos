import 'package:flutter_test/flutter_test.dart';
import 'package:my_pos/services/payment_calculator.dart';

void main() {
  group('PaymentCalculator.remainingBalanceCents', () {
    test('returns the full total when no payment has been made', () {
      final remaining = PaymentCalculator.remainingBalanceCents(
        cartTotalCents: 2500,
        cashPaidCents: 0,
        cardPaidCents: 0,
      );

      expect(remaining, 2500);
    });

    test('subtracts cash and card payments for a split payment', () {
      final remaining = PaymentCalculator.remainingBalanceCents(
        cartTotalCents: 2500,
        cashPaidCents: 1000,
        cardPaidCents: 750,
      );

      expect(remaining, 750);
    });

    test('never returns a negative balance when cash exceeds the total', () {
      final remaining = PaymentCalculator.remainingBalanceCents(
        cartTotalCents: 2500,
        cashPaidCents: 3000,
        cardPaidCents: 0,
      );

      expect(remaining, 0);
    });
  });

  group('PaymentCalculator.isCardPaymentValid', () {
    test('accepts a card payment equal to the remaining balance', () {
      expect(
        PaymentCalculator.isCardPaymentValid(
          cardAmountCents: 750,
          remainingBalanceCents: 750,
        ),
        isTrue,
      );
    });

    test('rejects a card payment greater than the remaining balance', () {
      expect(
        PaymentCalculator.isCardPaymentValid(
          cardAmountCents: 800,
          remainingBalanceCents: 750,
        ),
        isFalse,
      );
    });
  });
}
