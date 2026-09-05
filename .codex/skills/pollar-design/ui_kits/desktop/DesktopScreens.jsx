const {
  Sidebar, TopBar, Button, IconButton, Icon, Card, MetricCard, StatementSummary, BudgetProgress,
  MoneyText, PrivacyAmount, StatusBadge, TransactionTile, DataTable, TrendChart, ComparisonBars,
  CategoryDonut, ProgressMeter, Banner, Dialog, Toast, Input, Select, Checkbox, Switch, CurrencyInput,
} = window.PollarDesignSystem_efbbc4;
const D = window.PollarDesktopData;

function SectionTitle({ children, action }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 12 }}>
      <h2 style={{ margin: 0, fontSize: "var(--text-h3)", fontWeight: "var(--fw-h3)", lineHeight: "var(--lh-h3)", color: "var(--text-primary)", flex: 1 }}>{children}</h2>
      {action}
    </div>
  );
}

function PageHead({ title, subtitle, actions }) {
  return (
    <div style={{ display: "flex", alignItems: "flex-end", gap: 16, marginBottom: 20 }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <h1 style={{ margin: 0, fontSize: "var(--text-h1)", fontWeight: "var(--fw-h1)", lineHeight: "var(--lh-h1)", letterSpacing: "-0.015em", color: "var(--text-primary)" }}>{title}</h1>
        {subtitle && <div style={{ marginTop: 4, fontSize: 14, color: "var(--text-secondary)" }}>{subtitle}</div>}
      </div>
      {actions}
    </div>
  );
}

/* ---------- 1. Dashboard ---------- */
function DashboardScreen({ priv, onOpenTx, offline }) {
  return (
    <div style={{ maxWidth: "var(--size-dashboard-max)" }}>
      <PageHead title="Visão geral" subtitle="Setembro de 2026 · Todas as contas"
        actions={<div style={{ display: "flex", gap: 8 }}>
          <Select size="compact" options={["Setembro 2026", "Agosto 2026", "Julho 2026"]} style={{ width: 170 }} />
          <Button size="compact" variant="secondary" iconLeft="download">Exportar</Button>
        </div>} />
      {offline && (
        <div style={{ marginBottom: 20 }}>
          <Banner tone="warning" title="Você está offline" actions={<Button size="compact" variant="secondary">Tentar novamente</Button>}>
            As alterações ficam salvas neste dispositivo e serão sincronizadas quando a conexão voltar.
          </Banner>
        </div>
      )}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(3,minmax(0,1fr))", gap: 16, marginBottom: 16 }}>
        <MetricCard title="Saldo total" helper="4 contas" minor={1873455} comparisonMinor={125455} comparisonLabel="vs. agosto" privacyHidden={priv} />
        <MetricCard title="Resultado do mês" helper="Entradas − saídas" minor={191000} size="hero" comparisonMinor={-40000} comparisonLabel="vs. agosto" privacyHidden={priv} />
        <MetricCard title="Faturas em aberto" helper="2 cartões" minor={-412390} size="hero" privacyHidden={priv} />
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "1.55fr 1fr", gap: 16, marginBottom: 16 }}>
        <Card>
          <SectionTitle action={<Select size="compact" options={["6 meses", "12 meses"]} style={{ width: 120 }} />}>Evolução do saldo</SectionTitle>
          <TrendChart data={D.trend} height={168} />
        </Card>
        <Card>
          <SectionTitle>Entradas e saídas</SectionTitle>
          <ComparisonBars height={150} series={[{ label: "Entradas", color: "var(--chart-1)" }, { label: "Saídas", color: "var(--chart-3)" }]} groups={D.flow} />
        </Card>
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16, marginBottom: 16 }}>
        <Card>
          <SectionTitle action={<Button size="compact" variant="ghost" iconRight="arrow-right">Ver tudo</Button>}>Orçamentos de setembro</SectionTitle>
          <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
            {D.budgets.slice(0, 3).map(b => <BudgetProgress key={b.category} {...b} />)}
          </div>
        </Card>
        <Card>
          <SectionTitle>Composição das saídas</SectionTitle>
          <CategoryDonut size={124} thickness={16} centerLabel="Saídas" centerValue="R$ 8.610,00" slices={D.categories} />
        </Card>
      </div>
      <Card padding="none">
        <div style={{ padding: "16px 20px 12px" }}>
          <SectionTitle action={<Button size="compact" variant="ghost" iconRight="arrow-right" onClick={onOpenTx}>Todas as transações</Button>}>Transações recentes</SectionTitle>
        </div>
        <div style={{ borderTop: "1px solid var(--border)" }}>
          {D.transactions.slice(0, 4).map(t => (
            <TransactionTile key={t.id} title={t.title} category={t.category} account={t.account} date={t.date}
              minor={t.minor} kind={t.kind} installment={t.installment} icon={t.icon}
              status={t.status[0]} statusTone={t.status[1]} statusIcon={t.status[2]}
              privacyHidden={priv} onClick={onOpenTx} />
          ))}
        </div>
      </Card>
    </div>
  );
}

/* ---------- 2. Transactions + detail panel ---------- */
function TransactionsScreen({ priv }) {
  const [selected, setSelected] = React.useState([]);
  const [active, setActive] = React.useState(D.transactions[1]);
  const [sortKey, setSortKey] = React.useState("date");
  const [sortDir, setSortDir] = React.useState("asc");
  const rows = D.transactions;
  const columns = [
    { key: "date", label: "Data", width: "104px" },
    { key: "title", label: "Descrição", render: r => (
        <span style={{ display: "flex", alignItems: "center", gap: 8, minWidth: 0 }}>
          <Icon name={r.icon} size={16} color="var(--text-muted)" />
          <span style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{r.title}</span>
          {r.installment && <span className="fin-tnum" style={{ fontSize: 11, fontWeight: 600, color: "var(--text-muted)", background: "var(--surface-alt)", borderRadius: "var(--radius-sm)", padding: "1px 6px" }}>{r.installment}</span>}
        </span>) },
    { key: "category", label: "Categoria", width: "130px" },
    { key: "account", label: "Conta", width: "150px" },
    { key: "status", label: "Status", width: "144px", sortable: false, render: r => <StatusBadge tone={r.status[1]} icon={r.status[2]} size="compact">{r.status[0]}</StatusBadge> },
    { key: "minor", label: "Valor", width: "128px", align: "right", render: r => priv
        ? <PrivacyAmount minor={r.minor} hidden size="compact" maskDigits={5} />
        : <MoneyText minor={r.minor} size="compact" tone={r.kind === "income" ? "semantic" : undefined} showSign={r.kind === "income"} /> },
  ];
  return (
    <div style={{ display: "flex", gap: 16, alignItems: "flex-start" }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <PageHead title="Transações" subtitle="1–30 de setembro de 2026 · 128 registros"
          actions={<div style={{ display: "flex", gap: 8 }}>
            <Button size="compact" variant="secondary" iconLeft="sliders-horizontal">Filtros</Button>
            <Button size="compact" iconLeft="plus">Nova transação</Button>
          </div>} />
        <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 12, flexWrap: "wrap" }}>
          <Input size="compact" iconLeft="search" placeholder="Buscar descrição ou valor" style={{ width: 260 }} />
          <Select size="compact" options={["Todas as contas", "Conta corrente", "Cartão Ouro"]} style={{ width: 170 }} />
          <Select size="compact" options={["Todos os status", "Previsto", "Compensado", "Conciliado"]} style={{ width: 170 }} />
          <span style={{ flex: 1 }} />
          {selected.length > 0 && (
            <span style={{ display: "flex", alignItems: "center", gap: 8 }}>
              <span className="fin-tnum" style={{ fontSize: 13, color: "var(--text-secondary)" }}>{selected.length} selecionadas</span>
              <Button size="compact" variant="secondary" iconLeft="tags">Categorizar</Button>
              <Button size="compact" variant="danger" iconLeft="trash-2">Excluir</Button>
            </span>
          )}
          <IconButton icon="sliders-horizontal" label="Colunas" size="compact" variant="outline" />
        </div>
        <DataTable
          columns={columns} rows={rows} selectable selectedIds={selected}
          onToggleRow={id => setSelected(s => s.includes(id) ? s.filter(x => x !== id) : [...s, id])}
          onToggleAll={() => setSelected(s => s.length === rows.length ? [] : rows.map(r => r.id))}
          sortKey={sortKey} sortDir={sortDir}
          onSort={k => { setSortDir(d => (k === sortKey && d === "asc") ? "desc" : "asc"); setSortKey(k); }}
          onRowClick={setActive} activeId={active && active.id}
        />
      </div>
      {active && <DetailPanel tx={active} onClose={() => setActive(null)} priv={priv} />}
    </div>
  );
}

function DetailPanel({ tx, onClose, priv }) {
  return (
    <aside style={{ width: "var(--size-context-panel)", flex: "none", background: "var(--surface-canvas)", border: "1px solid var(--border)", borderRadius: "var(--radius-lg)", overflow: "hidden", position: "sticky", top: 0 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "14px 16px", borderBottom: "1px solid var(--border)" }}>
        <span style={{ flex: 1, fontSize: "var(--text-h3)", fontWeight: "var(--fw-h3)", color: "var(--text-primary)" }}>Detalhes</span>
        <IconButton icon="pencil" label="Editar" size="compact" />
        <IconButton icon="x" label="Fechar painel" size="compact" onClick={onClose} />
      </div>
      <div style={{ padding: 16, display: "flex", flexDirection: "column", gap: 16 }}>
        <div style={{ display: "flex", flexDirection: "column", gap: 4 }}>
          <PrivacyAmount minor={tx.minor} hidden={priv} size="hero" />
          <span style={{ fontSize: 14, color: "var(--text-secondary)" }}>{tx.title}</span>
        </div>
        <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
          <StatusBadge tone={tx.status[1]} icon={tx.status[2]}>{tx.status[0]}</StatusBadge>
          {tx.installment && <StatusBadge icon="layers">Parcela {tx.installment.replace("/", " de ")}</StatusBadge>}
        </div>
        <dl style={{ margin: 0, display: "grid", gridTemplateColumns: "108px 1fr", rowGap: 10, columnGap: 12, fontSize: 13 }}>
          {[["Data", tx.date], ["Categoria", tx.category], ["Conta", tx.account], ["Tipo", { income: "Entrada", expense: "Saída", transfer: "Transferência", cardPayment: "Pagamento de fatura" }[tx.kind]], ["Identificador", tx.id.toUpperCase() + "-2026-09"]].map(([k, v]) => (
            <React.Fragment key={k}>
              <dt style={{ color: "var(--text-muted)" }}>{k}</dt>
              <dd style={{ margin: 0, color: "var(--text-primary)" }}>{v}</dd>
            </React.Fragment>
          ))}
        </dl>
        {tx.status[0] === "Conflito" && (
          <Banner tone="danger" title="Conflito de sincronização" actions={<Button size="compact" variant="secondary">Revisar versões</Button>}>
            Esta transação foi editada em dois dispositivos. Escolha qual versão manter.
          </Banner>
        )}
        <div style={{ display: "flex", gap: 8 }}>
          <Button variant="secondary" size="compact" iconLeft="copy">Duplicar</Button>
          <Button variant="danger" size="compact" iconLeft="trash-2">Excluir</Button>
        </div>
      </div>
    </aside>
  );
}

/* ---------- 3. Card statement ---------- */
function StatementScreen({ priv, onPay }) {
  return (
    <div style={{ maxWidth: 1080 }}>
      <PageHead title="Cartão Ouro" subtitle="Visa · •••• 4417 · Fatura de setembro"
        actions={<div style={{ display: "flex", gap: 8 }}>
          <Button size="compact" variant="secondary" iconLeft="file-text">Extrato PDF</Button>
          <Button size="compact" iconLeft="check" onClick={onPay}>Pagar fatura</Button>
        </div>} />
      <div style={{ display: "grid", gridTemplateColumns: "1.6fr 1fr", gap: 16, marginBottom: 16 }}>
        <StatementSummary cardName="Cartão Ouro" brand="Visa" last4="4417" period="1–30 set 2026"
          status="Parcialmente paga" statusTone="warning" statusIcon="clock"
          totalMinor={-412390} paidMinor={-150000} dueDate="10 out 2026" limitMinor={800000}
          actions={<div style={{ display: "flex", gap: 8 }}>
            <Button size="compact" variant="secondary">Pagamento parcial</Button>
            <Button size="compact" onClick={onPay}>Pagar fatura</Button>
          </div>} />
        <Card style={{ display: "flex", flexDirection: "column", gap: 16 }}>
          <SectionTitle>Parcelas futuras</SectionTitle>
          {[["Notebook Pro", "6/12", -32083], ["Mercado do bairro", "3/12", -23480], ["Livraria Central", "1/3", -8990]].map(([t, i, v]) => (
            <div key={t} style={{ display: "flex", alignItems: "center", gap: 10 }}>
              <span style={{ flex: 1, fontSize: 14, color: "var(--text-primary)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{t}</span>
              <span className="fin-tnum" style={{ fontSize: 12, fontWeight: 600, color: "var(--text-muted)", background: "var(--surface-alt)", borderRadius: "var(--radius-sm)", padding: "1px 6px" }}>{i}</span>
              <MoneyText minor={v} size="compact" />
            </div>
          ))}
          <div style={{ borderTop: "1px solid var(--border)", paddingTop: 12, display: "flex", alignItems: "center" }}>
            <span style={{ flex: 1, fontSize: 13, color: "var(--text-secondary)" }}>Comprometido nos próximos meses</span>
            <MoneyText minor={-64553} size="standard" />
          </div>
        </Card>
      </div>
      <Card padding="none">
        <div style={{ padding: "16px 20px 12px", display: "flex", alignItems: "center", gap: 12 }}>
          <h2 style={{ margin: 0, fontSize: "var(--text-h3)", fontWeight: "var(--fw-h3)", color: "var(--text-primary)", flex: 1 }}>Compras da fatura</h2>
          <Select size="compact" options={["Agrupado por data", "Agrupado por categoria"]} style={{ width: 200 }} />
        </div>
        {D.statementPurchases.map(g => (
          <div key={g.day}>
            <div className="fin-tnum" style={{ display: "flex", alignItems: "center", gap: 8, padding: "8px 20px", background: "var(--surface-alt)", borderTop: "1px solid var(--border)", borderBottom: "1px solid var(--border)", fontSize: 12, fontWeight: 600, color: "var(--text-secondary)" }}>
              {g.day}
              <span style={{ flex: 1 }} />
              <MoneyText minor={g.items.reduce((a, i) => a + i.minor, 0)} size="compact" style={{ fontSize: 12 }} />
            </div>
            {g.items.map(i => (
              <TransactionTile key={i.id} title={i.title} category={i.category} account="Cartão Ouro"
                minor={i.minor} installment={i.installment} icon={i.icon} privacyHidden={priv} onClick={() => {}} />
            ))}
          </div>
        ))}
      </Card>
    </div>
  );
}

/* ---------- 4. Budgets ---------- */
function BudgetsScreen({ priv }) {
  return (
    <div style={{ maxWidth: "var(--size-dashboard-max)" }}>
      <PageHead title="Orçamentos" subtitle="Setembro de 2026 · 4 categorias acompanhadas"
        actions={<Button size="compact" iconLeft="plus">Novo orçamento</Button>} />
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16, marginBottom: 16 }}>
        <MetricCard title="Total orçado" minor={295000} size="standard" privacyHidden={priv} />
        <MetricCard title="Gasto até agora" minor={-236940} size="standard" comparisonMinor={-58060} comparisonLabel="restante" privacyHidden={priv} />
      </div>
      <Card>
        <SectionTitle action={<Switch label="Alertar em 85%" checked />}>Acompanhamento por categoria</SectionTitle>
        <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
          {D.budgets.map(b => <BudgetProgress key={b.category} {...b} />)}
        </div>
      </Card>
    </div>
  );
}

/* ---------- 5. Settings ---------- */
function SettingsScreen({ priv, setPriv, theme, setTheme }) {
  return (
    <div style={{ maxWidth: 760 }}>
      <PageHead title="Preferências" subtitle="Aplicadas a este dispositivo" />
      <Card style={{ display: "flex", flexDirection: "column", gap: 18, marginBottom: 16 }}>
        <SectionTitle>Privacidade e exibição</SectionTitle>
        <Switch label="Modo privacidade" description="Oculta todos os valores monetários (atalho: ⌘P)" checked={priv} onChange={() => setPriv(!priv)} />
        <Switch label="Tema escuro" description="Usa a paleta escura em todas as telas" checked={theme === "dark"} onChange={() => setTheme(theme === "dark" ? "light" : "dark")} />
        <Switch label="Reduzir animações" description="Respeita a preferência do sistema quando ativa" />
      </Card>
      <Card style={{ display: "flex", flexDirection: "column", gap: 16 }}>
        <SectionTitle>Moeda e formato</SectionTitle>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16 }}>
          <Select label="Moeda" options={["Real brasileiro (R$)", "Dólar americano (US$)", "Euro (€)"]} />
          <Select label="Formato de data" options={["1 set 2026", "01/09/2026", "2026-09-01"]} />
        </div>
        <CurrencyInput label="Meta de reserva de emergência" valueMinor={2400000} installments={12} />
        <div><Checkbox label="Arredondar valores em gráficos (os totais permanecem exatos)" /></div>
      </Card>
    </div>
  );
}

Object.assign(window, { DashboardScreen, TransactionsScreen, StatementScreen, BudgetsScreen, SettingsScreen, FinPageHead: PageHead, FinSectionTitle: SectionTitle });
