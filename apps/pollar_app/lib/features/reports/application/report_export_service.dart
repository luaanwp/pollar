import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../core/ledger/balance_rules.dart';
import '../domain/report_snapshot.dart';
import 'report_exporter.dart';

class ReportExportService {
  const ReportExportService();

  ReportExportDocument build(ReportCurrencySnapshot report) {
    final buffer = StringBuffer()
      ..writeln('# pollar_report_v1')
      ..writeln('# currency=${report.currency.code}')
      ..writeln('# period_start=${_month(report.periodStart)}')
      ..writeln('# period_end=${_month(report.periodEnd)}')
      ..writeln('# basis=confirmed_and_reconciled')
      ..writeln(
        'id;data;descricao;categoria;tipo;status;moeda;valor_unidades_menores',
      );
    for (final row in report.exportRows) {
      buffer.writeln(
        [
          _cell(row.id),
          _date(row.occurredAt),
          _cell(row.description),
          _cell(row.category),
          _type(row.type),
          row.status.name,
          row.signedAmount.currency.code,
          row.signedAmount.minorUnits,
        ].join(';'),
      );
    }
    final csv = buffer.toString();
    final fileName =
        'pollar-relatorio-${_month(report.periodStart)}-a-${_month(report.periodEnd)}-${report.currency.code}.csv';
    return ReportExportDocument(
      fileName: fileName,
      csv: csv,
      sha256: sha256.convert(utf8.encode(csv)).toString(),
    );
  }

  String _cell(String value) => '"${value.replaceAll('"', '""')}"';

  String _month(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}';

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  String _type(TransactionType type) => switch (type) {
    TransactionType.income => 'receita',
    TransactionType.expense => 'despesa',
    TransactionType.cardPurchase => 'compra_cartao',
    TransactionType.transfer => 'transferencia',
    TransactionType.cardStatementPayment => 'pagamento_fatura',
  };
}
