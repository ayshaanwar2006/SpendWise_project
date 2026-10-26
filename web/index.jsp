
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    javax.servlet.http.HttpSession userSession = request.getSession(false);

    if (userSession == null || userSession.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
    } else {
        int userId = ((Integer) userSession.getAttribute("userId")).intValue();
        String username = (String) userSession.getAttribute("username");

        double totalIncome = 0;
        double totalExpense = 0;
        double monthlyExpense = 0;
        double budgetAmount = 0;

        List<Map<String, Object>> transactions =
            new ArrayList<Map<String, Object>>();

        String dbError = null;
        String url = "jdbc:mysql://localhost:3306/spendwise";
        String dbUser = "root";
        String dbPassword = "windows";

        java.time.LocalDate today = java.time.LocalDate.now();
        java.time.LocalDate monthStart = today.withDayOfMonth(1);
        java.time.LocalDate nextMonth = monthStart.plusMonths(1);
        String budgetMonth = monthStart.toString();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn =
                     DriverManager.getConnection(url, dbUser, dbPassword)) {

                String totalsSql =
                    "SELECT " +
                    "COALESCE(SUM(CASE WHEN type='income' THEN amount ELSE 0 END),0) AS income, " +
                    "COALESCE(SUM(CASE WHEN type='expense' THEN amount ELSE 0 END),0) AS expense " +
                    "FROM transactions WHERE user_id = ?";

                try (PreparedStatement ps = conn.prepareStatement(totalsSql)) {
                    ps.setInt(1, userId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            totalIncome = rs.getDouble("income");
                            totalExpense = rs.getDouble("expense");
                        }
                    }
                }

                String monthlySql =
                    "SELECT COALESCE(SUM(amount),0) AS spent " +
                    "FROM transactions WHERE user_id = ? AND type='expense' " +
                    "AND transaction_date >= ? AND transaction_date < ?";

                try (PreparedStatement ps = conn.prepareStatement(monthlySql)) {
                    ps.setInt(1, userId);
                    ps.setDate(2, java.sql.Date.valueOf(monthStart));
                    ps.setDate(3, java.sql.Date.valueOf(nextMonth));

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            monthlyExpense = rs.getDouble("spent");
                        }
                    }
                }

                String budgetSql =
                    "SELECT budget_amount FROM monthly_budgets " +
                    "WHERE user_id = ? AND budget_month = ?";

                try (PreparedStatement ps = conn.prepareStatement(budgetSql)) {
                    ps.setInt(1, userId);
                    ps.setDate(2, java.sql.Date.valueOf(monthStart));

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            budgetAmount = rs.getDouble("budget_amount");
                        }
                    }
                }

                String listSql =
                    "SELECT id, type, amount, category, transaction_date, description " +
                    "FROM transactions WHERE user_id = ? " +
                    "ORDER BY transaction_date DESC, id DESC";

                try (PreparedStatement ps = conn.prepareStatement(listSql)) {
                    ps.setInt(1, userId);

                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> item = new HashMap<String, Object>();
                            item.put("id", Integer.valueOf(rs.getInt("id")));
                            item.put("type", rs.getString("type"));
                            item.put("amount", rs.getBigDecimal("amount"));
                            item.put("category", rs.getString("category"));
                            item.put("date", rs.getDate("transaction_date"));
                            item.put("description", rs.getString("description"));
                            transactions.add(item);
                        }
                    }
                }
            }
        } catch (Exception ex) {
            application.log("SpendWise dashboard error", ex);
            dbError = "Could not load dashboard data. Check the database connection.";
        }

        double remainingBudget = budgetAmount - monthlyExpense;
        int budgetPercent = budgetAmount > 0
            ? (int)Math.min(100, Math.round(monthlyExpense * 100.0 / budgetAmount))
            : 0;

        java.text.NumberFormat currency =
            java.text.NumberFormat.getCurrencyInstance(new java.util.Locale("en", "IN"));

        java.text.SimpleDateFormat dateFormat =
            new java.text.SimpleDateFormat("dd MMM yyyy");

        String success = request.getParameter("success");
        String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SpendWise | Dashboard</title>
    <link rel="stylesheet" href="style.css">

    <style>
        * { box-sizing: border-box; }
        body { margin:0; font-family:Arial,sans-serif; background:#0b1110; color:#eef8f3; }
        .layout { max-width:1250px; margin:auto; padding:28px; }
        .topbar { display:flex; justify-content:space-between; align-items:center; gap:15px; flex-wrap:wrap; margin-bottom:32px; }
        .brand { font-size:27px; font-weight:bold; color:#67e8b5; }
        .brand span { color:#f3f7f5; }
        .welcome { color:#aabbb3; margin-top:7px; }
        .logout { color:#0b1110; background:#67e8b5; padding:11px 18px; text-decoration:none; border-radius:9px; font-weight:bold; }
        .section-title { font-size:23px; margin:0 0 18px; }
        .cards { display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:18px; margin-bottom:25px; }
        .card,.panel { background:#141e1a; border:1px solid #263a31; border-radius:16px; padding:23px; }
        .card-label { color:#aabbb3; font-size:14px; }
        .card-amount { font-size:27px; font-weight:bold; margin-top:13px; overflow-wrap:anywhere; }
        .green { color:#67e8b5; }
        .red { color:#ff8989; }
        .content { display:grid; grid-template-columns:minmax(260px,.8fr) minmax(0,1.5fr); gap:22px; align-items:start; }
        label { display:block; color:#c2d2ca; font-size:14px; margin:15px 0 7px; }
        input,select,textarea { width:100%; background:#0b1310; color:#eef8f3; border:1px solid #35483e; border-radius:8px; padding:12px; font:inherit; }
        textarea { resize:vertical; min-height:75px; }
        .submit,.action { margin-top:18px; border:0; border-radius:9px; padding:12px 15px; background:#67e8b5; color:#0b1110; font-weight:bold; cursor:pointer; }
        .action { margin-top:0; }
        .delete { background:#ff8989; }
        .message,.error { padding:12px; border-radius:8px; margin-bottom:15px; }
        .message { background:#18382b; color:#8af3c8; }
        .error { background:#402222; color:#ffaaaa; }
        .table-wrap { overflow-x:auto; }
        table { border-collapse:collapse; width:100%; min-width:530px; }
        th,td { text-align:left; padding:14px 10px; border-bottom:1px solid #293a32; font-size:14px; }
        th { color:#9eb3a8; font-weight:normal; }
        tbody tr { cursor:pointer; transition:background .15s; }
        tbody tr:hover { background:#1b2b23; }
        tbody tr.selected { background:#234638; outline:1px solid #67e8b5; }
        .empty { color:#aabbb3; text-align:center; padding:28px 10px; }
        .actions { display:flex; gap:10px; align-items:center; flex-wrap:wrap; margin:0 0 15px; }
        .hint { color:#9eb3a8; font-size:13px; }
        .budget-panel { margin-bottom:25px; }
        .budget-top { display:flex; justify-content:space-between; align-items:center; gap:12px; flex-wrap:wrap; }
        .budget-grid { display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:16px; margin:20px 0; }
        .budget-stat { background:#0d1712; border:1px solid #263a31; border-radius:12px; padding:16px; }
        .budget-stat .card-amount { font-size:22px; }
        .progress-track { width:100%; height:12px; background:#293a32; border-radius:20px; overflow:hidden; margin:15px 0 8px; }
        .progress-fill { height:100%; background:#67e8b5; border-radius:20px; transition:width .3s; }
        .progress-fill.over { background:#ff8989; }
        .budget-form { display:flex; align-items:end; gap:12px; flex-wrap:wrap; margin-top:20px; }
        .budget-form .field { flex:1; min-width:180px; }
        .budget-form label { margin-top:0; }
        .budget-form .submit { margin-top:0; }
        .footer { color:#71877b; font-size:12px; text-align:center; margin-top:30px; }
        @media(max-width:800px) {
            .cards,.content,.budget-grid { grid-template-columns:1fr; }
            .layout { padding:18px; }
            .card-amount { font-size:24px; }
        }
    </style>
</head>
<body>
<div class="layout">
    <header class="topbar">
        <div>
            <div class="brand">Spend<span>Wise</span></div>
            <div class="welcome">Welcome back, <strong><%= username == null ? "User" :
                username.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;") %></strong> 👋</div>
        </div>
        <a class="logout" href="logout.jsp">Log out ↗</a>
    </header>

    <h2 class="section-title">Your Overview</h2>
    <section class="cards">
        <div class="card">
            <div class="card-label">Total Balance</div>
            <div class="card-amount green"><%= currency.format(totalIncome-totalExpense) %></div>
        </div>
        <div class="card">
            <div class="card-label">Total Income</div>
            <div class="card-amount green"><%= currency.format(totalIncome) %></div>
        </div>
        <div class="card">
            <div class="card-label">Total Expenses</div>
            <div class="card-amount red"><%= currency.format(totalExpense) %></div>
        </div>
    </section>

    <section class="panel budget-panel">
        <div class="budget-top">
            <div>
                <h2 class="section-title">Monthly Budget</h2>
                <div class="welcome"><%= today.getMonth().getDisplayName(
                    java.time.format.TextStyle.FULL, java.util.Locale.ENGLISH) %>
                    <%= today.getYear() %></div>
            </div>
            <div class="hint">Your budget is private to your account.</div>
        </div>

        <% if (budgetAmount <= 0) { %>
            <p class="welcome">You haven't set a budget for this month yet.</p>
        <% } %>

        <div class="budget-grid">
            <div class="budget-stat">
                <div class="card-label">Monthly Limit</div>
                <div class="card-amount"><%= currency.format(budgetAmount) %></div>
            </div>
            <div class="budget-stat">
                <div class="card-label">Spent This Month</div>
                <div class="card-amount red"><%= currency.format(monthlyExpense) %></div>
            </div>
            <div class="budget-stat">
                <div class="card-label"><%= remainingBudget < 0 ? "Over Budget By" : "Budget Remaining" %></div>
                <div class="card-amount <%= remainingBudget < 0 ? "red" : "green" %>">
                    <%= currency.format(Math.abs(remainingBudget)) %>
                </div>
            </div>
        </div>

        <% if (budgetAmount > 0) { %>
            <div class="budget-top">
                <span class="hint"><%= budgetPercent %>% of budget used</span>
                <% if (monthlyExpense > budgetAmount) { %>
                    <span class="red">You've exceeded your budget.</span>
                <% } else { %>
                    <span class="green">You're within your budget.</span>
                <% } %>
            </div>
            <div class="progress-track">
                <div class="progress-fill <%= monthlyExpense > budgetAmount ? "over" : "" %>"
                     style="width:<%= budgetPercent %>%"></div>
            </div>
        <% } %>

        <% if ("budgetSaved".equals(success)) { %>
            <div class="message">Monthly budget saved successfully!</div>
        <% } %>

        <form class="budget-form" action="saveBudget.jsp" method="post">
            <div class="field">
                <label for="budget_amount">Set Monthly Budget (₹)</label>
                <input type="number" id="budget_amount" name="budget_amount"
                       min="0.01" max="99999999.99" step="0.01"
                       value="<%= budgetAmount > 0 ? String.valueOf(budgetAmount) : "" %>"
                       placeholder="e.g. 5000" required>
                <input type="hidden" name="budget_month" value="<%= budgetMonth %>">
            </div>
            <button class="submit" type="submit">Save Budget</button>
        </form>
    </section>

    <section class="content">
        <div class="panel">
            <h2 class="section-title">Add Transaction</h2>

            <% if ("added".equals(success)) { %>
                <div class="message">Transaction added successfully!</div>
            <% } %>
            <% if ("deleted".equals(success)) { %>
                <div class="message">Transaction deleted successfully.</div>
            <% } %>
            <% if ("updated".equals(success)) { %>
                <div class="message">Transaction updated successfully.</div>
            <% } %>
            <% if ("invalid".equals(error)) { %>
                <div class="error">Please check the transaction details and try again.</div>
            <% } %>
            <% if ("server".equals(error) || dbError != null) { %>
                <div class="error">Something went wrong. Check the server log if it continues.</div>
            <% } %>

            <form action="addTransaction.jsp" method="post">
                <label for="type">Transaction Type</label>
                <select id="type" name="type" required>
                    <option value="expense">Expense</option>
                    <option value="income">Income</option>
                </select>

                <label for="amount">Amount (₹)</label>
                <input id="amount" name="amount" type="number" min="0.01"
                       step="0.01" placeholder="e.g. 250.00" required>

                <label for="category">Category</label>
                <select id="category" name="category" required>
                    <option value="">Choose category</option>
                    <option>Food</option><option>Transport</option>
                    <option>Education</option><option>Shopping</option>
                    <option>Entertainment</option><option>Health</option>
                    <option>Salary</option><option>Allowance</option><option>Other</option>
                </select>

                <label for="transaction_date">Date</label>
                <input id="transaction_date" name="transaction_date" type="date" required>

                <label for="description">Description</label>
                <textarea id="description" name="description" maxlength="255"
                          placeholder="What was this for?" required></textarea>

                <button class="submit" type="submit">+ Add Transaction</button>
            </form>
        </div>

        <div class="panel">
            <h2 class="section-title">Recent Transactions</h2>

            <% if (dbError != null) { %>
                <div class="error"><%= dbError %></div>
            <% } else if (transactions.isEmpty()) { %>
                <div class="empty">No transactions yet. Add your first income or expense!</div>
            <% } else { %>
                <div class="actions">
                    <span id="selectionHint" class="hint">Select a transaction to edit or delete it.</span>
                    <button id="editButton" class="action" type="button" disabled>Edit</button>
                    <button id="deleteButton" class="action delete" type="button" disabled>Delete</button>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr><th>Transaction</th><th>Category</th><th>Date</th><th>Amount</th></tr>
                        </thead>
                        <tbody>
                        <% for (Map<String,Object> item : transactions) {
                            String transactionType = (String)item.get("type");
                            boolean income = "income".equalsIgnoreCase(transactionType);
                            String description = String.valueOf(item.get("description"));
                            String category = String.valueOf(item.get("category"));
                            int transactionId = ((Integer)item.get("id")).intValue();
                        %>
                            <tr data-id="<%= transactionId %>">
                                <td><%= description.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;") %></td>
                                <td><%= category.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;") %></td>
                                <td><%= dateFormat.format(item.get("date")) %></td>
                                <td class="<%= income ? "green" : "red" %>">
                                    <%= income ? "+" : "-" %><%= currency.format(item.get("amount")) %>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </section>

    <div class="footer">SpendWise · Track your money, make it count.</div>
</div>

<script>
    var selectedId = null;
    var rows = document.querySelectorAll("tbody tr[data-id]");
    var editButton = document.getElementById("editButton");
    var deleteButton = document.getElementById("deleteButton");
    var selectionHint = document.getElementById("selectionHint");

    rows.forEach(function(row) {
        row.addEventListener("click", function() {
            rows.forEach(function(other) { other.classList.remove("selected"); });
            row.classList.add("selected");
            selectedId = row.getAttribute("data-id");
            editButton.disabled = false;
            deleteButton.disabled = false;
            selectionHint.textContent = "Selected transaction #" + selectedId;
        });
    });

    editButton.addEventListener("click", function() {
        if (selectedId !== null) {
            window.location.href = "editTransaction.jsp?id=" +
                encodeURIComponent(selectedId);
        }
    });

    deleteButton.addEventListener("click", function() {
        if (selectedId !== null && confirm("Delete this transaction permanently?")) {
            var form = document.createElement("form");
            form.method = "post";
            form.action = "deleteTransaction.jsp";

            var input = document.createElement("input");
            input.type = "hidden";
            input.name = "id";
            input.value = selectedId;

            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        }
    });

    var dateInput = document.getElementById("transaction_date");
    if (dateInput && !dateInput.value) {
        var now = new Date();
        dateInput.value = now.getFullYear() + "-" +
            String(now.getMonth()+1).padStart(2,"0") + "-" +
            String(now.getDate()).padStart(2,"0");
    }
</script>
</body>
</html>
<%
    }
%>
