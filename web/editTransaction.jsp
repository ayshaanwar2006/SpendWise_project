
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    javax.servlet.http.HttpSession userSession = request.getSession(false);

    if (userSession == null || userSession.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
    } else {
        int userId = ((Integer) userSession.getAttribute("userId")).intValue();
        String idText = request.getParameter("id");

        int transactionId = 0;
        String type = "";
        String category = "";
        String description = "";
        String date = "";
        java.math.BigDecimal amount = java.math.BigDecimal.ZERO;
        boolean found = false;
        String dbError = null;

        try {
            transactionId = Integer.parseInt(idText);

            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/spendwise", "root", "windows");
                 PreparedStatement ps = conn.prepareStatement(
                    "SELECT type, amount, category, transaction_date, description " +
                    "FROM transactions WHERE id = ? AND user_id = ?")) {

                ps.setInt(1, transactionId);
                ps.setInt(2, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        type = rs.getString("type");
                        amount = rs.getBigDecimal("amount");
                        category = rs.getString("category");
                        date = rs.getDate("transaction_date").toString();
                        description = rs.getString("description");
                        found = true;
                    }
                }
            }
        } catch (Exception ex) {
            application.log("SpendWise edit page error", ex);
            dbError = "Could not load this transaction.";
        }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Transaction | SpendWise</title>
    <link rel="stylesheet" href="style.css">
    <style>
        * { box-sizing:border-box; }
        body { margin:0; padding:24px; background:#0b1110; color:#eef8f3; font-family:Arial,sans-serif; }
        .panel { max-width:560px; margin:35px auto; padding:28px; background:#141e1a; border:1px solid #263a31; border-radius:16px; }
        h1 { color:#67e8b5; margin-top:0; }
        label { display:block; margin:15px 0 7px; color:#c2d2ca; }
        input,select,textarea { width:100%; padding:12px; border-radius:8px; border:1px solid #35483e; background:#0b1310; color:#eef8f3; font:inherit; }
        textarea { min-height:80px; }
        button,a { display:inline-block; margin-top:18px; padding:12px 16px; border:0; border-radius:8px; font-weight:bold; text-decoration:none; cursor:pointer; }
        button { background:#67e8b5; color:#0b1110; }
        a { color:#eef8f3; background:#293a32; }
        .error { color:#ffaaaa; }
    </style>
</head>
<body>
<div class="panel">
    <h1>Edit Transaction</h1>

    <% if (dbError != null) { %>
        <p class="error"><%= dbError %></p>
        <a href="index.jsp">Back to Dashboard</a>
    <% } else if (!found) { %>
        <p class="error">Transaction not found or you don't have permission to edit it.</p>
        <a href="index.jsp">Back to Dashboard</a>
    <% } else { %>
        <form action="updateTransaction.jsp" method="post">
            <input type="hidden" name="id" value="<%= transactionId %>">

            <label for="type">Type</label>
            <select id="type" name="type" required>
                <option value="expense" <%= "expense".equals(type) ? "selected" : "" %>>Expense</option>
                <option value="income" <%= "income".equals(type) ? "selected" : "" %>>Income</option>
            </select>

            <label for="amount">Amount (₹)</label>
            <input id="amount" name="amount" type="number" min="0.01" step="0.01"
                   value="<%= amount.toPlainString() %>" required>

            <label for="category">Category</label>
            <select id="category" name="category" required>
                <option value="">Choose category</option>
                <option <%= "Food".equals(category) ? "selected" : "" %>>Food</option>
                <option <%= "Transport".equals(category) ? "selected" : "" %>>Transport</option>
                <option <%= "Education".equals(category) ? "selected" : "" %>>Education</option>
                <option <%= "Shopping".equals(category) ? "selected" : "" %>>Shopping</option>
                <option <%= "Entertainment".equals(category) ? "selected" : "" %>>Entertainment</option>
                <option <%= "Health".equals(category) ? "selected" : "" %>>Health</option>
                <option <%= "Salary".equals(category) ? "selected" : "" %>>Salary</option>
                <option <%= "Allowance".equals(category) ? "selected" : "" %>>Allowance</option>
                <option <%= "Other".equals(category) ? "selected" : "" %>>Other</option>
            </select>

            <label for="transaction_date">Date</label>
            <input id="transaction_date" name="transaction_date" type="date"
                   value="<%= date %>" required>

            <label for="description">Description</label>
            <textarea id="description" name="description" maxlength="255" required><%= description.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;") %></textarea>

            <button type="submit">Save Changes</button>
            <a href="index.jsp">Cancel</a>
        </form>
    <% } %>
</div>
</body>
</html>
<%
    }
%>
