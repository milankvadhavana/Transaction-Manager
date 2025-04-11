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
import java.sql.ResultSet;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String mobile = request.getParameter("mobile");
        String password = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");

            PreparedStatement ps = con.prepareStatement("SELECT name, email FROM user_credentials WHERE mobile = ? AND password = ?");
            ps.setString(1, mobile);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("mobile", mobile);
                session.setAttribute("name", rs.getString("name"));
                session.setAttribute("email", rs.getString("email")); // 💡 Save email for further use
                response.sendRedirect("index.jsp");  // ✅ Redirect to index.jsp after successful login
            } else {
                response.sendRedirect("login.html?error=Invalid mobile number or password");
            }

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.html?error=An error occurred. Please try again.");
        }
    }
}
