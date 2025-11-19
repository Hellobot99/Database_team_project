<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="admin_check.jsp" %>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");
    String userID = request.getParameter("userID");
    String password = request.getParameter("password");
    String name = request.getParameter("name");
    String tier = request.getParameter("tier");
    
    Connection conn = null;
    PreparedStatement pstmt = null;

    String sql = "INSERT INTO USERS (UserID, Password, Name, Tier, Balance) VALUES (?, ?, ?, ?, 0)";

    try {
    	conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userID);
        pstmt.setString(2, password);
        pstmt.setString(3, name);
        pstmt.setString(4, tier);
        
        pstmt.executeUpdate();
        
        response.sendRedirect("admin_user_manage.jsp?message=create_success");

    } catch (SQLException se) {
        response.sendRedirect("admin_user_manage.jsp?message=error_" + se.getErrorCode());
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>