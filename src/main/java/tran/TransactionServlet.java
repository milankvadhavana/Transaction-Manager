package tran;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Timestamp;

@WebServlet("/TransactionServlet")
public class TransactionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String mobile = (String) session.getAttribute("mobile");
        if (mobile == null) {
            response.sendRedirect("login.html");
            return;
        }

        // Get form parameters
        String type = request.getParameter("type");
        double amount = Double.parseDouble(request.getParameter("amount"));
        String mode = request.getParameter("mode");
        String description = request.getParameter("description");
        String fileIdParam = request.getParameter("fileId");

        try {
            int fileId = Integer.parseInt(fileIdParam);
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");

            // Update user balance (global balance)
            String balanceColumn = mode.equals("Cash") ? "cash_balance" : "online_balance";
            String updateBalanceQuery = "UPDATE user_credentials SET " + balanceColumn + " = " 
                + balanceColumn + " + ? WHERE mobile = ?";
            try (PreparedStatement ps = con.prepareStatement(updateBalanceQuery)) {
                ps.setDouble(1, type.equals("IN") ? amount : -amount);
                ps.setString(2, mobile);
                ps.executeUpdate();
            }

            // Insert transaction with file reference
            String insertTransactionQuery = "INSERT INTO transaction_history "
                + "(mobile, file_id, transaction_date, type, amount, mode, description, is_spending) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement ps2 = con.prepareStatement(insertTransactionQuery)) {
                ps2.setString(1, mobile);
                ps2.setInt(2, fileId);
                ps2.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
                ps2.setString(4, type);
                ps2.setDouble(5, amount);
                ps2.setString(6, mode);
                ps2.setString(7, description);
                ps2.setBoolean(8, type.equals("OUT"));
                ps2.executeUpdate();
            }

            con.close();
            response.sendRedirect("dashboard.jsp?fileId=" + fileId);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("error.jsp?message=Invalid file ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp?message=Database error");
        }
    }
}