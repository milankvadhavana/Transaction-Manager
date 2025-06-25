<%@ page import="java.sql.*, java.util.ArrayList" %>
<%@ page session="true" %>
<%
    String mobile = (String) session.getAttribute("mobile");
    String name = (String) session.getAttribute("name");
    
    if (mobile == null) {
        response.sendRedirect("login.html");
        return;
    }
    
    ArrayList<String[]> files = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");
        PreparedStatement pst = con.prepareStatement("SELECT id, file_name, created_at FROM user_files WHERE mobile = ? ORDER BY created_at DESC");
        pst.setString(1, mobile);
        ResultSet rs = pst.executeQuery();
        while (rs.next()) {
            files.add(new String[] {
                rs.getString("id"),
                rs.getString("file_name"),
                rs.getString("created_at")
            });
        }
        con.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaction Manager - Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4361ee;
            --primary-dark: #3a56d4;
            --secondary-color: #4cc9f0;
            --light-color: #f8f9fa;
            --dark-color: #212529;
            --success-color: #4bb543;
            --error-color: #ff3333;
            --border-radius: 12px;
            --box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            --transition: all 0.3s ease;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f5f7fa;
            color: var(--dark-color);
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

        .welcome-section {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            color: white;
            padding: 40px 0;
            margin-bottom: 40px;
            border-radius: 0 0 var(--border-radius) var(--border-radius);
        }

        .welcome-title {
            font-weight: 600;
            margin-bottom: 10px;
        }

        .welcome-subtitle {
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
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.15);
        }

        .card-header {
            background-color: white;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            font-weight: 600;
        }

        .file-card .card-body {
            padding: 20px;
        }

        .file-card .card-title {
            font-weight: 500;
            margin-bottom: 10px;
        }

        .file-card .card-text {
            color: #666;
            font-size: 13px;
        }

        .file-card .card-footer {
            background-color: white;
            border-top: 1px solid rgba(0, 0, 0, 0.05);
            padding: 15px 20px;
        }

        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }

        .btn-primary:hover {
            background-color: var(--primary-dark);
            border-color: var(--primary-dark);
        }

        .btn-danger {
            background-color: var(--error-color);
            border-color: var(--error-color);
        }

        .btn-outline-primary {
            color: var(--primary-color);
            border-color: var(--primary-color);
        }

        .btn-outline-primary:hover {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }

        .create-file-card {
            border: 2px dashed #ddd;
            background-color: rgba(67, 97, 238, 0.05);
            transition: var(--transition);
        }

        .create-file-card:hover {
            border-color: var(--primary-color);
            background-color: rgba(67, 97, 238, 0.1);
            transform: none;
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

        .file-icon {
            font-size: 24px;
            color: var(--primary-color);
            margin-right: 10px;
        }

        .file-actions {
            display: flex;
            gap: 10px;
        }

        .file-actions .btn {
            flex: 1;
        }

        @media (max-width: 768px) {
            .welcome-section {
                text-align: center;
                padding: 30px 0;
            }
            
            .file-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg">
        <div class="container">
            <a class="navbar-brand" href="#">
                <i class="fas fa-wallet"></i> Transaction Manager
            </a>
            <div class="d-flex align-items-center">
                <span class="me-3 d-none d-sm-inline">Welcome, <%= name %></span>
                <a href="LogoutServlet" class="btn btn-sm btn-danger">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
    </nav>

    <!-- Welcome Section -->
    <div class="welcome-section">
        <div class="container">
            <h1 class="welcome-title">Your Transaction Files</h1>
            <p class="welcome-subtitle">Manage all your financial records in one place</p>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container mb-5">
        <!-- Create File Card -->
        <div class="card create-file-card mb-4">
            <div class="card-body">
                <h5 class="card-title"><i class="fas fa-plus-circle me-2"></i>Create New File</h5>
                <form action="CreateFileServlet" method="post" class="mt-3">
                    <div class="input-group">
                        <input type="text" name="fileName" class="form-control" 
                               placeholder="Enter file name (e.g. 'January Expenses')" required>
                        <button class="btn btn-primary" type="submit">
                            <i class="fas fa-plus me-1"></i> Create
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Files Section -->
        <% if (files.isEmpty()) { %>
            <div class="card empty-state">
                <div class="card-body">
                    <i class="fas fa-folder-open"></i>
                    <h4>No Files Yet</h4>
                    <p>Create your first file to start managing transactions</p>
                </div>
            </div>
        <% } else { %>
            <h4 class="mb-3">Your Files (<%= files.size() %>)</h4>
            <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
                <% for (String[] file : files) { %>
                    <div class="col">
                        <div class="card file-card h-100">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-2">
                                    <i class="file-icon fas fa-file-alt"></i>
                                    <h5 class="card-title mb-0">
                                        <a href="dashboard.jsp?fileId=<%= file[0] %>" 
                                           class="text-decoration-none text-dark">
                                            <%= file[1] %>
                                        </a>
                                    </h5>
                                </div>
                                <p class="card-text text-muted small">
                                    <i class="far fa-calendar me-1"></i> Created: <%= file[2] %>
                                </p>
                            </div>
                            <div class="card-footer">
                                <div class="file-actions">
                                    <a href="dashboard.jsp?fileId=<%= file[0] %>" 
                                       class="btn btn-sm btn-outline-primary">
                                        <i class="fas fa-eye me-1"></i> View
                                    </a>
                                    <form action="DeleteFileServlet" method="post" 
                                          onsubmit="return confirm('Are you sure you want to delete this file? This action cannot be undone.')" 
                                          class="d-inline">
                                        <input type="hidden" name="fileId" value="<%= file[0] %>">
                                        <button type="submit" class="btn btn-sm btn-danger">
                                            <i class="fas fa-trash me-1"></i> Delete
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Confirmation for delete action
        document.addEventListener('DOMContentLoaded', function() {
            const deleteForms = document.querySelectorAll('form[action="DeleteFileServlet"]');
            
            deleteForms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    if (!confirm('Are you sure you want to delete this file? This action cannot be undone.')) {
                        e.preventDefault();
                    }
                });
            });
        });
    </script>
</body>
</html>