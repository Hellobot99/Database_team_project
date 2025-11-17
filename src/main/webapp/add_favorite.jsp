<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }

    long auctionId = Long.parseLong(request.getParameter("auctionId"));

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        conn = DBConnection.getConnection();
        ps = conn.prepareStatement("INSERT INTO FAVORITE (UserID, AuctionID) VALUES (?, ?)");
        ps.setString(1, userId);
        ps.setLong(2, auctionId);
        ps.executeUpdate();

        out.println("<script>");
        out.println("alert('즐겨찾기에 추가되었습니다.');");
        out.println("location.href='auction_list.jsp';");
        out.println("</script>");

    } catch (Exception e) {
        out.println("<script>");
        out.println("alert('이미 즐겨찾기한 경매입니다.');");
        out.println("location.href='auction_list.jsp';");
        out.println("</script>");
    } finally {	
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
%>
