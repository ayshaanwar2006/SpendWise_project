<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("register.jsp");
        return;
    }

    String username = request.getParameter("username");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");

    if (username == null || email == null || password == null ||
        confirmPassword == null) {
        response.sendRedirect("register.jsp?error=invalid");
        return;
    }

    username = username.trim();
    email = email.trim();

    if (username.isEmpty() || email.isEmpty() ||
        username.length() > 50 || email.length() > 100 ||
        !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
        response.sendRedirect("register.jsp?error=invalid");
        return;
    }

    if (!password.equals(confirmPassword)) {
        response.sendRedirect("register.jsp?error=password");
        return;
    }

    if (password.length() < 8) {
        response.sendRedirect("register.jsp?error=weak");
        return;
    }

    String url = "jdbc:mysql://localhost:3306/spendwise";
    String dbUser = "root";
    String dbPassword = "windows";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");

        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] digest = md.digest(password.getBytes(StandardCharsets.UTF_8));
        StringBuilder hash = new StringBuilder();

        for (byte b : digest) {
            hash.append(String.format("%02x", b & 0xff));
        }

        try (Connection conn =
                 DriverManager.getConnection(url, dbUser, dbPassword)) {

            String checkSql =
                "SELECT id FROM users WHERE username = ? OR email = ?";

            try (PreparedStatement check = conn.prepareStatement(checkSql)) {
                check.setString(1, username);
                check.setString(2, email);

                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) {
                        response.sendRedirect("register.jsp?error=exists");
                        return;
                    }
                }
            }

            String insertSql =
                "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)";

            try (PreparedStatement insert = conn.prepareStatement(insertSql)) {
                insert.setString(1, username);
                insert.setString(2, email);
                insert.setString(3, hash.toString());
                insert.executeUpdate();
            }
        }

        response.sendRedirect("login.jsp?error=registered");
        return;

    } catch (java.sql.SQLIntegrityConstraintViolationException ex) {
        response.sendRedirect("register.jsp?error=exists");
        return;
    } catch (Exception ex) {
        application.log("SpendWise registration error", ex);
        response.sendRedirect("register.jsp?error=server");
        return;
    }
%>