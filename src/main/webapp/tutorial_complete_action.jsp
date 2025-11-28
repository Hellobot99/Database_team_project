<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%
    String userId = (String) session.getAttribute("userId");
    String userTier = (String) session.getAttribute("userTier"); // 세션에서 현재 등급 확인

    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }

    if (!"ROOKIE".equals(userTier)) {
        out.println("<script>");
        out.println("alert('이미 튜토리얼 보상을 받으셨습니다. 로비로 이동합니다.');");
        out.println("location.href='index.jsp';");
        out.println("</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBConnection.getConnection();
        
        String sql = "UPDATE USERS SET Balance = Balance + 10000, Tier = 'Bronze' WHERE UserID = ? AND Tier = 'ROOKIE'";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        
        int result = pstmt.executeUpdate();

        if (result > 0) {
            session.setAttribute("userTier", "Bronze");
            
            out.println("<script>");
            out.println("alert('🎉 축하합니다! 튜토리얼 완료 보상 10,000 G가 지급되었습니다.\\n등급이 [Bronze]로 승급되었습니다!');");
            out.println("location.href='index.jsp';");
            out.println("</script>");
        } else {
            out.println("<script>alert('보상 지급 중 문제가 발생했거나 이미 수령했습니다.'); location.href='index.jsp';</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage() + "'); location.href='index.jsp';</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>