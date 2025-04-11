<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>
<%
    // Check for valid file ID
    String fileId = request.getParameter("fileId");
    if (fileId == null || fileId.isEmpty()) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Session validation
    String email = (String) session.getAttribute("email");
    String mobile = (String) session.getAttribute("mobile");
    if (email == null) {
        response.sendRedirect("login.html");
        return;
    }

    // Database connection
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");

    // Fetch user details
    String name = "";
    PreparedStatement pst = con.prepareStatement("SELECT * FROM user_credentials WHERE email=?");
    pst.setString(1, email);
    ResultSet rs = pst.executeQuery();
    if (rs.next()) {
        name = rs.getString("name");
        mobile = rs.getString("mobile");
        session.setAttribute("mobile", mobile);
    }

    // Fetch file details
    String fileName = "";
    PreparedStatement pstFile = con.prepareStatement(
        "SELECT file_name FROM user_files WHERE id = ? AND mobile = ?"
    );
    pstFile.setInt(1, Integer.parseInt(fileId));
    pstFile.setString(2, mobile);
    ResultSet rsFile = pstFile.executeQuery();
    
    if (!rsFile.next()) {
        response.sendRedirect("index.jsp");
        return;
    }
    fileName = rsFile.getString("file_name");

    // Fetch file-specific transactions
    PreparedStatement pst2 = con.prepareStatement(
        "SELECT * FROM transaction_history WHERE mobile=? AND file_id=? ORDER BY id DESC"
    );
    pst2.setString(1, mobile);
    pst2.setInt(2, Integer.parseInt(fileId));
    ResultSet trs = pst2.executeQuery();

    // Initialize data structures
    double totalIncome = 0, totalExpense = 0;
    List<Map<String, String>> incomes = new ArrayList<>();
    List<Map<String, String>> expenses = new ArrayList<>();

    // Process transactions
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
    <title><%= fileName %> - Dashboard</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />
     <!-- Add Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    
    <style>
        body { background-color: #f7f7fc; padding: 30px; }
        .card { border-radius: 15px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .transaction-form input, .transaction-form select { margin-bottom: 10px; }
        .transaction-form button { width: 100%; }
        .section-title { font-weight: bold; margin-bottom: 10px; }
        .top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .back-link { margin-right: 20px; }
        .file-title { font-size: 1.5rem; color: #2c3e50; }
    </style>
</head>
<body>

<div class="container">
    <div class="top-bar">
        <div>
            <a href="index.jsp" class="btn btn-secondary back-link">Back to Files</a>
            <h2 class="file-title" style="display: inline-block;">
                <%= fileName %>
                <small class="text-muted" style="font-size: 1rem;">(File ID: <%= fileId %>)</small>
            </h2>
        </div>
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
        <h4 class="mb-3">New Transaction</h4>
        <form action="TransactionServlet" method="post" class="transaction-form">
            <input type="hidden" name="fileId" value="<%= fileId %>">
            <div class="row g-3">
                <div class="col-md-3">
                    <select name="type" class="form-select" required>
                        <option value="IN" class="text-success">Deposit</option>
                        <option value="OUT" class="text-danger">Withdraw</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <input type="number" name="amount" step="0.01" placeholder="Amount" 
                           class="form-control" required />
                </div>
                <div class="col-md-3">
                    <select name="mode" class="form-select" required>
                        <option value="Cash">Cash</option>
                        <option value="Online">Online</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <input type="text" name="description" placeholder="Description" 
                           class="form-control" required />
                </div>
            </div>
            
            <!-- Action Buttons -->
            <div class="mt-4 d-flex flex-column flex-md-row gap-2">
                <button type="submit" class="btn btn-success btn-lg flex-grow-1">
                    <i class="bi bi-plus-circle me-2"></i>Add Transaction
                </button>
                
                <div class="d-flex gap-2 flex-grow-1">
                    <button type="reset" class="btn btn-warning btn-lg flex-grow-1">
                        <i class="bi bi-eraser me-2"></i>Clear Form
                    </button>
                    
                    <button type="button" class="btn btn-danger btn-lg flex-grow-1" 
                            data-bs-toggle="modal" data-bs-target="#clearAllModal">
                        <i class="bi bi-trash3 me-2"></i>Clear All
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- Clear All Confirmation Modal -->
    <div class="modal fade" id="clearAllModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Confirm Clear All</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    Are you sure you want to delete ALL transactions in this file?<br>
                    <strong class="text-danger">This action cannot be undone!</strong>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <form action="ClearTransactionsServlet" method="post">
                        <input type="hidden" name="fileId" value="<%= fileId %>">
                        <button type="submit" class="btn btn-danger">
                            Confirm Delete All
                        </button>
                    </form>
                </div>
            </div>
        </div>
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
                                        <input type="hidden" name="transactionId" value="<%= tr.get("id") %>">
                                        <input type="hidden" name="fileId" value="<%= fileId %>">
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
                                        <input type="hidden" name="transactionId" value="<%= tr.get("id") %>">
                                        <input type="hidden" name="fileId" value="<%= fileId %>">
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