<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
try {
    // 1. 로그인 체크
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }

    // 2. 요청 방식 검사 (POST만 처리)
    if (!request.getMethod().equalsIgnoreCase("POST")) {
        out.println("요청 방식: " + request.getMethod() + "<br>");
        out.println("POST 요청이 아니라서 아무 작업도 수행하지 않았습니다.");
        return;
    }

    // 3. 파라미터 파싱
    long auctionId = Long.parseLong(request.getParameter("auctionId"));
    long amount    = Long.parseLong(request.getParameter("amount"));

    Connection conn = DBConnection.getConnection();

    // 4. 현재 최고가 조회
    PreparedStatement ps1 = conn.prepareStatement(
        "SELECT CurrentHighestPrice FROM AUCTION WHERE AuctionID = ?"
    );
    ps1.setLong(1, auctionId);
    ResultSet rs = ps1.executeQuery();

    long currentPrice = 0;
    if (rs.next()) {
        currentPrice = rs.getLong(1);
    }
    rs.close();
    ps1.close();

    // 5. 금액 검증
    if (amount <= currentPrice) {
        out.println("<script>");
        out.println("alert('입찰 실패: 현재 최고가보다 높은 금액만 입찰할 수 있습니다.');");
        out.println("history.back();");
        out.println("</script>");
        conn.close();
        return;
    }

    // 6. 입찰 기록 INSERT
    PreparedStatement ps2 = conn.prepareStatement(
        "INSERT INTO BIDDING_RECORD (AuctionID, BidderID, BidAmount, BidTime) " +
        "VALUES (?, ?, ?, SYSDATE)"
    );
    ps2.setLong(1, auctionId);
    ps2.setString(2, userId);   // ★★★★★ 여기! 숫자 변환 X, 그대로 문자열로 저장 ★★★★★
    ps2.setLong(3, amount);
    ps2.executeUpdate();
    ps2.close();

    // 7. AUCTION 현재 최고가 갱신
    PreparedStatement ps3 = conn.prepareStatement(
        "UPDATE AUCTION SET CurrentHighestPrice = ? WHERE AuctionID = ?"
    );
    ps3.setLong(1, amount);
    ps3.setLong(2, auctionId);
    ps3.executeUpdate();
    ps3.close();

    conn.close();

    // 8. 성공 메시지 후 목록으로 이동
    out.println("<script>");
    out.println("alert('입찰 성공!');");
    out.println("location.href='auction_list.jsp';");
    out.println("</script>");

} catch (Exception e) {
    out.println("<h2>오류 발생</h2>");
    out.println("<pre>");
    java.io.StringWriter sw = new java.io.StringWriter();
    java.io.PrintWriter pw = new java.io.PrintWriter(sw);
    e.printStackTrace(pw);
    out.println(sw.toString());
    out.println("</pre>");
}
%>
