<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String) session.getAttribute("loggedInUserId");
    
    String password = request.getParameter("password"); 

    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }

    String serverIP = "localhost";
    String strSID = "orcl"; 
    String portNum = "1521";
    String user = "DBA_PROJECT";
    String pass = "1234";
    String url = "jdbc:oracle:thin:@"+serverIP+":"+portNum+":"+strSID;

    Connection conn = null;
    PreparedStatement pstmt = null;

    String sql = "DELETE FROM USERS WHERE UserID = ? AND Password = ?";

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(url, user, pass);
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        pstmt.setString(2, password);

        int affectedRows = pstmt.executeUpdate();

        if (affectedRows > 0) {
            session.invalidate();
            
            out.println("<script>");
            out.println("alert('회원 탈퇴가 완료되었습니다.');");
            out.println("location.href='index.jsp';");
            out.println("</script>");
        } else {
            out.println("<script>");
            out.println("alert('비밀번호가 일치하지 않습니다.');");
            out.println("history.back();");
            out.println("</script>");
        }

    } catch (Exception e) {
        out.println("<h2>DB 오류</h2><p>" + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>