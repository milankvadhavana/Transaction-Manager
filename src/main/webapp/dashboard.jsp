<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>
<%
    String email = (String) session.getAttribute("email");
    String mobile = (String) session.getAttribute("mobile");

    if (email == null) {
        response.sendRedirect("login.html");
        return;
    }

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");

    // Fetch user details
    PreparedStatement pst = con.prepareStatement("SELECT * FROM user_credentials WHERE email=?");
    pst.setString(1, email);
    ResultSet rs = pst.executeQuery();
    String name = "";
    if (rs.next()) {
        name = rs.getString("name");
        mobile = rs.getString("mobile");
        session.setAttribute("mobile", mobile); // Ensure mobile is stored in session
    }

    // Fetch transaction history
    PreparedStatement pst2 = con.prepareStatement("SELECT * FROM transaction_history WHERE mobile=? ORDER BY id DESC");
    pst2.setString(1, mobile);
    ResultSet trs = pst2.executeQuery();

    double totalIncome = 0, totalExpense = 0;
    List<Map<String, String>> incomes = new ArrayList<>();
    List<Map<String, String>> expenses = new ArrayList<>();

    while (trs.next()) {
        String type = trs.getString("type");
        String amount = trs.getString("amount");
        String mode = trs.getString("mode");
        String desc = trs.getString("description");
        String id = trs.getString("id");

        Map<String, String> record = new HashMap<>();
        record.put("amount", amount);
        record.put("mode", mode);
        record.put("desc", desc);
        record.put("id", id);

        if (type.equals("IN")) {
            incomes.add(record);
            totalIncome += Double.parseDouble(amount);
        } else {
            expenses.add(record);
            totalExpense += Double.parseDouble(amount);
        }
    }

    double balance = totalIncome - totalExpense;
%>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />
    <style>
        body { background-color: #f7f7fc; padding: 30px; }
        .card { border-radius: 15px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .transaction-form input, .transaction-form select { margin-bottom: 10px; }
        .transaction-form button { width: 100%; }
        .section-title { font-weight: bold; margin-bottom: 10px; }
        .top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
    </style>
</head>
<body>

<div class="container">
    <div class="top-bar">
        <h2>Welcome, <%= name %>!</h2>
        <a href="LogoutServlet" class="btn btn-outline-danger">Logout</a>
    </div>

    <!-- Balance Section -->
    <div class="row mb-4">
        <div class="col-md-4">
            <div class="card text-white bg-primary p-3">
                <h5>Total Income</h5>
                <h3>Rs. <%= totalIncome %></h3>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card text-white bg-danger p-3">
                <h5>Total Expense</h5>
                <h3>Rs. <%= totalExpense %></h3>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card text-white bg-success p-3">
                <h5>Current Balance</h5>
                <h3>Rs. <%= balance %></h3>
            </div>
        </div>
    </div>

    <!-- Transaction Form -->
    <div class="card mb-5 p-4">
        <h4 class="mb-3">Add New Transaction</h4>
        <form action="TransactionServlet" method="post" class="transaction-form">
            <div class="row">
                <div class="col-md-3">
                    <select name="type" class="form-control" required>
                        <option value="IN">Deposit</option>
                        <option value="OUT">Withdraw</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <input type="number" name="amount" step="0.01" placeholder="Amount" class="form-control" required />
                </div>
                <div class="col-md-3">
                    <select name="mode" class="form-control" required>
                        <option value="Cash">Cash</option>
                        <option value="Online">Online</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <input type="text" name="description" placeholder="Description" class="form-control" required />
                </div>
            </div>
            <div class="mt-3 d-flex gap-2">
    			<button type="submit" class="btn btn-success">Add Transaction</button>
    			<button type="reset" class="btn btn-warning">Clear</button>
			</div>
		</form> <!-- closes transaction form -->

		<!-- Clear All Button in its own form -->
		<form action="ClearTransactionsServlet" method="post" onsubmit="return confirm('Are you sure you want to clear all transactions?');" class="mt-2">
    			<button type="submit" class="btn btn-danger">Clear All Transactions</button>
			</form>
    </div>

    <!-- Transaction Lists -->
    <div class="row">
        <!-- Income Section -->
        <div class="col-md-6">
            <div class="card p-4">
                <h5 class="section-title">Income Transactions</h5>
                <table class="table table-bordered">
                    <thead>
                        <tr><th>Amount</th><th>Mode</th><th>Description</th><th>Action</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, String> tr : incomes) { %>
                            <tr>
                                <td>Rs. <%= tr.get("amount") %></td>
                                <td><%= tr.get("mode") %></td>
                                <td><%= tr.get("desc") %></td>
                                <td>
                                    <form action="DeleteTransactionServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="transactionId" value="<%= tr.get("id") %>"/>
                                        <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
                <p><strong>Total Income:</strong> Rs. <%= totalIncome %></p>
            </div>
        </div>

        <!-- Expense Section -->
        <div class="col-md-6">
            <div class="card p-4">
                <h5 class="section-title">Expense Transactions</h5>
                <table class="table table-bordered">
                    <thead>
                        <tr><th>Amount</th><th>Mode</th><th>Description</th><th>Action</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, String> tr : expenses) { %>
                            <tr>
                                <td>Rs. <%= tr.get("amount") %></td>
                                <td><%= tr.get("mode") %></td>
                                <td><%= tr.get("desc") %></td>
                                <td>
                                    <form action="DeleteTransactionServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="transactionId" value="<%= tr.get("id") %>"/>
                                        <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
                <p><strong>Total Expense:</strong> Rs. <%= totalExpense %></p>
            </div>
        </div>
    </div>
</div>

</body>
</html>
