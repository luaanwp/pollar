// THESIS: O relatório é uma trilha de evidências do livro-caixa; recusa gráficos decorativos e métricas sem reconciliação.
// OWN-WORLD: Uma faixa financeira sólida, evidências planas, teal restrito e figuras tabulares exatas do Pollar.
// STORY: A pessoa compara seis meses, confere o saldo líquido, identifica categorias e exporta a mesma base com verificação.
// FIRST VIEWPORT: Período e moeda antecedem o resultado; critério expansível e exportação apoiam gráficos e tabelas exatas.
// FORM: Extensão operacional do livro-caixa sereno, herdando o sistema estabelecido sem concept seed.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/privacy/privacy_mode_provider.dart';
import '../../../app/theme/pollar_theme.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_form_controls.dart';
import '../../../shared/presentation/pollar_motion.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../../../shared/presentation/pollar_toast.dart';
import '../../../shared/presentation/money_text.dart';
import '../../../shared/presentation/privacy_amount.dart';
import '../../../shared/presentation/status_badge.dart';
import '../domain/report_snapshot.dart';
import 'reports_controller.dart';
import 'widgets/report_charts.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportsProvider);
    return reports.when(
      skipLoadingOnReload: true,
      loading: () => const PollarLoadingState(
        message: 'Consolidando os últimos seis meses…',
      ),
      error: (error, stackTrace) => PollarErrorState(
        title: 'Não foi possível montar os relatórios',
        message: 'Os lançamentos continuam salvos. Tente consolidar os dados novamente.',
        actionLabel: 'Recalcular relatórios',
        onRetry: ref.read(reportsProvider.notifier).retry,
      ),
      data: (snapshot) => _ReportsContent(snapshot: snapshot),
    );
  }
}

class _ReportsContent extends ConsumerStatefulWidget {
  const _ReportsContent({required this.snapshot});

  final ReportSnapshot snapshot;

  @override
  ConsumerState<_ReportsContent> createState() => _ReportsContentState();
}

class _ReportsContentState extends ConsumerState<_ReportsContent> {
  Currency? _selectedCurrency;
  var _exporting = false;

  @override
  Widget build(BuildContext context) {
    final privacyHidden = ref.watch(privacyModeProvider);
    final snapshot = widget.snapshot;
    final report =
        (_selectedCurrency == null
            ? null
            : snapshot.reportFor(_selectedCurrency!)) ??
        snapshot.reportFor(Currency.brl) ??
        (snapshot.reports.isEmpty ? null : snapshot.reports.first);

    if (report == null) return const _EmptyReports();
    final period = _periodLabel(report);

    return LayoutBuilder(
      builder: (context, viewport) {
        final compact =
            viewport.maxWidth < 760 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: PollarSizes.dashboardMax,
            ),
            child: ListView(
              padding: EdgeInsets.all(
                compact ? PollarSpacing.x4 : PollarSpacing.x6,
              ),
              children: [
                _ReportHeader(
                  compact: compact,
                  period: period,
                  reports: snapshot.reports,
                  selectedCurrency: report.currency,
                  exporting: _exporting,
                  onCurrencyChanged: (value) =>
                      setState(() => _selectedCurrency = value),
                  onExport: () => _export(report),
                ),
                const SizedBox(height: PollarSpacing.x5),
                _ReportSummary(report: report, privacyHidden: privacyHidden),
                const SizedBox(height: PollarSpacing.x4),
                if (compact) ...[
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: PollarButton(
                      label: 'Exportar CSV',
                      leadingIcon: LucideIcons.download,
                      variant: PollarButtonVariant.secondary,
                      adaptiveHeight: true,
                      loading: _exporting,
                      onPressed: _exporting ? null : () => _export(report),
                    ),
                  ),
                  const SizedBox(height: PollarSpacing.x3),
                ],
                _ReportBasis(period: period),
                const SizedBox(height: PollarSpacing.x6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textScale = MediaQuery.textScalerOf(context).scale(1);
                    final sideBySide =
                        constraints.maxWidth >= 880 && textScale <= 1.3;
                    final flow = _MonthlyFlow(
                      report: report,
                      privacyHidden: privacyHidden,
                    );
                    final balance = _BalanceHistory(
                      report: report,
                      privacyHidden: privacyHidden,
                    );
                    if (!sideBySide) {
                      return Column(
                        children: [
                          flow,
                          const SizedBox(height: PollarSpacing.x6),
                          balance,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: flow),
                        const SizedBox(width: PollarSpacing.x6),
                        Expanded(flex: 4, child: balance),
                      ],
                    );
                  },
                ),
                const SizedBox(height: PollarSpacing.x6),
                _CategoryComposition(
                  report: report,
                  privacyHidden: privacyHidden,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _export(ReportCurrencySnapshot report) async {
    setState(() => _exporting = true);
    try {
      final result = await ref.read(reportsProvider.notifier).export(report);
      if (!mounted) return;
      showPollarToast(
        context,
        message:
            'Relatório CSV e verificação SHA-256 salvos em ${result.csvPath}.',
      );
    } catch (_) {
      if (!mounted) return;
      showPollarToast(
        context,
        message: 'Não foi possível exportar o relatório. Verifique o armazenamento e tente novamente.',
        tone: PollarStatusTone.danger,
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({
    required this.compact,
    required this.period,
    required this.reports,
    required this.selectedCurrency,
    required this.exporting,
    required this.onCurrencyChanged,
    required this.onExport,
  });

  final bool compact;
  final String period;
  final List<ReportCurrencySnapshot> reports;
  final Currency selectedCurrency;
  final bool exporting;
  final ValueChanged<Currency> onCurrencyChanged;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Relatórios', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: PollarSpacing.x1),
        Text(
          period,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: context.pollar.textSecondary),
        ),
      ],
    );
    final currency = reports.length > 1
        ? SizedBox(
            key: ValueKey(selectedCurrency.code),
            width: compact ? double.infinity : 150,
            child: PollarSelect<Currency>(
              label: 'Moeda',
              initialValue: selectedCurrency,
              options: [
                for (final report in reports)
                  PollarSelectOption(
                    value: report.currency,
                    label: report.currency.code,
                  ),
              ],
              onChanged: (value) {
                if (value != null) onCurrencyChanged(value);
              },
            ),
          )
        : null;
    final export = PollarButton(
      label: 'Exportar CSV',
      leadingIcon: LucideIcons.download,
      variant: PollarButtonVariant.secondary,
      loading: exporting,
      adaptiveHeight: true,
      fullWidth: compact,
      onPressed: exporting ? null : onExport,
    );
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          copy,
          if (currency != null) ...[
            const SizedBox(height: PollarSpacing.x4),
            currency,
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: copy),
        if (currency != null) ...[
          const SizedBox(width: PollarSpacing.x4),
          currency,
        ],
        const SizedBox(width: PollarSpacing.x3),
        export,
      ],
    );
  }
}

class _ReportBasis extends StatefulWidget {
  const _ReportBasis({required this.period});

  final String period;

  @override
  State<_ReportBasis> createState() => _ReportBasisState();
}

class _ReportBasisState extends State<_ReportBasis> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    key: const ValueKey('report-basis'),
    expansionAnimationStyle: PollarMotion.reduced(context)
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: PollarMotion.change,
            curve: PollarMotion.curve,
          ),
    tilePadding: EdgeInsets.zero,
    childrenPadding: const EdgeInsets.only(bottom: PollarSpacing.x4),
    onExpansionChanged: (value) => setState(() => _expanded = value),
    trailing: AnimatedRotation(
      turns: _expanded ? .5 : 0,
      duration: PollarMotion.reduced(context)
          ? Duration.zero
          : PollarMotion.change,
      curve: PollarMotion.curve,
      child: Icon(
        LucideIcons.chevronDown,
        size: 20,
        color: context.pollar.textSecondary,
      ),
    ),
    title: Text(
      'Base confirmada',
      style: Theme.of(context).textTheme.titleSmall,
    ),
    subtitle: Text(
      'Compensados e conciliados',
      style: Theme.of(context).textTheme.bodySmall,
    ),
    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Base confirmada · ${widget.period}. Inclui apenas lançamentos compensados e conciliados. Transferências e pagamentos de fatura não contam como receita ou despesa.',
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: context.pollar.textPrimary),
      ),
    ],
  );
}

class _ReportSummary extends StatelessWidget {
  const _ReportSummary({required this.report, required this.privacyHidden});

  final ReportCurrencySnapshot report;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) => PollarCard(
    variant: PollarCardVariant.financial,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 720 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3;
        final result = _SummaryResult(
          report: report,
          privacyHidden: privacyHidden,
        );
        final components = _SummaryComponents(
          report: report,
          privacyHidden: privacyHidden,
        );
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              result,
              const SizedBox(height: PollarSpacing.x5),
              Divider(height: 1, color: context.pollar.border),
              const SizedBox(height: PollarSpacing.x5),
              components,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: result),
            const SizedBox(width: PollarSpacing.x5),
            Expanded(flex: 4, child: components),
          ],
        );
      },
    ),
  );
}

class _SummaryResult extends StatelessWidget {
  const _SummaryResult({required this.report, required this.privacyHidden});

  final ReportCurrencySnapshot report;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Resultado do período',
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: context.pollar.textSecondary),
      ),
      const SizedBox(height: PollarSpacing.x2),
      PrivacyAmount(
        report.netResult,
        hidden: privacyHidden,
        style: PollarTypography.amountHero,
        showSign: true,
        colorBySign: true,
        semantic: report.netResult.isNegative
            ? MoneySemantic.expense
            : MoneySemantic.income,
        allowWrap: true,
        reserveLayout: true,
        animateChanges: true,
      ),
      const SizedBox(height: PollarSpacing.x2),
      Text(
        'Entradas menos saídas confirmadas no período.',
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: context.pollar.textSecondary),
      ),
    ],
  );
}

class _SummaryComponents extends StatelessWidget {
  const _SummaryComponents({required this.report, required this.privacyHidden});

  final ReportCurrencySnapshot report;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _MetricPair(
        label: 'Entradas confirmadas',
        amount: report.totalIncome,
        hidden: privacyHidden,
        semantic: MoneySemantic.income,
        colorBySign: true,
      ),
      const SizedBox(height: PollarSpacing.x4),
      _MetricPair(
        label: 'Saídas confirmadas',
        amount: report.totalExpenses,
        hidden: privacyHidden,
        semantic: MoneySemantic.expense,
        colorBySign: false,
      ),
    ],
  );
}

class _MetricPair extends StatelessWidget {
  const _MetricPair({
    required this.label,
    required this.amount,
    required this.hidden,
    required this.semantic,
    required this.colorBySign,
  });

  final String label;
  final Money amount;
  final bool hidden;
  final MoneySemantic semantic;
  final bool colorBySign;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 520 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3;
        final labelWidget = Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.pollar.textSecondary),
        );
        final value = PrivacyAmount(
          amount,
          hidden: hidden,
          style: PollarTypography.amountStandard,
          semantic: semantic,
          colorBySign: colorBySign,
          allowWrap: true,
          reserveLayout: true,
        );
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              labelWidget,
              const SizedBox(height: PollarSpacing.x1),
              value,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: labelWidget),
            const SizedBox(width: PollarSpacing.x3),
            Expanded(child: value),
          ],
        );
      },
    );
  }
}

class _MonthlyFlow extends StatelessWidget {
  const _MonthlyFlow({required this.report, required this.privacyHidden});

  final ReportCurrencySnapshot report;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Fluxo mês a mês', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: PollarSpacing.x1),
        Text(
          'Quanto entrou e saiu em cada mês? Sem movimentações internas.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.pollar.textSecondary),
        ),
        const SizedBox(height: PollarSpacing.x5),
        MonthlyComparisonChart(
          months: report.months,
          privacyHidden: privacyHidden,
        ),
        const SizedBox(height: PollarSpacing.x5),
        _MonthlyValueTable(months: report.months, privacyHidden: privacyHidden),
      ],
    ),
  );
}

class _MonthlyValueTable extends StatelessWidget {
  const _MonthlyValueTable({required this.months, required this.privacyHidden});

  final List<ReportMonth> months;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('MMM yyyy', 'pt_BR');
    return Column(
      children: [
        for (var index = 0; index < months.length; index++) ...[
          if (index > 0) Divider(height: 1, color: context.pollar.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: PollarSpacing.x3),
            child: _MonthValueRow(
              label: format.format(months[index].month),
              month: months[index],
              privacyHidden: privacyHidden,
            ),
          ),
        ],
      ],
    );
  }
}

class _MonthValueRow extends StatelessWidget {
  const _MonthValueRow({
    required this.label,
    required this.month,
    required this.privacyHidden,
  });

  final String label;
  final ReportMonth month;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaled = MediaQuery.textScalerOf(context).scale(1) > 1.3;
        final amounts = <Widget>[
          _CompactAmount(
            label: 'Entradas',
            amount: month.income,
            hidden: privacyHidden,
            semantic: MoneySemantic.income,
          ),
          _CompactAmount(
            label: 'Saídas',
            amount: month.expenses,
            hidden: privacyHidden,
            semantic: MoneySemantic.expense,
          ),
        ];
        final values = scaled
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  amounts[0],
                  const SizedBox(height: PollarSpacing.x2),
                  amounts[1],
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: amounts[0]),
                  const SizedBox(width: PollarSpacing.x3),
                  Expanded(child: amounts[1]),
                ],
              );
        if (scaled || constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: PollarSpacing.x2),
              values,
            ],
          );
        }
        return Row(
          children: [
            SizedBox(
              width: 78 * MediaQuery.textScalerOf(context).scale(1),
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(child: values),
          ],
        );
      },
    );
  }
}

class _CompactAmount extends StatelessWidget {
  const _CompactAmount({
    required this.label,
    required this.amount,
    required this.hidden,
    required this.semantic,
  });

  final String label;
  final Money amount;
  final bool hidden;
  final MoneySemantic semantic;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: context.pollar.textMuted),
      ),
      PrivacyAmount(
        amount,
        hidden: hidden,
        semantic: semantic,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
        allowWrap: true,
        reserveLayout: true,
      ),
    ],
  );
}

class _BalanceHistory extends StatelessWidget {
  const _BalanceHistory({required this.report, required this.privacyHidden});

  final ReportCurrencySnapshot report;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Saldo líquido das contas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: PollarSpacing.x1),
          Text(
            'Como variou a posição das contas ativas? Saldos iniciais e lançamentos confirmados.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.pollar.textSecondary),
          ),
          const SizedBox(height: PollarSpacing.x5),
          BalanceTrendChart(
            months: report.months,
            privacyHidden: privacyHidden,
          ),
          const SizedBox(height: PollarSpacing.x5),
          for (var index = 0; index < report.months.length; index++) ...[
            if (index > 0) Divider(height: PollarSpacing.x4),
            _MetricPair(
              label: DateFormat(
                'MMM yyyy',
                'pt_BR',
              ).format(report.months[index].month),
              amount: report.months[index].accountNetBalance,
              hidden: privacyHidden,
              semantic: MoneySemantic.balance,
              colorBySign: true,
            ),
          ],
          const SizedBox(height: PollarSpacing.x3),
          Text(
            'Este histórico não inclui avaliações manuais de ativos e dívidas. Elas permanecem no dossiê de patrimônio até existir histórico de avaliação.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.pollar.textMuted),
          ),
        ],
      ),
    );
  }
}

class _CategoryComposition extends StatelessWidget {
  const _CategoryComposition({
    required this.report,
    required this.privacyHidden,
  });

  final ReportCurrencySnapshot report;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Composição das saídas',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: PollarSpacing.x1),
        Text(
          'Onde se concentram as saídas? Categorias pelo valor confirmado no período.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.pollar.textSecondary),
        ),
        const SizedBox(height: PollarSpacing.x5),
        if (report.categories.isEmpty)
          _NoCategories(currency: report.currency)
        else
          for (var index = 0; index < report.categories.length; index++) ...[
            if (index > 0) const SizedBox(height: PollarSpacing.x4),
            _CategoryRow(
              category: report.categories[index],
              total: report.totalExpenses,
              privacyHidden: privacyHidden,
            ),
          ],
      ],
    ),
  );
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.total,
    required this.privacyHidden,
  });

  final ReportCategory category;
  final Money total;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    final percent = total.isZero
        ? 0
        : (category.amount.minorUnits * 100 / total.minorUnits).round();
    final amount = PrivacyAmount(
      category.amount,
      hidden: privacyHidden,
      semantic: MoneySemantic.expense,
      style: PollarTypography.amountStandard,
      allowWrap: true,
      reserveLayout: true,
    );
    final percentage = Text(
      privacyHidden ? '••%' : '$percent%',
      textAlign: TextAlign.end,
      style: PollarTypography.tabular(Theme.of(context).textTheme.bodySmall!)
          .copyWith(color: context.pollar.textSecondary),
    );
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(category.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: PollarSpacing.x2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: amount),
            const SizedBox(width: PollarSpacing.x3),
            percentage,
          ],
        ),
      ],
    );
    return Semantics(
      label: privacyHidden
          ? '${category.name}, percentual oculto pelo modo privacidade'
          : '${category.name}, $percent por cento',
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          heading,
          const SizedBox(height: PollarSpacing.x2),
          if (privacyHidden)
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: context.pollar.surfaceAlt,
                borderRadius: BorderRadius.circular(PollarRadii.small),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(PollarRadii.small),
              child: LinearProgressIndicator(
                value: percent.clamp(0, 100) / 100,
                minHeight: 8,
                backgroundColor: context.pollar.surfaceAlt,
                color: context.pollar.primary,
                semanticsLabel:
                    '${category.name}: $percent por cento das saídas',
                semanticsValue: '$percent%',
              ),
            ),
        ],
      ),
    );
  }
}

class _NoCategories extends StatelessWidget {
  const _NoCategories({required this.currency});

  final Currency currency;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(LucideIcons.tags, size: 20, color: context.pollar.textMuted),
      const SizedBox(width: PollarSpacing.x3),
      Expanded(
        child: Text(
          'Nenhuma saída confirmada em ${currency.code} neste período. Novos lançamentos compensados ou conciliados aparecerão aqui.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: context.pollar.textSecondary),
        ),
      ),
    ],
  );
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: const EdgeInsets.all(PollarSpacing.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.chartNoAxesColumn,
              size: 28,
              color: context.pollar.info,
            ),
            const SizedBox(height: PollarSpacing.x4),
            Text(
              'Ainda não há dados para relatar',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: PollarSpacing.x2),
            Text(
              'Cadastre uma conta e registre lançamentos para formar comparações mensais verificáveis.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.pollar.textSecondary),
            ),
          ],
        ),
      ),
    ),
  );
}

String _periodLabel(ReportCurrencySnapshot report) {
  final format = DateFormat('MMM yyyy', 'pt_BR');
  return '${format.format(report.periodStart)}–${format.format(report.periodEnd)}';
}
