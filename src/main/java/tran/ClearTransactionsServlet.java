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

@WebServlet("/ClearTransactionsServlet")
public class ClearTransactionsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String mobile = (String) session.getAttribute("mobile");

        if (mobile == null) {
            response.sendRedirect("login.html");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");

            // Delete all transactions for the user
            String deleteQuery = "DELETE FROM transaction_history WHERE mobile = ?";
            PreparedStatement ps = con.prepareStatement(deleteQuery);
            ps.setString(1, mobile);
            ps.executeUpdate();

            // Reset balances to zero
            String resetBalanceQuery = "UPDATE user_credentials SET cash_balance = 0, online_balance = 0 WHERE mobile = ?";
            PreparedStatement ps2 = con.prepareStatement(resetBalanceQuery);
            ps2.setString(1, mobile);
            ps2.executeUpdate();

            con.close();

            // Redirect back to the dashboard
            response.sendRedirect("dashboard.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
