
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    javax.servlet.http.HttpSession userSession = request.getSession(false);

    if (userSession != null) {
        userSession.invalidate();
    }

    response.sendRedirect("login.jsp?error=logout");
%>
