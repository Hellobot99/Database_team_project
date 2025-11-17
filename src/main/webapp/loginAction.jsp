<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="TeamPrj.DBConnection" %>

<%
    request.setCharacterEncoding("UTF-8");

    String userID = request.getParameter("userID");
    String password = request.getParameter("password");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String sql = "SELECT UserID, Name, Tier FROM USERS WHERE UserID = ? AND Password = ?";

    try {
        conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userID);
        pstmt.setString(2, password);
        
        rs = pstmt.executeQuery();

        if (rs.next()) {
            session.setAttribute("userId", rs.getString("UserID"));
            session.setAttribute("userName", rs.getString("Name"));
            session.setAttribute("userTier", rs.getString("Tier")); // ★ Tier 정보 저장
            
            response.sendRedirect("index.jsp");
        } else {
            out.println("<script>");
            out.println("alert('아이디 또는 비밀번호가 일치하지 않습니다.');");
            out.println("history.back();");
            out.println("</script>");
        }

    } catch (Exception e) {
        out.println("<h2>DB 오류</h2><p>" + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>