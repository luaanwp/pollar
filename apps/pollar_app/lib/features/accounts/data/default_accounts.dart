import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../domain/account.dart';

/// Demo accounts inserted once when the local database is first created.
List<Account> createDefaultAccounts() => [
  Account(
    id: 'checking-main',
    name: 'Conta principal',
    type: AccountType.checking,
    currency: Currency.brl,
    openingBalance: const Money(minorUnits: 859595, currency: Currency.brl),
  ),
  Account(
    id: 'cash-wallet',
    name: 'Carteira',
    type: AccountType.cash,
    currency: Currency.brl,
    openingBalance: const Money(minorUnits: 18000, currency: Currency.brl),
  ),
  Account(
    id: 'card-gold',
    name: 'Cartão Ouro',
    type: AccountType.creditCard,
    currency: Currency.brl,
    openingBalance: const Money(minorUnits: -27415, currency: Currency.brl),
    creditCardTerms: CreditCardTerms(
      creditLimit: const Money(minorUnits: 500000, currency: Currency.brl),
      closingDay: 20,
      dueDay: 28,
    ),
  ),
];
