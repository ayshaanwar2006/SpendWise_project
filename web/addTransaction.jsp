
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
        String type = request.getParameter("type");
        String amountText = request.getParameter("amount");
        String category = request.getParameter("category");
        String dateText = request.getParameter("transaction_date");
        String description = request.getParameter("description");

        try {
            int userId = ((Integer) userSession.getAttribute("userId")).intValue();

            if (type == null || amountText == null || category == null ||
                dateText == null || description == null ||
                (!"income".equals(type) && !"expense".equals(type)) ||
                category.trim().isEmpty() || description.trim().isEmpty() ||
                category.trim().length() > 50 || description.trim().length() > 255) {

                response.sendRedirect("index.jsp?error=invalid");

            } else {
                BigDecimal amount = new BigDecimal(amountText);

                if (amount.compareTo(BigDecimal.ZERO) <= 0 ||
                    amount.scale() > 2 || amount.precision() > 10) {

                    response.sendRedirect("index.jsp?error=invalid");

                } else {
                    Date transactionDate = Date.valueOf(dateText);

                    String url = "jdbc:mysql://localhost:3306/spendwise";
                    String dbUser = "root";
                    String dbPassword = "windows";

                    Class.forName("com.mysql.cj.jdbc.Driver");

                    try (Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);
                         PreparedStatement ps = conn.prepareStatement(
                             "INSERT INTO transactions " +
                             "(user_id, type, amount, category, transaction_date, description) " +
                             "VALUES (?, ?, ?, ?, ?, ?)")) {

                        ps.setInt(1, userId);
                        ps.setString(2, type);
                        ps.setBigDecimal(3, amount);
                        ps.setString(4, category.trim());
                        ps.setDate(5, transactionDate);
                        ps.setString(6, description.trim());

                        ps.executeUpdate();
                    }

                    response.sendRedirect("index.jsp?success=added");
                }
            }
        } catch (Exception ex) {
            application.log("SpendWise transaction insert error", ex);
            response.sendRedirect("index.jsp?error=server");
        }
    }
%>
