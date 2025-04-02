<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Transaction Dashboard</title>
    <style>
        /* General body styling */
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 20px;
        }

        /* Container styling */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        /* Success message styling */
        .success-message {
            background-color: #d4edda;
            color: #155724;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
        }

        /* Welcome message styling */
        h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 24px;
        }

        h2 a {
            color: #4CAF50;
            text-decoration: none;
            margin-left: 10px;
        }

        h2 a:hover {
            text-decoration: underline;
        }

        /* Balance section styling */
        .balance-section {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
        }

        .balance-section h3 {
            color: #333;
            margin-bottom: 15px;
            font-size: 20px;
        }

        .balance-section p {
            font-size: 16px;
            color: #555;
            margin: 5px 0;
        }

        /* Transaction form styling */
        .transaction-form {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
        }

        .transaction-form h3 {
            color: #333;
            margin-bottom: 15px;
            font-size: 20px;
        }

        .transaction-form select,
        .transaction-form input {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 16px;
            box-sizing: border-box;
        }

        .transaction-form button {
            width: 100%;
            background-color: #4CAF50;
            color: white;
            padding: 12px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 10px;
            transition: background-color 0.3s ease;
        }

        .transaction-form button:hover {
            background-color: #45a049;
        }

        /* Clear transactions button styling */
        .clear-transactions {
            margin-bottom: 30px;
        }

        .clear-transactions button {
            background-color: #f44336;
            color: white;
            padding: 12px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .clear-transactions button:hover {
            background-color: #d32f2f;
        }

        /* Transaction history table styling */
        .transaction-history {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .transaction-history h3 {
            color: #333;
            margin-bottom: 15px;
            font-size: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #f4f4f9;
            font-weight: bold;
            color: #333;
        }

        tr:hover {
            background-color: #f9f9f9;
        }

        /* Delete button styling */
        .delete-button {
            background-color: #f44336;
            color: white;
            padding: 6px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .delete-button:hover {
            background-color: #d32f2f;
        }
    </style>
    <script>
        // Function to display success message from URL query parameters
        function showSuccessMessage() {
    const urlParams = new URLSearchParams(window.location.search);
    const success = urlParams.get('success');
    if (success) {
        // Create the success message div
        const successDiv = document.createElement('div');
        successDiv.className = 'success-message';
        successDiv.textContent = success;

        // Add the success message to the top of the container
        document.querySelector('.container').prepend(successDiv);

        // Remove the success message after 10 seconds
        setTimeout(() => {
            successDiv.remove();
        }, 3000); // 10 seconds = 10000 milliseconds
    }
}

// Call the function when the page loads
window.onload = showSuccessMessage;
    </script>
</head>
<body>
    <div class="container">
        <% 
        String mobile = (String) session.getAttribute("mobile");
        if(mobile == null) {
            response.sendRedirect("login.html");
        }
        
        double cashBalance = 0.0;
        double onlineBalance = 0.0;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");
            
            // Get user balances
            PreparedStatement ps = con.prepareStatement("SELECT cash_balance, online_balance FROM user_credentials WHERE mobile = ?");
            ps.setString(1, mobile);
            ResultSet rs = ps.executeQuery();
            
            if(rs.next()) {
                cashBalance = rs.getDouble("cash_balance");
                onlineBalance = rs.getDouble("online_balance");
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        %>
        
        <h2>Welcome, <%= session.getAttribute("name") %> | <a href="LogoutServlet">Logout</a></h2>
        
        <!-- Balance Section -->
        <div class="balance-section">
            <h3>Balance Information</h3>
            <p>Cash Balance: ₹<%= cashBalance %></p>
            <p>Online Balance: ₹<%= onlineBalance %></p>
            <p>Total Balance: ₹<%= cashBalance + onlineBalance %></p>
        </div>

        <!-- Transaction Form -->
        <div class="transaction-form">
            <h3>New Transaction</h3>
            <form action="TransactionServlet" method="post">
                <select name="type" required>
                    <option value="IN">Deposit</option>
                    <option value="OUT">Withdraw</option>
                </select>
                
                <input type="number" step="0.01" name="amount" placeholder="Amount" required>
                
                <select name="mode" required>
                    <option value="Cash">Cash</option>
                    <option value="Online">Online</option>
                </select>
                
                <input type="text" name="description" placeholder="Description" required>
                
                <button type="submit">Add Transaction</button>
            </form>
        </div>

        <!-- Clear All Transactions Button -->
        <div class="clear-transactions">
            <form action="ClearTransactionsServlet" method="post" onsubmit="return confirm('Are you sure you want to clear ALL transactions? This cannot be undone.');">
                <button type="submit">Clear All Transactions</button>
            </form>
        </div>

        <!-- Transaction History -->
        <div class="transaction-history">
            <h3>Transaction History</h3>
            <table>
                <tr>
                    <th>Date</th>
                    <th>Type</th>
                    <th>Amount</th>
                    <th>Mode</th>
                    <th>Description</th>
                    <th>Action</th>
                </tr>
                <%
                try {
                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");
                    PreparedStatement ps = con.prepareStatement("SELECT * FROM transaction_history WHERE mobile = ? ORDER BY transaction_date DESC");
                    ps.setString(1, mobile);
                    ResultSet rs = ps.executeQuery();
                    
                    while(rs.next()) {
                %>
                <tr>
                    <td><%= rs.getTimestamp("transaction_date") %></td>
                    <td><%= rs.getString("type") %></td>
                    <td>₹<%= rs.getDouble("amount") %></td>
                    <td><%= rs.getString("mode") %></td>
                    <td><%= rs.getString("description") %></td>
                    <td>
                        <form action="DeleteTransactionServlet" method="post" style="display:inline;">
                            <input type="hidden" name="transactionId" value="<%= rs.getInt("id") %>">
                            <button type="submit" class="delete-button" onclick="return confirm('Are you sure you want to delete this transaction?');">Delete</button>
                        </form>
                    </td>
                </tr>
                <% 
                    }
                    con.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }
                %>
            </table>
        </div>
    </div>
</body>
</html>