import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/accounts/domain/account.dart';

void main() {
  const brl = Currency.brl;

  Money brlOf(int minorUnits) => Money(minorUnits: minorUnits, currency: brl);

  test('normalizes identity fields and starts active', () {
    final account = Account(
      id: ' checking-1 ',
      name: ' Conta principal ',
      type: AccountType.checking,
      currency: brl,
      openingBalance: brlOf(12500),
    );

    expect(account.id, 'checking-1');
    expect(account.name, 'Conta principal');
    expect(account.status, AccountStatus.active);
    expect(account.isCreditCard, isFalse);
  });

  test('rejects empty identity fields', () {
    expect(
      () => Account(
        id: ' ',
        name: 'Conta',
        type: AccountType.cash,
        currency: brl,
        openingBalance: Money.zero(brl),
      ),
      throwsArgumentError,
    );
    expect(
      () => Account(
        id: 'cash-1',
        name: ' ',
        type: AccountType.cash,
        currency: brl,
        openingBalance: Money.zero(brl),
      ),
      throwsArgumentError,
    );
  });

  test('opening balance must use the account currency', () {
    expect(
      () => Account(
        id: 'checking-1',
        name: 'Conta',
        type: AccountType.checking,
        currency: brl,
        openingBalance: const Money(minorUnits: 100, currency: Currency.usd),
      ),
      throwsA(isA<CurrencyMismatchError>()),
    );
  });

  test('credit card requires valid billing terms in its currency', () {
    expect(
      () => Account(
        id: 'card-1',
        name: 'Cartão Ouro',
        type: AccountType.creditCard,
        currency: brl,
        openingBalance: brlOf(-23000),
      ),
      throwsArgumentError,
    );

    final terms = CreditCardTerms(
      creditLimit: brlOf(500000),
      closingDay: 20,
      dueDay: 28,
    );
    final card = Account(
      id: 'card-1',
      name: 'Cartão Ouro',
      type: AccountType.creditCard,
      currency: brl,
      openingBalance: brlOf(-23000),
      creditCardTerms: terms,
    );

    expect(card.isCreditCard, isTrue);
    expect(card.creditCardTerms, terms);
  });

  test('non-card accounts reject billing terms', () {
    final terms = CreditCardTerms(
      creditLimit: brlOf(100000),
      closingDay: 10,
      dueDay: 17,
    );
    expect(
      () => Account(
        id: 'cash-1',
        name: 'Carteira',
        type: AccountType.cash,
        currency: brl,
        openingBalance: Money.zero(brl),
        creditCardTerms: terms,
      ),
      throwsArgumentError,
    );
  });

  test('credit-card limit is positive and billing days are calendar days', () {
    expect(
      () => CreditCardTerms(
        creditLimit: Money.zero(brl),
        closingDay: 10,
        dueDay: 17,
      ),
      throwsArgumentError,
    );
    expect(
      () => CreditCardTerms(
        creditLimit: brlOf(100000),
        closingDay: 0,
        dueDay: 17,
      ),
      throwsRangeError,
    );
    expect(
      () => CreditCardTerms(
        creditLimit: brlOf(100000),
        closingDay: 10,
        dueDay: 32,
      ),
      throwsRangeError,
    );
  });

  test('rename, archive and restore return new valid values', () {
    final original = Account(
      id: 'cash-1',
      name: 'Carteira',
      type: AccountType.cash,
      currency: brl,
      openingBalance: Money.zero(brl),
    );

    final renamed = original.rename('Dinheiro');
    final archived = renamed.archive();
    final restored = archived.restore();

    expect(original.name, 'Carteira');
    expect(renamed.name, 'Dinheiro');
    expect(archived.isArchived, isTrue);
    expect(restored.status, AccountStatus.active);
  });
}
