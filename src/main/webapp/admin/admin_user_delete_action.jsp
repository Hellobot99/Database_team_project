<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<%
    String userID_to_delete = request.getParameter("userID");

    String loggedInAdmin = (String) session.getAttribute("loggedInUserId");
    if (userID_to_delete.equals(loggedInAdmin)) {
        response.sendRedirect("admin_user_manage.jsp?message=error_self_delete");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    String sql = "DELETE FROM USERS WHERE UserID = ?";

    try {
    	conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userID_to_delete);
        
        pstmt.executeUpdate();
        
        response.sendRedirect("admin_user_manage.jsp?message=delete_success");

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("admin_user_manage.jsp?message=error");
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>