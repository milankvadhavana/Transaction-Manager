package tran;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@SuppressWarnings("serial")
@WebServlet("/CreateFileServlet")
public class CreateFileServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String fileName = request.getParameter("fileName");
        String mobile = (String) request.getSession().getAttribute("mobile");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");
            
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO user_files (mobile, file_name) VALUES (?, ?)");
            ps.setString(1, mobile);
            ps.setString(2, fileName);
            ps.executeUpdate();
            
            con.close();
            response.sendRedirect("index.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=Error creating file");
        }
    }
}