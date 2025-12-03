<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
Connection conn = null;
PreparedStatement psAuctionLock = null;
PreparedStatement psDeduct     = null;
PreparedStatement psRefund     = null;
PreparedStatement psUpdateAuc  = null;
PreparedStatement psInsertBid  = null;
PreparedStatement psCheckTop   = null;

ResultSet rsAuction = null;
ResultSet rsTop     = null;

try {
    String userId = (String) session.getAttribute("userId");
    if (userId == null || userId.trim().isEmpty()) {
        response.sendRedirect("login.html");
        return;
    }
    
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        out.println("<script>");
        out.println("alert('잘못된 접근입니다. (POST 메소드만 허용)');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    String auctionIdParam = request.getParameter("auctionId");
    String amountParam    = request.getParameter("amount");

    if (auctionIdParam == null || amountParam == null ||
        auctionIdParam.trim().isEmpty() || amountParam.trim().isEmpty()) {
        out.println("<script>");
        out.println("alert('요청 파라미터가 올바르지 않습니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    if (!auctionIdParam.matches("\\d+") || !amountParam.matches("\\d+")) {
        out.println("<script>");
        out.println("alert('잘못된 입찰 요청입니다. (숫자가 아닌 값 포함)');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    long auctionId = Long.parseLong(auctionIdParam);
    long amount    = Long.parseLong(amountParam);

    if (amount <= 0) {
        out.println("<script>");
        out.println("alert('입찰 금액은 1원 이상이어야 합니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    conn = DBConnection.getConnection();
    conn.setAutoCommit(false);
    psAuctionLock = conn.prepareStatement(
        "SELECT SellerID, Start_Price, CurrentHighestPrice, EndTime " +
        "FROM AUCTION WHERE AuctionID = ? FOR UPDATE"
    );
    psAuctionLock.setLong(1, auctionId);
    rsAuction = psAuctionLock.executeQuery();

    String sellerId = null;
    long startPrice = 0L;
    long currentHighestPrice = 0L;
    java.sql.Timestamp endTime = null;

    if (rsAuction.next()) {
        sellerId            = rsAuction.getString("SellerID");
        startPrice          = rsAuction.getLong("Start_Price");
        currentHighestPrice = rsAuction.getLong("CurrentHighestPrice");
        endTime             = rsAuction.getTimestamp("EndTime");
    } else {
        conn.rollback();
        out.println("<script>");
        out.println("alert('존재하지 않는 경매입니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }
    java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
    if (endTime != null && !endTime.after(now)) {
        conn.rollback();
        out.println("<script>");
        out.println("alert('이미 마감된 경매입니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    if (userId.equals(sellerId)) {
        conn.rollback();
        out.println("<script>");
        out.println("alert('본인이 등록한 물품에는 입찰할 수 없습니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    long minimumBid = (currentHighestPrice > 0) ? currentHighestPrice + 1 : startPrice;
    
    if (amount < minimumBid) {
        conn.rollback();
        out.println("<script>");
        out.println("alert('입찰 금액은 최소 " + minimumBid + " G 이상이어야 합니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    String sqlDeduct =
        "UPDATE USERS " +
        "SET Balance = Balance - ? " +
        "WHERE UserID = ? AND Balance >= ?";

    psDeduct = conn.prepareStatement(sqlDeduct);
    psDeduct.setLong(1, amount);
    psDeduct.setString(2, userId);
    psDeduct.setLong(3, amount);

    int deducted = psDeduct.executeUpdate();
    if (deducted == 0) {
        conn.rollback();
        out.println("<script>");
        out.println("alert('잔액이 부족하여 입찰할 수 없습니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    String sqlCheckTop =
        "SELECT BidderID, BidAmount " +
        "FROM BIDDING_RECORD " +
        "WHERE AuctionID = ? " +
        "ORDER BY BidAmount DESC, BidTime ASC " +
        "FETCH FIRST 1 ROWS ONLY";

    psCheckTop = conn.prepareStatement(sqlCheckTop);
    psCheckTop.setLong(1, auctionId);
    rsTop = psCheckTop.executeQuery();

    String prevBidderId = null;
    long prevBidAmount  = 0L;

    if (rsTop.next()) {
        prevBidderId = rsTop.getString("BidderID");
        prevBidAmount = rsTop.getLong("BidAmount");
    }

    if (prevBidderId != null && !prevBidderId.equals(userId)) {
        String sqlRefund =
            "UPDATE USERS " +
            "SET Balance = Balance + ? " +
            "WHERE UserID = ?";
        psRefund = conn.prepareStatement(sqlRefund);
        psRefund.setLong(1, prevBidAmount);
        psRefund.setString(2, prevBidderId);

        int refunded = psRefund.executeUpdate();
        if (refunded == 0) {
            conn.rollback();
            out.println("<script>");
            out.println("alert('이전 최고 입찰자 환불 처리 중 오류가 발생했습니다.');");
            out.println("history.back();");
            out.println("</script>");
            return;
        }
    }

    psUpdateAuc = conn.prepareStatement(
        "UPDATE AUCTION " +
        "SET CurrentHighestPrice = ? " +
        "WHERE AuctionID = ?"
    );
    psUpdateAuc.setLong(1, amount);
    psUpdateAuc.setLong(2, auctionId);

    int aucUpdated = psUpdateAuc.executeUpdate();
    if (aucUpdated == 0) {
        conn.rollback();
        out.println("<script>");
        out.println("alert('경매 정보 갱신 중 오류가 발생했습니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    // ========== 8. 입찰 기록 추가 ==========
    psInsertBid = conn.prepareStatement(
        "INSERT INTO BIDDING_RECORD (AuctionID, BidderID, BidAmount, BidTime) " +
        "VALUES (?, ?, ?, ?)"
    );
    psInsertBid.setLong(1, auctionId);
    psInsertBid.setString(2, userId);
    psInsertBid.setLong(3, amount);
    psInsertBid.setTimestamp(4, now);
    psInsertBid.executeUpdate();

    conn.commit();

    out.println("<script>");
    out.println("alert('입찰 성공!');");
    out.println("location.href='auction_list.jsp';");
    out.println("</script>");

} catch (Exception e) {
    if (conn != null) {
        try { conn.rollback(); } catch (Exception ignore) {}
    }
    log("Bidding Error: " + e.getMessage(), e);
    out.println("<script>");
    out.println("alert('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');");
    out.println("history.back();");
    out.println("</script>");

} finally {
    try { if (rsTop     != null) rsTop.close();     } catch (Exception ignore) {}
    try { if (rsAuction != null) rsAuction.close(); } catch (Exception ignore) {}
    try { if (psInsertBid   != null) psInsertBid.close();   } catch (Exception ignore) {}
    try { if (psUpdateAuc   != null) psUpdateAuc.close();   } catch (Exception ignore) {}
    try { if (psRefund      != null) psRefund.close();      } catch (Exception ignore) {}
    try { if (psDeduct      != null) psDeduct.close();      } catch (Exception ignore) {}
    try { if (psCheckTop    != null) psCheckTop.close();    } catch (Exception ignore) {}
    try { if (psAuctionLock != null) psAuctionLock.close(); } catch (Exception ignore) {}
    try {
        if (conn != null) {
            conn.setAutoCommit(true);
            conn.close();
        }
    } catch (Exception ignore) {}
}
%>