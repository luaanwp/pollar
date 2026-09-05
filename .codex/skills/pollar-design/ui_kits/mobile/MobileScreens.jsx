const {
  Button, IconButton, Icon, Card, MetricCard, StatementSummary, BudgetProgress,
  MoneyText, PrivacyAmount, StatusBadge, TransactionTile, TrendChart, CategoryDonut,
  ProgressMeter, Banner, BottomSheet, Input, Select, CurrencyInput, Switch, Checkbox,
} = window.PollarDesignSystem_efbbc4;
const D = window.PollarDesktopData;

function AppBar({ title, subtitle, left, actions }) {
  return (
    <header style={{ display: "flex", alignItems: "center", gap: 8, minHeight: 56, padding: "8px var(--gutter-mobile)", background: "var(--surface-canvas)", borderBottom: "1px solid var(--border)", flex: "none" }}>
      {left}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 17, fontWeight: 650, letterSpacing: "-0.01em", color: "var(--text-primary)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{title}</div>
        {subtitle && <div style={{ fontSize: "var(--text-caption)", color: "var(--text-muted)" }}>{subtitle}</div>}
      </div>
      {actions}
    </header>
  );
}

function GroupTitle({ children, action }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "0 0 8px" }}>
      <span style={{ flex: 1, fontSize: "var(--text-label)", fontWeight: "var(--fw-label)", color: "var(--text-secondary)" }}>{children}</span>
      {action}
    </div>
  );
}

/* ---------- 1. Home ---------- */
function MobileHome({ priv, offline, onOpen }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 16, padding: "16px var(--gutter-mobile) 24px" }}>
      {offline && <Banner tone="warning" title="Offline" actions={<Button size="compact" variant="secondary">Tentar novamente</Button>}>Suas alterações serão sincronizadas quando a conexão voltar.</Banner>}
      <MetricCard title="Saldo total" helper="4 contas" minor={1873455} comparisonMinor={125455} comparisonLabel="vs. agosto" privacyHidden={priv} />
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
        <MetricCard title="Entradas" minor={1052000} size="standard" privacyHidden={priv} />
        <MetricCard title="Saídas" minor={-861000} size="standard" privacyHidden={priv} />
      </div>
      <Card>
        <GroupTitle>Evolução do saldo</GroupTitle>
        <TrendChart data={D.trend} height={116} />
      </Card>
      <Card>
        <GroupTitle action={<Button size="compact" variant="ghost" iconRight="arrow-right" onClick={() => onOpen("cards")}>Ver</Button>}>Fatura aberta</GroupTitle>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <span style={{ display: "inline-flex", alignItems: "center", justifyContent: "center", width: 40, height: 40, flex: "none", borderRadius: "var(--radius-md)", background: "var(--primary-soft)", color: "var(--primary)" }}><Icon name="credit-card" size={20} /></span>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 14, fontWeight: 600, color: "var(--text-primary)" }}>Cartão Ouro</div>
            <div style={{ fontSize: "var(--text-caption)", color: "var(--text-muted)" }}>Vence 10 out 2026</div>
          </div>
          <div style={{ display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 4 }}>
            <PrivacyAmount minor={-262390} hidden={priv} />
            <StatusBadge tone="warning" icon="clock" size="compact">Parcialmente paga</StatusBadge>
          </div>
        </div>
        <div style={{ marginTop: 14 }}><ProgressMeter label="Limite utilizado" value={52} valueLabel="52%" /></div>
      </Card>
      <Card>
        <GroupTitle action={<Button size="compact" variant="ghost" iconRight="arrow-right" onClick={() => onOpen("budgets")}>Ver</Button>}>Orçamentos</GroupTitle>
        <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
          {D.budgets.slice(0, 2).map(b => <BudgetProgress key={b.category} {...b} />)}
        </div>
      </Card>
      <Card padding="none">
        <div style={{ padding: "16px 16px 8px" }}>
          <GroupTitle action={<Button size="compact" variant="ghost" iconRight="arrow-right" onClick={() => onOpen("tx")}>Tudo</Button>}>Transações recentes</GroupTitle>
        </div>
        <div style={{ borderTop: "1px solid var(--border)" }}>
          {D.transactions.slice(0, 4).map(t => (
            <TransactionTile key={t.id} title={t.title} category={t.category} account={t.account} date={t.date}
              minor={t.minor} kind={t.kind} installment={t.installment} icon={t.icon}
              status={t.status[0]} statusTone={t.status[1]} statusIcon={t.status[2]}
              privacyHidden={priv} onClick={() => onOpen("tx")} />
          ))}
        </div>
      </Card>
    </div>
  );
}

/* ---------- 2. Transactions list ---------- */
function MobileTransactions({ priv, onSelect }) {
  const [filter, setFilter] = React.useState("Todas");
  const chips = ["Todas", "Saídas", "Entradas", "Previstas"];
  const rows = D.transactions.filter(t =>
    filter === "Todas" ? true :
    filter === "Saídas" ? t.minor < 0 :
    filter === "Entradas" ? t.minor > 0 : t.status[0] === "Previsto");
  const byDay = rows.reduce((acc, t) => { (acc[t.date] = acc[t.date] || []).push(t); return acc; }, {});
  return (
    <div>
      <div style={{ display: "flex", gap: 8, padding: "12px var(--gutter-mobile)", overflowX: "auto", background: "var(--surface-canvas)", borderBottom: "1px solid var(--border)" }}>
        {chips.map(c => (
          <button key={c} type="button" onClick={() => setFilter(c)}
            style={{ flex: "none", height: 32, padding: "0 12px", borderRadius: "var(--radius-pill)", cursor: "pointer",
              border: "1px solid " + (filter === c ? "var(--primary)" : "var(--border)"),
              background: filter === c ? "var(--primary-soft)" : "var(--surface-canvas)",
              color: filter === c ? "var(--primary)" : "var(--text-secondary)",
              font: "inherit", fontSize: 13, fontWeight: 600 }}>{c}</button>
        ))}
      </div>
      {Object.entries(byDay).map(([day, items]) => (
        <div key={day}>
          <div className="fin-tnum" style={{ display: "flex", alignItems: "center", gap: 8, padding: "8px var(--gutter-mobile)", background: "var(--surface-background)", fontSize: 12, fontWeight: 600, color: "var(--text-secondary)" }}>
            {day}<span style={{ flex: 1 }} />
            <MoneyText minor={items.reduce((a, i) => a + i.minor, 0)} size="compact" style={{ fontSize: 12 }} />
          </div>
          {items.map(t => (
            <TransactionTile key={t.id} title={t.title} category={t.category} account={t.account}
              minor={t.minor} kind={t.kind} installment={t.installment} icon={t.icon}
              status={t.status[0]} statusTone={t.status[1]} statusIcon={t.status[2]}
              privacyHidden={priv} onClick={() => onSelect(t)} />
          ))}
        </div>
      ))}
      <div style={{ padding: "20px var(--gutter-mobile) 32px", textAlign: "center", fontSize: 13, color: "var(--text-muted)" }}>128 transações em setembro</div>
    </div>
  );
}

/* ---------- 3. Statement ---------- */
function MobileStatement({ priv, onPay }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 16, padding: "16px var(--gutter-mobile) 24px" }}>
      <StatementSummary cardName="Cartão Ouro" brand="Visa" last4="4417" period="1–30 set 2026"
        status="Parcialmente paga" statusTone="warning" statusIcon="clock"
        totalMinor={-412390} paidMinor={-150000} dueDate="10 out 2026" limitMinor={800000}
        actions={<Button size="compact" onClick={onPay}>Pagar fatura</Button>} />
      <Card padding="none">
        <div style={{ padding: "16px 16px 8px" }}><GroupTitle>Compras da fatura</GroupTitle></div>
        {D.statementPurchases.map(g => (
          <div key={g.day}>
            <div className="fin-tnum" style={{ display: "flex", padding: "8px 16px", background: "var(--surface-alt)", borderTop: "1px solid var(--border)", borderBottom: "1px solid var(--border)", fontSize: 12, fontWeight: 600, color: "var(--text-secondary)" }}>
              {g.day}<span style={{ flex: 1 }} />
              <MoneyText minor={g.items.reduce((a, i) => a + i.minor, 0)} size="compact" style={{ fontSize: 12 }} />
            </div>
            {g.items.map(i => (
              <TransactionTile key={i.id} title={i.title} category={i.category} account="Cartão Ouro"
                minor={i.minor} installment={i.installment} icon={i.icon} privacyHidden={priv} onClick={() => {}} />
            ))}
          </div>
        ))}
      </Card>
      <Card>
        <GroupTitle>Parcelas futuras</GroupTitle>
        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          {[["Notebook Pro", "6/12", -32083], ["Mercado do bairro", "3/12", -23480], ["Livraria Central", "1/3", -8990]].map(([t, i, v]) => (
            <div key={t} style={{ display: "flex", alignItems: "center", gap: 10 }}>
              <span style={{ flex: 1, fontSize: 14, color: "var(--text-primary)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{t}</span>
              <span className="fin-tnum" style={{ fontSize: 12, fontWeight: 600, color: "var(--text-muted)", background: "var(--surface-alt)", borderRadius: "var(--radius-sm)", padding: "1px 6px" }}>{i}</span>
              <MoneyText minor={v} size="compact" />
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}

/* ---------- 4. Budgets ---------- */
function MobileBudgets({ priv }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 16, padding: "16px var(--gutter-mobile) 24px" }}>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
        <MetricCard title="Orçado" minor={295000} size="standard" privacyHidden={priv} />
        <MetricCard title="Gasto" minor={-236940} size="standard" privacyHidden={priv} />
      </div>
      <Card>
        <GroupTitle>Por categoria</GroupTitle>
        <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
          {D.budgets.map(b => <BudgetProgress key={b.category} {...b} />)}
        </div>
      </Card>
      <Card>
        <GroupTitle>Composição das saídas</GroupTitle>
        <CategoryDonut size={104} thickness={14} centerLabel="Saídas" centerValue="R$ 8.610,00" slices={D.categories} />
      </Card>
    </div>
  );
}

/* ---------- 5. Transaction detail (full page) ---------- */
function MobileDetail({ tx, priv }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 16, padding: "16px var(--gutter-mobile) 24px" }}>
      <Card style={{ display: "flex", flexDirection: "column", gap: 10, alignItems: "flex-start" }}>
        <PrivacyAmount minor={tx.minor} hidden={priv} size="hero" />
        <span style={{ fontSize: 15, color: "var(--text-secondary)" }}>{tx.title}</span>
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
          <StatusBadge tone={tx.status[1]} icon={tx.status[2]}>{tx.status[0]}</StatusBadge>
          {tx.installment && <StatusBadge icon="layers">Parcela {tx.installment.replace("/", " de ")}</StatusBadge>}
        </div>
      </Card>
      <Card>
        <dl style={{ margin: 0, display: "grid", gridTemplateColumns: "112px 1fr", rowGap: 12, columnGap: 12, fontSize: 14 }}>
          {[["Data", tx.date], ["Categoria", tx.category], ["Conta", tx.account],
            ["Tipo", { income: "Entrada", expense: "Saída", transfer: "Transferência", cardPayment: "Pagamento de fatura" }[tx.kind]],
            ["Identificador", tx.id.toUpperCase() + "-2026-09"]].map(([k, v]) => (
            <React.Fragment key={k}>
              <dt style={{ color: "var(--text-muted)" }}>{k}</dt>
              <dd style={{ margin: 0, color: "var(--text-primary)" }}>{v}</dd>
            </React.Fragment>
          ))}
        </dl>
      </Card>
      {tx.status[0] === "Conflito" && (
        <Banner tone="danger" title="Conflito de sincronização" actions={<Button size="compact" variant="secondary">Revisar versões</Button>}>
          Esta transação foi editada em dois dispositivos. Escolha qual versão manter.
        </Banner>
      )}
      <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
        <Button size="prominent" fullWidth iconLeft="pencil">Editar transação</Button>
        <Button size="prominent" fullWidth variant="secondary" iconLeft="copy">Duplicar</Button>
        <Button size="prominent" fullWidth variant="danger" iconLeft="trash-2">Excluir transação</Button>
      </div>
    </div>
  );
}

/* ---------- 6. More / settings ---------- */
function MobileMore({ priv, setPriv, theme, setTheme }) {
  const rows = [["Contas e cartões", "wallet"], ["Categorias", "tags"], ["Metas", "target"], ["Exportar dados", "download"], ["Ajuda", "circle-help"]];
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 16, padding: "16px var(--gutter-mobile) 24px" }}>
      <Card style={{ display: "flex", flexDirection: "column", gap: 18 }}>
        <GroupTitle>Preferências</GroupTitle>
        <Switch label="Modo privacidade" description="Oculta valores em todas as telas" checked={priv} onChange={() => setPriv(!priv)} />
        <Switch label="Tema escuro" checked={theme === "dark"} onChange={() => setTheme(theme === "dark" ? "light" : "dark")} />
        <Switch label="Reduzir animações" />
      </Card>
      <Card padding="none">
        {rows.map(([label, icon], i) => (
          <button key={label} type="button" style={{ display: "flex", alignItems: "center", gap: 12, width: "100%", minHeight: 52, padding: "0 16px", background: "none", border: "none", borderTop: i ? "1px solid var(--border)" : "none", font: "inherit", fontSize: 15, color: "var(--text-primary)", cursor: "pointer", textAlign: "left" }}>
            <Icon name={icon} size={20} color="var(--text-secondary)" />
            <span style={{ flex: 1 }}>{label}</span>
            <Icon name="chevron-right" size={18} color="var(--text-muted)" />
          </button>
        ))}
      </Card>
      <div style={{ textAlign: "center", fontSize: 12, color: "var(--text-muted)" }}>Pollar · versão de demonstração</div>
    </div>
  );
}

Object.assign(window, { FinAppBar: AppBar, MobileHome, MobileTransactions, MobileStatement, MobileBudgets, MobileDetail, MobileMore });
