<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");
    String userID = request.getParameter("userID");
    String name = request.getParameter("name");
    String password = request.getParameter("password");
    String tier = request.getParameter("tier");
    long balance = Long.parseLong(request.getParameter("balance"));
    
    Connection conn = null;
    PreparedStatement pstmt = null;

    String sql = "UPDATE USERS SET Name = ?, Password = ?, Tier = ?, Balance = ? WHERE UserID = ?";

    try {
    	conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, name);
        pstmt.setString(2, password);
        pstmt.setString(3, tier);
        pstmt.setLong(4, balance);
        pstmt.setString(5, userID);
        
        pstmt.executeUpdate();
        
        response.sendRedirect("admin_user_manage.jsp?message=update_success");

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("admin_user_manage.jsp?message=error");
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>