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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= fileName %> - Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4361ee;
            --primary-dark: #3a56d4;
            --secondary-color: #4cc9f0;
            --success-color: #4bb543;
            --danger-color: #ff3333;
            --warning-color: #ffcc00;
            --light-color: #f8f9fa;
            --dark-color: #212529;
            --border-radius: 12px;
            --box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            --transition: all 0.3s ease;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f5f7fa;
            color: var(--dark-color);
            padding: 0;
        }

        .navbar {
            background-color: white;
            box-shadow: var(--box-shadow);
            padding: 15px 0;
        }

        .navbar-brand {
            font-weight: 700;
            color: var(--primary-color);
            display: inline-flex;
            align-items: center;
        }

        .navbar-brand i {
            margin-right: 10px;
            font-size: 24px;
        }

        .dashboard-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            color: white;
            padding: 30px 0;
            margin-bottom: 30px;
            border-radius: 0 0 var(--border-radius) var(--border-radius);
        }

        .file-title {
            font-weight: 600;
            margin-bottom: 5px;
        }

        .file-subtitle {
            opacity: 0.9;
            font-weight: 300;
        }

        .card {
            border: none;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            transition: var(--transition);
            margin-bottom: 20px;
        }

        .card:hover {
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.15);
        }

        .summary-card {
            color: white;
            padding: 20px;
            text-align: center;
            height: 100%;
        }

        .summary-card h5 {
            font-weight: 500;
            margin-bottom: 10px;
        }

        .summary-card h3 {
            font-weight: 600;
            margin-bottom: 0;
        }

        .income-card {
            background: linear-gradient(135deg, #2ecc71 0%, #27ae60 100%);
        }

        .expense-card {
            background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
        }

        .balance-card {
            background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
        }

        .transaction-form .form-control, 
        .transaction-form .form-select {
            border-radius: var(--border-radius);
            padding: 12px 15px;
        }

        .btn-lg {
            padding: 12px 20px;
            font-weight: 500;
            border-radius: var(--border-radius);
        }

        .btn-success {
            background: linear-gradient(135deg, var(--success-color) 0%, #3a9a4d 100%);
            border: none;
        }

        .btn-warning {
            background: linear-gradient(135deg, var(--warning-color) 0%, #e6b800 100%);
            border: none;
            color: #333;
        }

        .btn-danger {
            background: linear-gradient(135deg, var(--danger-color) 0%, #cc0000 100%);
            border: none;
        }

        .transaction-section {
            margin-top: 30px;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
        }

        .section-title {
            font-weight: 600;
            color: var(--dark-color);
            margin: 0;
        }

        .transaction-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 10px;
        }

        .transaction-table thead th {
            background-color: rgba(67, 97, 238, 0.1);
            padding: 12px 15px;
            font-weight: 500;
            color: #666;
        }

        .transaction-table tbody tr {
            background-color: white;
            border-radius: var(--border-radius);
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            transition: var(--transition);
        }

        .transaction-table tbody tr:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .transaction-table tbody td {
            padding: 15px;
            vertical-align: middle;
            border-top: none;
            border-bottom: none;
        }

        .transaction-table tbody td:first-child {
            border-top-left-radius: var(--border-radius);
            border-bottom-left-radius: var(--border-radius);
        }

        .transaction-table tbody td:last-child {
            border-top-right-radius: var(--border-radius);
            border-bottom-right-radius: var(--border-radius);
        }

        .income-row td:first-child {
            border-left: 4px solid var(--success-color);
        }

        .expense-row td:first-child {
            border-left: 4px solid var(--danger-color);
        }

        .amount-cell {
            font-weight: 600;
        }

        .income-amount {
            color: var(--success-color);
        }

        .expense-amount {
            color: var(--danger-color);
        }

        .action-buttons {
            display: flex;
            gap: 10px;
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #666;
        }

        .empty-state i {
            font-size: 50px;
            color: #ddd;
            margin-bottom: 20px;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            margin-bottom: 20px;
        }

        @media (max-width: 768px) {
            .dashboard-header {
                padding: 20px 0;
            }
            
            .action-buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg">
        <div class="container">
            <a class="navbar-brand" href="index.jsp">
                <i class="fas fa-wallet"></i> Transaction Manager
            </a>
            <div class="d-flex align-items-center">
                <span class="me-3 d-none d-sm-inline">Welcome, <%= name %></span>
                
            </div>
        </div>
    </nav>

    <!-- Dashboard Header -->
    <div class="dashboard-header">
        <div class="container">
            <a href="index.jsp" class="btn btn-light back-btn">
                <i class="fas fa-arrow-left me-2"></i> Back to Files
            </a>
            <h1 class="file-title"><%= fileName %></h1>
            <p class="file-subtitle">File ID: <%= fileId %> | Last updated: <%= new java.util.Date() %></p>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container mb-5">
        <!-- Financial Summary Cards -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card summary-card income-card">
                    <h5><i class="fas fa-arrow-down me-2"></i> Total Income</h5>
                    <h3>Rs.<%= String.format("%.2f", totalIncome) %></h3>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card summary-card expense-card">
                    <h5><i class="fas fa-arrow-up me-2"></i> Total Expense</h5>
                    <h3>Rs. <%= String.format("%.2f", totalExpense) %></h3>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card summary-card balance-card">
                    <h5><i class="fas fa-balance-scale me-2"></i> Current Balance</h5>
                    <h3>Rs. <%= String.format("%.2f", balance) %></h3>
                </div>
            </div>
        </div>

        <!-- Transaction Form -->
        <div class="card p-4 mb-5">
            <h4 class="mb-4"><i class="fas fa-plus-circle me-2"></i>Add New Transaction</h4>
            <form action="TransactionServlet" method="post" class="transaction-form">
                <input type="hidden" name="fileId" value="<%= fileId %>">
                <div class="row g-3">
                    <div class="col-md-3">
                        <select name="type" class="form-select" required>
                            <option value="IN" class="text-success">Income</option>
                            <option value="OUT" class="text-danger">Expense</option>
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
                            <option value="Card">Card</option>
                            <option value="Bank Transfer">Bank Transfer</option>
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
                        <i class="fas fa-plus me-2"></i>Add Transaction
                    </button>
                    
                    <div class="d-flex gap-2 flex-grow-1">
                        <button type="reset" class="btn btn-warning btn-lg flex-grow-1">
                            <i class="fas fa-eraser me-2"></i>Clear Form
                        </button>
                        
                        <button type="button" class="btn btn-danger btn-lg flex-grow-1" 
                                data-bs-toggle="modal" data-bs-target="#clearAllModal">
                            <i class="fas fa-trash-alt me-2"></i>Clear All
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
                        <h5 class="modal-title">Confirm Clear All Transactions</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p>Are you sure you want to delete ALL transactions in this file?</p>
                        <p class="text-danger"><strong>Warning: This action cannot be undone!</strong></p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <form action="ClearTransactionsServlet" method="post">
                            <input type="hidden" name="fileId" value="<%= fileId %>">
                            <button type="submit" class="btn btn-danger">
                                <i class="fas fa-trash-alt me-2"></i>Confirm Delete All
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Transaction Sections -->
        <div class="row">
            <!-- Income Section -->
            <div class="col-md-6">
                <div class="transaction-section">
                    <div class="section-header">
                        <h3 class="section-title"><i class="fas fa-arrow-down text-success me-2"></i>Income Transactions</h3>
                        <span class="badge bg-success"><%= incomes.size() %> records</span>
                    </div>
                    
                    <% if (incomes.isEmpty()) { %>
                        <div class="card empty-state">
                            <div class="card-body">
                                <i class="fas fa-money-bill-wave text-success"></i>
                                <p>No income transactions yet</p>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="card">
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="transaction-table">
                                        <thead>
                                            <tr>
                                                <th>Amount</th>
                                                <th>Mode</th>
                                                <th>Description</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (Map<String, String> tr : incomes) { %>
                                                <tr class="income-row">
                                                    <td class="amount-cell income-amount">Rs. <%= tr.get("amount") %></td>
                                                    <td><span class="badge bg-light text-dark"><%= tr.get("mode") %></span></td>
                                                    <td><%= tr.get("desc") %></td>
                                                    <td>
                                                        <div class="action-buttons">
                                                            <form action="DeleteTransactionServlet" method="post" class="d-inline">
                                                                <input type="hidden" name="transactionId" value="<%= tr.get("id") %>">
                                                                <input type="hidden" name="fileId" value="<%= fileId %>">
                                                                <button type="submit" class="btn btn-sm btn-danger">
                                                                    <i class="fas fa-trash"></i>
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Expense Section -->
            <div class="col-md-6">
                <div class="transaction-section">
                    <div class="section-header">
                        <h3 class="section-title"><i class="fas fa-arrow-up text-danger me-2"></i>Expense Transactions</h3>
                        <span class="badge bg-danger"><%= expenses.size() %> records</span>
                    </div>
                    
                    <% if (expenses.isEmpty()) { %>
                        <div class="card empty-state">
                            <div class="card-body">
                                <i class="fas fa-shopping-cart text-danger"></i>
                                <p>No expense transactions yet</p>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="card">
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="transaction-table">
                                        <thead>
                                            <tr>
                                                <th>Amount</th>
                                                <th>Mode</th>
                                                <th>Description</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (Map<String, String> tr : expenses) { %>
                                                <tr class="expense-row">
                                                    <td class="amount-cell expense-amount">Rs. <%= tr.get("amount") %></td>
                                                    <td><span class="badge bg-light text-dark"><%= tr.get("mode") %></span></td>
                                                    <td><%= tr.get("desc") %></td>
                                                    <td>
                                                        <div class="action-buttons">
                                                            <form action="DeleteTransactionServlet" method="post" class="d-inline">
                                                                <input type="hidden" name="transactionId" value="<%= tr.get("id") %>">
                                                                <input type="hidden" name="fileId" value="<%= fileId %>">
                                                                <button type="submit" class="btn btn-sm btn-danger">
                                                                    <i class="fas fa-trash"></i>
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Confirmation for delete action
        document.addEventListener('DOMContentLoaded', function() {
            const deleteForms = document.querySelectorAll('form[action="DeleteTransactionServlet"]');
            
            deleteForms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    if (!confirm('Are you sure you want to delete this transaction?')) {
                        e.preventDefault();
                    }
                });
            });
        });
    </script>
</body>
</html>