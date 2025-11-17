<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
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
        ps = conn.prepareStatement("DELETE FROM FAVORITE WHERE UserID = ? AND AuctionID = ?");
        ps.setString(1, userId);
        ps.setLong(2, auctionId);

        ps.executeUpdate();

        out.println("<script>");
        out.println("alert('즐겨찾기에서 제거되었습니다.');");
        out.println("location.href='favorite_list.jsp';");
        out.println("</script>");

    } catch (Exception e) {
        out.println("오류 발생: " + e.getMessage());
    } finally {
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
%>
