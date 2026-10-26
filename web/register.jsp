
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String error = request.getParameter("error");
    String message = "";

    if ("password".equals(error)) {
        message = "Passwords do not match.";
    } else if ("weak".equals(error)) {
        message = "Password must contain at least 8 characters.";
    } else if ("exists".equals(error)) {
        message = "That username or email is already registered.";
    } else if ("invalid".equals(error)) {
        message = "Please enter valid account details.";
    } else if ("server".equals(error)) {
        message = "Could not create account. Please try again.";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SpendWise | Create Account</title>
    <style>
        * { box-sizing: border-box; }

        body {
            margin: 0; min-height: 100vh; display: flex;
            justify-content: center; align-items: center; padding: 20px;
            background: radial-gradient(circle at 15% 20%, #064e3b, transparent 35%),
                        radial-gradient(circle at 85% 80%, #164e63, transparent 35%),
                        #070b12;
            font-family: Arial, sans-serif; color: #f1f5f9;
        }

        .card {
            width: 100%; max-width: 440px; padding: 35px;
            border: 1px solid rgba(110,231,183,.3); border-radius: 24px;
            background: rgba(15,23,42,.92);
            box-shadow: 0 0 45px rgba(16,185,129,.12);
        }

        .logo { text-align: center; color: #6ee7b7;
                font-size: 31px; font-weight: bold; }
        .subtitle { text-align: center; color: #94a3b8;
                    margin: 10px 0 24px; }
        label { display: block; margin: 16px 0 7px;
                font-size: 14px; color: #cbd5e1; }

        input {
            width: 100%; padding: 13px; border-radius: 10px;
            border: 1px solid #334155; background: #0b1220;
            color: white; outline: none; font-size: 14px;
        }
        input:focus { border-color: #6ee7b7; }

        button {
            width: 100%; padding: 14px; margin-top: 24px;
            border: 0; border-radius: 10px; background: #6ee7b7;
            color: #052e24; font-weight: bold; font-size: 16px;
            cursor: pointer;
        }
        button:hover { background: #a7f3d0; }

        .message { margin-top: 15px; padding: 11px; border-radius: 8px;
                   background: rgba(248,113,113,.12); color: #fca5a5;
                   text-align: center; font-size: 13px; }

        .links { text-align: center; margin-top: 22px;
                 color: #94a3b8; font-size: 14px; }
        a { color: #6ee7b7; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <main class="card">
        <div class="logo">SpendWise.</div>
        <p class="subtitle">Create your account</p>

        <% if (!message.isEmpty()) { %>
            <div class="message"><%= message %></div>
        <% } %>

        <form action="registerProcess.jsp" method="post">
            <label for="username">Username</label>
            <input type="text" id="username" name="username"
                   maxlength="50" required autocomplete="username"
                   placeholder="Choose a username">

            <label for="email">Email address</label>
            <input type="email" id="email" name="email"
                   maxlength="100" required autocomplete="email"
                   placeholder="you@example.com">

            <label for="password">Password</label>
            <input type="password" id="password" name="password"
                   minlength="8" required autocomplete="new-password"
                   placeholder="At least 8 characters">

            <label for="confirmPassword">Confirm password</label>
            <input type="password" id="confirmPassword"
                   name="confirmPassword" minlength="8" required
                   autocomplete="new-password"
                   placeholder="Enter the password again">

            <button type="submit">Create Account &#8594;</button>
        </form>

        <div class="links">
            Already have an account? <a href="login.jsp">Sign In</a>
        </div>
    </main>
</body>
</html>
