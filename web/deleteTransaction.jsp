
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    javax.servlet.http.HttpSession userSession = request.getSession(false);

    if (userSession == null || userSession.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
    } else if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("index.jsp");
    } else {
        String idText = request.getParameter("id");

        try {
            int userId = ((Integer) userSession.getAttribute("userId")).intValue();
            int transactionId = Integer.parseInt(idText);

            String url = "jdbc:mysql://localhost:3306/spendwise";
            String dbUser = "root";
            String dbPassword = "windows";

            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);
                 PreparedStatement ps = conn.prepareStatement(
                     "DELETE FROM transactions WHERE id = ? AND user_id = ?")) {

                ps.setInt(1, transactionId);
                ps.setInt(2, userId);

                int deleted = ps.executeUpdate();

                if (deleted == 1) {
                    response.sendRedirect("index.jsp?success=deleted");
                } else {
                    response.sendRedirect("index.jsp?error=invalid");
                }
            }
        } catch (Exception ex) {
            application.log("SpendWise delete error", ex);
            response.sendRedirect("index.jsp?error=server");
        }
    }
%>
