
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.SQLException"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SpendWise - Database Test</title>
</head>
<body>
<%
    String url = "jdbc:mysql://localhost:3306/spendwise";
    String user = "root";
    String password = "windows";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");

        try (Connection conn =
                DriverManager.getConnection(url, user, password)) {
%>
            <h1>Connected successfully!</h1>
            <p>SpendWise is connected to the MySQL database.</p>
<%
        }
    } catch (ClassNotFoundException | SQLException e) {
%>
        <h1>Database connection failed!</h1>
        <pre><%= e.getMessage() %></pre>
<%
        e.printStackTrace();
    }
%>
</body>
</html>
