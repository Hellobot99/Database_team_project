<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.html"); return; }
%>

<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>경매 삭제</title></head>
<body>

<h2>:: 경매 삭제 ::</h2>

<form method="post">
    삭제할 경매 ID: <input type="number" name="auctionId"><br><br>
    <button type="submit">삭제</button>
</form>

<%
if(request.getMethod().equals("POST")) {
    long auctionId = Long.parseLong(request.getParameter("auctionId"));

    Connection conn = DBConnection.getConnection();

    // 입찰 기록 체크
    PreparedStatement check = conn.prepareStatement(
            "SELECT COUNT(*) FROM BIDDING_RECORD WHERE AUCTIONID = ?");
    check.setLong(1, auctionId);

    ResultSet r = check.executeQuery();
    r.next();

    if(r.getInt(1) > 0) {
        out.println("입찰이 이미 존재하여 삭제 불가!");
    } else {
        PreparedStatement del = conn.prepareStatement(
                "DELETE FROM AUCTION WHERE AUCTIONID = ?");
        del.setLong(1, auctionId);
        int ok = del.executeUpdate();
        out.println(ok > 0 ? "삭제 완료!" : "삭제 실패!");

        del.close();
    }

    r.close();
    check.close();
    conn.close();
}
%>

<br><a href="index.jsp">메인 메뉴</a>

</body>
</html>
