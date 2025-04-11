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

@WebServlet("/AddFileServlet")
public class AddFileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String email = (String) session.getAttribute("email");
        String filename = request.getParameter("filename");

        if (email == null || filename == null || filename.trim().isEmpty()) {
            response.sendRedirect("error.jsp");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/TransactionDB", "root", "9016");

            PreparedStatement pst = con.prepareStatement(
                "INSERT INTO transaction_file (email, filename) VALUES (?, ?)");
            pst.setString(1, email);
            pst.setString(2, filename);
            pst.executeUpdate();

            response.sendRedirect("index.jsp");

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
