<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>

<%
    String userId = (String) session.getAttribute("userId");
    request.setCharacterEncoding("UTF-8");

    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }

    String password = request.getParameter("password");

    Connection conn = null;
    PreparedStatement pstmt = null;

    String sql = "DELETE FROM USERS WHERE UserID = ? AND Password = ?";

    try {
        conn = DBConnection.getConnection();
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        pstmt.setString(2, password);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            session.invalidate();
            out.println("<script>alert('회원 탈퇴 완료!'); location.href='index.jsp';</script>");
        } else {
            out.println("<script>alert('비밀번호가 일치하지 않습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        out.println("<h2>DB 오류</h2>" + e.getMessage());
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
