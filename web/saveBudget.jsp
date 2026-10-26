
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.sql.Date"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    javax.servlet.http.HttpSession userSession = request.getSession(false);

    if (userSession == null || userSession.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
    } else if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("index.jsp");
    } else {
        try {
            int userId = ((Integer) userSession.getAttribute("userId")).intValue();

            String amountText = request.getParameter("budget_amount");
            String monthText = request.getParameter("budget_month");

            if (amountText == null || monthText == null ||
                amountText.trim().isEmpty() || monthText.trim().isEmpty()) {
                response.sendRedirect("index.jsp?error=invalid");
            } else {
                BigDecimal amount = new BigDecimal(amountText.trim());
                Date month = Date.valueOf(monthText.trim());

                // The budget date must be the first day of a month.
                java.time.LocalDate budgetDate =
                    java.time.LocalDate.parse(monthText.trim());

                if (budgetDate.getDayOfMonth() != 1 ||
                    amount.compareTo(BigDecimal.ZERO) <= 0 ||
                    amount.scale() > 2 ||
                    amount.compareTo(new BigDecimal("99999999.99")) > 0) {

                    response.sendRedirect("index.jsp?error=invalid");

                } else {
                    Class.forName("com.mysql.cj.jdbc.Driver");

                    String url = "jdbc:mysql://localhost:3306/spendwise";
                    String dbUser = "root";
                    String dbPassword = "windows";

                    String sql =
                        "INSERT INTO monthly_budgets " +
                        "(user_id, budget_month, budget_amount) VALUES (?, ?, ?) " +
                        "ON DUPLICATE KEY UPDATE budget_amount = VALUES(budget_amount)";

                    try (Connection conn =
                             DriverManager.getConnection(url, dbUser, dbPassword);
                         PreparedStatement ps = conn.prepareStatement(sql)) {

                        ps.setInt(1, userId);
                        ps.setDate(2, month);
                        ps.setBigDecimal(3, amount);

                        ps.executeUpdate();
                    }

                    response.sendRedirect("index.jsp?success=budgetSaved");
                }
            }

        } catch (Exception ex) {
            application.log("SpendWise save budget error", ex);
            response.sendRedirect("index.jsp?error=server");
        }
    }
%>
