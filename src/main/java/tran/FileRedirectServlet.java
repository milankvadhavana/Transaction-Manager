package tran;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/FileRedirectServlet")
public class FileRedirectServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String fileName = request.getParameter("filename");

        if (fileName != null && !fileName.isEmpty()) {
            session.setAttribute("filename", fileName);
            response.sendRedirect("dashboard.jsp");
        } else {
            response.sendRedirect("error.jsp");  // handle invalid access
        }
    }
}
