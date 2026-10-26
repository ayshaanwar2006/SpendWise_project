
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.net.URLEncoder"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("login.jsp");
    } else {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String remember = request.getParameter("rememberEmail");

        if (email == null || password == null ||
            email.trim().isEmpty() || password.isEmpty()) {
            response.sendRedirect("login.jsp?error=missing");
        } else {
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

                int userId = 0;
                String username = null;

                try (Connection conn =
                         DriverManager.getConnection(url, dbUser, dbPassword);
                     PreparedStatement ps = conn.prepareStatement(
                         "SELECT id, username FROM users WHERE email = ? AND password_hash = ?")) {

                    ps.setString(1, email.trim());
                    ps.setString(2, hash.toString());

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            userId = rs.getInt("id");
                            username = rs.getString("username");
                        }
                    }
                }

                if (username == null) {
                    response.sendRedirect("login.jsp?error=invalid");
                } else {
                    if (request.getSession(false) != null) {
                        request.getSession(false).invalidate();
                    }

                    javax.servlet.http.HttpSession userSession =
                        request.getSession(true);

                    userSession.setAttribute("userId", Integer.valueOf(userId));
                    userSession.setAttribute("username", username);
                    userSession.setMaxInactiveInterval(30 * 60);

                    String contextPath = request.getContextPath();

                    if ("yes".equals(remember)) {
                        javax.servlet.http.Cookie emailCookie =
                            new javax.servlet.http.Cookie(
                                "rememberEmail",
                                URLEncoder.encode(email.trim(), "UTF-8"));

                        emailCookie.setMaxAge(30 * 24 * 60 * 60);
                        emailCookie.setHttpOnly(true);
                        emailCookie.setPath(contextPath);
                        response.addCookie(emailCookie);
                    } else {
                        javax.servlet.http.Cookie emailCookie =
                            new javax.servlet.http.Cookie("rememberEmail", "");

                        emailCookie.setMaxAge(0);
                        emailCookie.setPath(contextPath);
                        response.addCookie(emailCookie);
                    }

                    response.sendRedirect("index.jsp");
                }

            } catch (Exception ex) {
                application.log("SpendWise login error", ex);
                response.sendRedirect("login.jsp?error=server");
            }
        }
    }
%>
