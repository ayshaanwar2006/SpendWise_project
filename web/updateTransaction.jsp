
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
            int id = Integer.parseInt(request.getParameter("id"));

            String type = request.getParameter("type");
            String amountText = request.getParameter("amount");
            String category = request.getParameter("category");
            String dateText = request.getParameter("transaction_date");
            String description = request.getParameter("description");

            if (type == null || amountText == null || category == null ||
                dateText == null || description == null ||
                (!"income".equals(type) && !"expense".equals(type)) ||
                category.trim().isEmpty() || category.trim().length() > 50 ||
                description.trim().isEmpty() || description.trim().length() > 255) {

                response.sendRedirect("index.jsp?error=invalid");

            } else {
                BigDecimal amount = new BigDecimal(amountText);

                if (amount.compareTo(BigDecimal.ZERO) <= 0 ||
                    amount.scale() > 2 || amount.precision() > 10) {

                    response.sendRedirect("index.jsp?error=invalid");

                } else {
                    Date transactionDate = Date.valueOf(dateText);

                    Class.forName("com.mysql.cj.jdbc.Driver");

                    try (Connection conn = DriverManager.getConnection(
                            "jdbc:mysql://localhost:3306/spendwise",
                            "root", "windows");
                         PreparedStatement ps = conn.prepareStatement(
                            "UPDATE transactions SET type=?, amount=?, category=?, " +
                            "transaction_date=?, description=? WHERE id=? AND user_id=?")) {

                        ps.setString(1, type);
                        ps.setBigDecimal(2, amount);
                        ps.setString(3, category.trim());
                        ps.setDate(4, transactionDate);
                        ps.setString(5, description.trim());
                        ps.setInt(6, id);
                        ps.setInt(7, userId);

                        int updated = ps.executeUpdate();

                        if (updated == 1) {
                            response.sendRedirect("index.jsp?success=updated");
                        } else {
                            response.sendRedirect("index.jsp?error=invalid");
                        }
                    }
                }
            }

        } catch (Exception ex) {
            application.log("SpendWise transaction update error", ex);
            response.sendRedirect("index.jsp?error=server");
        }
    }
%>
