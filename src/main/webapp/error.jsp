<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Error</title>
    <style>
        /* General body styling */
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f4f9;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            padding: 0;
        }

        /* Container styling */
        .container {
            background-color: #ffffff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            max-width: 500px;
            width: 100%;
            text-align: center;
        }

        /* Heading styling */
        h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 24px;
        }

        /* Link styling */
        a {
            color: #4CAF50;
            text-decoration: none;
            font-weight: bold;
            transition: color 0.3s ease;
        }

        a:hover {
            color: #45a049;
            text-decoration: underline;
        }

        /* Error message styling */
        .error-message {
            color: #ff0000;
            font-size: 18px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Oops! Something Went Wrong</h2>
        <div class="error-message">
            An error occurred. Please try again later.
        </div>
        <a href="dashboard.jsp">Go back to Dashboard</a>
    </div>
</body>
</html>