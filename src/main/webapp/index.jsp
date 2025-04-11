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
        PreparedStatement pst = con.prepareStatement("SELECT id, file_name, created_at FROM user_files WHERE mobile = ?");
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
<html>
<head>
    <title>File Manager</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <style>
        .file-card { transition: transform 0.2s; }
        .file-card:hover { transform: translateY(-5px); }
    </style>
</head>
<body>
    <div class="container mt-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1>Welcome, <%= name %>!</h1>
            <div>
                <a href="LogoutServlet" class="btn btn-danger">Logout</a>
            </div>
        </div>

        <!-- Create File Card -->
        <div class="card file-card mb-4">
            <div class="card-body">
                <h5 class="card-title">Create New File</h5>
                <form action="CreateFileServlet" method="post">
                    <div class="input-group">
                        <input type="text" name="fileName" class="form-control" 
                               placeholder="Enter file name" required>
                        <button class="btn btn-success" type="submit">
                            Create
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Files Grid -->
        <div class="row row-cols-1 row-cols-md-3 g-4">
            <% for (String[] file : files) { %>
                <div class="col">
                    <div class="card file-card h-100">
                        <div class="card-body">
                            <h5 class="card-title">
                                <a href="dashboard.jsp?fileId=<%= file[0] %>" 
                                   class="text-decoration-none text-dark">
                                    <%= file[1] %>
                                </a>
                            </h5>
                            <p class="card-text text-muted small">
                                Created: <%= file[2] %>
                            </p>
                        </div>
                        <div class="card-footer">
                            <form action="DeleteFileServlet" method="post" 
                                  onsubmit="return confirm('Delete this file permanently?')" 
                                  class="d-inline">
                                <input type="hidden" name="fileId" value="<%= file[0] %>">
                                <button type="submit" class="btn btn-sm btn-danger">
                                    Delete
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>