package tran;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@SuppressWarnings("serial")
@WebServlet("/DeleteFileServlet")
public class DeleteFileServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String fileId = request.getParameter("fileId");
        String mobile = (String) request.getSession().getAttribute("mobile");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");
            
            // Delete related transactions first
            PreparedStatement ps1 = con.prepareStatement(
                "DELETE FROM transaction_history WHERE file_id = ?");
            ps1.setInt(1, Integer.parseInt(fileId));
            ps1.executeUpdate();
            
            // Delete the file
            PreparedStatement ps2 = con.prepareStatement(
                "DELETE FROM user_files WHERE id = ? AND mobile = ?");
            ps2.setInt(1, Integer.parseInt(fileId));
            ps2.setString(2, mobile);
            ps2.executeUpdate();
            
            con.close();
            response.sendRedirect("index.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=Error deleting file");
        }
    }
}