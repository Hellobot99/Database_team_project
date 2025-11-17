<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");
    String userId = (String) session.getAttribute("loggedInUserId");
    
    String newName = request.getParameter("name");
    String newPassword = request.getParameter("password"); 

    if (userId == null || newName == null || newPassword == null) {
        response.sendRedirect("login.html");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    String sql = "UPDATE USERS SET Name = ?, Password = ? WHERE UserID = ?";

    try {
    	conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql);
        
        pstmt.setString(1, newName);
        pstmt.setString(2, newPassword);
        pstmt.setString(3, userId);

        int affectedRows = pstmt.executeUpdate();

        if (affectedRows > 0) {
            session.setAttribute("loggedInName", newName);
            
            out.println("<script>");
            out.println("alert('회원정보가 성공적으로 변경되었습니다.');");
            out.println("location.href='myProfile.jsp';");
            out.println("</script>");
        } else {
            out.println("<script>");
            out.println("alert('정보 변경에 실패했습니다.');");
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