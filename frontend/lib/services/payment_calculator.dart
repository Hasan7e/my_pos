class PaymentCalculator {
  PaymentCalculator._();

  static int remainingBalanceCents({
    required int cartTotalCents,
    required int cashPaidCents,
    required int cardPaidCents,
  }) {
    final remaining = cartTotalCents - cashPaidCents - cardPaidCents;
    return remaining < 0 ? 0 : remaining;
  }

  static bool isCardPaymentValid({
    required int cardAmountCents,
    required int remainingBalanceCents,
  }) {
    return cardAmountCents <= remainingBalanceCents;
  }
}
