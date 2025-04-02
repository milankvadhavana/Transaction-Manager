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
import java.sql.ResultSet; // Add this import

@WebServlet("/DeleteTransactionServlet")
public class DeleteTransactionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String mobile = (String) session.getAttribute("mobile");

        if (mobile == null) {
            response.sendRedirect("login.html");
            return;
        }

        int transactionId = Integer.parseInt(request.getParameter("transactionId"));

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");

            // Get the transaction details before deleting
            String getTransactionQuery = "SELECT type, amount, mode FROM transaction_history WHERE id = ? AND mobile = ?";
            PreparedStatement ps = con.prepareStatement(getTransactionQuery);
            ps.setInt(1, transactionId);
            ps.setString(2, mobile);
            ResultSet rs = ps.executeQuery(); // This line requires the ResultSet import

            if (rs.next()) {
                String type = rs.getString("type");
                double amount = rs.getDouble("amount");
                String mode = rs.getString("mode");

                // Adjust the balance
                String balanceColumn = mode.equals("Cash") ? "cash_balance" : "online_balance";
                String updateBalanceQuery = "UPDATE user_credentials SET " + balanceColumn + " = " + balanceColumn + " + ? WHERE mobile = ?";
                PreparedStatement ps2 = con.prepareStatement(updateBalanceQuery);
                ps2.setDouble(1, type.equals("IN") ? -amount : amount); // Reverse the transaction
                ps2.setString(2, mobile);
                ps2.executeUpdate();
            }

            // Delete the transaction
            String deleteQuery = "DELETE FROM transaction_history WHERE id = ? AND mobile = ?";
            PreparedStatement ps3 = con.prepareStatement(deleteQuery);
            ps3.setInt(1, transactionId);
            ps3.setString(2, mobile);
            ps3.executeUpdate();

            con.close();

            // Redirect back to the dashboard
            response.sendRedirect("dashboard.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}