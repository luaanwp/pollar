/* Fake data for the Pollar desktop recreation. Amounts are integer minor units. */
window.PollarDesktopData = {
  nav: [
    { id: "dash", label: "Visão geral", icon: "layout-dashboard" },
    { section: "Dinheiro" },
    { id: "tx", label: "Transações", icon: "arrow-left-right" },
    { id: "cards", label: "Cartões", icon: "credit-card", badge: 2 },
    { id: "budgets", label: "Orçamentos", icon: "target" },
    { section: "Planejamento" },
    { id: "reports", label: "Relatórios", icon: "chart-pie" },
    { id: "settings", label: "Preferências", icon: "settings" },
  ],
  trend: [
    { label: "abr", value: 1420000 }, { label: "mai", value: 1512000 },
    { label: "jun", value: 1487000 }, { label: "jul", value: 1610000 },
    { label: "ago", value: 1748000 }, { label: "set", value: 1873455 },
  ],
  flow: [
    { label: "jun", values: [980000, 742000] }, { label: "jul", values: [1010000, 861000] },
    { label: "ago", values: [1035000, 904000] }, { label: "set", values: [1052000, 861000] },
  ],
  categories: [
    { label: "Moradia", value: -320000 }, { label: "Alimentação", value: -138050 },
    { label: "Transporte", value: -42300 }, { label: "Saúde", value: -31600 },
    { label: "Lazer", value: -24990 },
  ],
  budgets: [
    { category: "Alimentação", icon: "shopping-basket", spentMinor: -138050, limitMinor: 160000 },
    { category: "Transporte", icon: "bus", spentMinor: -42300, limitMinor: 40000 },
    { category: "Lazer", icon: "clapperboard", spentMinor: -24990, limitMinor: 50000 },
    { category: "Saúde", icon: "heart-pulse", spentMinor: -31600, limitMinor: 45000 },
  ],
  transactions: [
    { id: "t1", date: "1 set 2026", title: "Salário", category: "Renda", account: "Conta corrente", minor: 920000, kind: "income", status: ["Compensado", "success", "check"], icon: "banknote" },
    { id: "t2", date: "1 set 2026", title: "Mercado do bairro", category: "Alimentação", account: "Cartão Ouro", minor: -23480, kind: "expense", installment: "3/12", status: ["Previsto", "neutral", "clock"], icon: "shopping-basket" },
    { id: "t3", date: "2 set 2026", title: "Aluguel", category: "Moradia", account: "Conta corrente", minor: -320000, kind: "expense", status: ["Compensado", "success", "check"], icon: "house" },
    { id: "t4", date: "2 set 2026", title: "Assinatura streaming", category: "Lazer", account: "Cartão Ouro", minor: -4990, kind: "expense", status: ["Pendente", "neutral", "clock"], icon: "clapperboard" },
    { id: "t5", date: "3 set 2026", title: "Transferência para Reserva", category: "Transferência", account: "Conta corrente → Poupança", minor: -150000, kind: "transfer", status: ["Conciliado", "info", "link"], icon: "arrow-left-right" },
    { id: "t6", date: "4 set 2026", title: "Combustível", category: "Transporte", account: "Cartão Ouro", minor: -28900, kind: "expense", status: ["Previsto", "neutral", "clock"], icon: "fuel" },
    { id: "t7", date: "5 set 2026", title: "Farmácia", category: "Saúde", account: "Débito", minor: -8760, kind: "expense", status: ["Compensado", "success", "check"], icon: "pill" },
    { id: "t8", date: "5 set 2026", title: "Pagamento fatura agosto", category: "Cartão", account: "Cartão Ouro", minor: -150000, kind: "cardPayment", status: ["Compensado", "success", "check"], icon: "credit-card" },
    { id: "t9", date: "6 set 2026", title: "Freelance — projeto Vega", category: "Renda", account: "Conta corrente", minor: 132000, kind: "income", status: ["Previsto", "neutral", "clock"], icon: "briefcase" },
    { id: "t10", date: "7 set 2026", title: "Restaurante Yuki", category: "Alimentação", account: "Cartão Ouro", minor: -14200, kind: "expense", status: ["Conflito", "danger", "triangle-alert"], icon: "utensils" },
  ],
  statementPurchases: [
    { day: "5 set 2026", items: [
      { id: "p1", title: "Mercado do bairro", category: "Alimentação", minor: -23480, installment: "3/12", icon: "shopping-basket" },
      { id: "p2", title: "Combustível", category: "Transporte", minor: -28900, icon: "fuel" } ] },
    { day: "3 set 2026", items: [
      { id: "p3", title: "Restaurante Yuki", category: "Alimentação", minor: -14200, icon: "utensils" },
      { id: "p4", title: "Livraria Central", category: "Educação", minor: -8990, installment: "1/3", icon: "book-open" } ] },
    { day: "1 set 2026", items: [
      { id: "p5", title: "Assinatura streaming", category: "Lazer", minor: -4990, icon: "clapperboard" },
      { id: "p6", title: "Notebook Pro", category: "Equipamentos", minor: -32083, installment: "6/12", icon: "laptop" } ] },
  ],
};
