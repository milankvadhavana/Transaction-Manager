package tran;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/RegistrationServlet")
public class RegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String mobile = request.getParameter("mobile");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String country = request.getParameter("country");
        String password = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");

            // Check if mobile number already exists
            PreparedStatement checkStmt = con.prepareStatement("SELECT * FROM user_credentials WHERE mobile = ?");
            checkStmt.setString(1, mobile);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                // Mobile number already exists
                response.sendRedirect("register.html?error=Mobile number already registered");
            } else {
                // Insert new user
                PreparedStatement ps = con.prepareStatement("INSERT INTO user_credentials VALUES(?,?,?,?,?,?,?,0,0)");
                ps.setString(1, mobile);
                ps.setString(2, name);
                ps.setString(3, email);
                ps.setString(4, city);
                ps.setString(5, state);
                ps.setString(6, country);
                ps.setString(7, password);

                int i = ps.executeUpdate();
                if (i > 0) {
                    response.sendRedirect("login.html");
                }
            }

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.html?error=An error occurred. Please try again.");
        }
    }
}