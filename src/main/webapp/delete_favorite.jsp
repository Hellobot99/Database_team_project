<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='login.html';</script>");
        return;
    }

    String auctionIdStr = request.getParameter("auctionId");
    if (auctionIdStr == null || auctionIdStr.isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }

    int auctionId = Integer.parseInt(auctionIdStr);

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBConnection.getConnection();
        
        String sql = "DELETE FROM FAVORITE WHERE UserID = ? AND AuctionID = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        pstmt.setInt(2, auctionId);
        
        int result = pstmt.executeUpdate();
        
        if (result > 0) {
            out.println("<script>alert('관심 목록에서 삭제되었습니다.'); location.href='myAuction.jsp';</script>");
        } else {
            out.println("<script>alert('삭제할 내역이 없거나 이미 삭제되었습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "") + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>