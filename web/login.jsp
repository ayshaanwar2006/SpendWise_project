
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String savedEmail = "";
    boolean rememberEmail = false;
    javax.servlet.http.Cookie[] cookies = request.getCookies();

    if (cookies != null) {
        for (javax.servlet.http.Cookie c : cookies) {
            if ("rememberEmail".equals(c.getName())) {
                try {
                    savedEmail = java.net.URLDecoder.decode(
                        c.getValue(), "UTF-8");
                    rememberEmail = true;
                } catch (Exception ex) {
                    savedEmail = "";
                }
                break;
            }
        }
    }

    savedEmail = savedEmail.replace("&", "&amp;")
        .replace("\"", "&quot;")
        .replace("<", "&lt;")
        .replace(">", "&gt;");

    String error = request.getParameter("error");
    String message = "";

    if ("invalid".equals(error)) {
        message = "Incorrect email or password.";
    } else if ("exists".equals(error)) {
        message = "That account already exists. Please sign in.";
    } else if ("missing".equals(error)) {
        message = "Please fill in all fields.";
    } else if ("server".equals(error)) {
        message = "A server error occurred. Please try again.";
    } else if ("registered".equals(error)) {
        message = "Account created! You can now sign in.";
    } else if ("logout".equals(error)) {
        message = "You have been logged out.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SpendWise | Login</title>

    <style>
        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            font-family: Arial, sans-serif;
            color: #f1f5f9;
            background:
                radial-gradient(circle at 15% 20%, #064e3b, transparent 35%),
                radial-gradient(circle at 85% 80%, #164e63, transparent 35%),
                #070b12;
        }

        .card {
            width: 100%;
            max-width: 420px;
            padding: 36px;
            border: 1px solid rgba(110,231,183,.3);
            border-radius: 24px;
            background: rgba(15,23,42,.9);
            box-shadow: 0 0 45px rgba(16,185,129,.12);
            animation: appear .6s ease;
        }

        @keyframes appear {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .logo {
            text-align: center;
            color: #6ee7b7;
            font-size: 32px;
            font-weight: bold;
        }

        .subtitle {
            text-align: center;
            color: #94a3b8;
            margin: 10px 0 28px;
        }

        label.field {
            display: block;
            margin: 17px 0 8px;
            font-size: 14px;
            color: #cbd5e1;
        }

        input[type=email], input[type=password] {
            width: 100%;
            padding: 14px;
            border-radius: 10px;
            border: 1px solid #334155;
            background: #0b1220;
            color: white;
            outline: none;
            font-size: 14px;
        }

        input:focus {
            border-color: #6ee7b7;
            box-shadow: 0 0 0 3px rgba(110,231,183,.1);
        }

        .remember {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #cbd5e1;
            font-size: 13px;
            margin: 19px 0;
        }

        .remember input { accent-color: #6ee7b7; }

        button {
            width: 100%;
            padding: 14px;
            border: 0;
            border-radius: 10px;
            background: #6ee7b7;
            color: #052e24;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 5px;
        }

        button:hover { background: #a7f3d0; }

        .message {
            padding: 11px;
            margin: 15px 0;
            border-radius: 8px;
            background: rgba(110,231,183,.1);
            color: #a7f3d0;
            font-size: 13px;
            text-align: center;
        }

        .signup {
            text-align: center;
            margin-top: 22px;
            font-size: 14px;
            color: #94a3b8;
        }

        .signup a {
            color: #6ee7b7;
            font-weight: bold;
            text-decoration: underline;
            text-underline-offset: 3px;
        }

        .signup a:hover { color: #a7f3d0; }

        .footer {
            text-align: center;
            color: #64748b;
            font-size: 10px;
            margin-top: 25px;
            letter-spacing: 1.5px;
        }
    </style>
</head>

<body>
    <main class="card">
        <div class="logo">SpendWise.</div>
        <p class="subtitle">Your money. Your control.</p>

        <% if (!message.isEmpty()) { %>
            <div class="message"><%= message %></div>
        <% } %>

        <form action="loginProcess.jsp" method="post">
            <label class="field" for="email">Email address</label>
            <input type="email" id="email" name="email"
                   placeholder="you@example.com" required
                   autocomplete="email" value="<%= savedEmail %>">

            <label class="field" for="password">Password</label>
            <input type="password" id="password" name="password"
                   placeholder="Enter your password" required
                   autocomplete="current-password">

            <label class="remember">
                <input type="checkbox" name="rememberEmail" value="yes"
                    <%= rememberEmail ? "checked" : "" %>>
                Remember my email on this device
            </label>

            <button type="submit">Sign In &#8594;</button>
        </form>

        <div class="signup">
            Don't have an account?
            <a href="register.jsp">Sign up</a>
        </div>

        <div class="footer">SECURE ACCESS &middot; SPENDWISE</div>
    </main>
</body>
</html>
