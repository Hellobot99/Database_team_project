<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>

<%
    String userId = (String) session.getAttribute("userId");
    String auctionIdStr = request.getParameter("auctionId");

    if (userId == null || auctionIdStr == null || !auctionIdStr.matches("\\d+")) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }

    int auctionId = Integer.parseInt(auctionIdStr);

    Connection conn = null;
    PreparedStatement psAuctionLock = null;
    PreparedStatement psInfo = null;
    PreparedStatement psNullInv = null;
    PreparedStatement psDeleteInv = null;
    PreparedStatement psGive = null;
    PreparedStatement psFlag = null;
    ResultSet rsAuc = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        /* 1) AUCTION 고정 잠금 */
        String sqlLockAuction =
            "SELECT SellerID, EndTime, ReceivedFlag, RegisterInventoryID " +
            "FROM AUCTION WHERE AuctionID = ? FOR UPDATE";

        psAuctionLock = conn.prepareStatement(sqlLockAuction);
        psAuctionLock.setInt(1, auctionId);
        rsAuc = psAuctionLock.executeQuery();

        String sellerId = null;
        Timestamp endTime = null;
        int receivedFlag = 0;
        int sellerInvenId = 0;

        if (rsAuc.next()) {
            sellerId = rsAuc.getString("SellerID");
            endTime = rsAuc.getTimestamp("EndTime");
            receivedFlag = rsAuc.getInt("ReceivedFlag");
            sellerInvenId = rsAuc.getInt("RegisterInventoryID");
        } else {
            conn.rollback();
            out.println("<script>alert('존재하지 않는 경매입니다.'); history.back();</script>");
            return;
        }
        rsAuc.close();

        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (endTime.after(now)) {
            conn.rollback();
            out.println("<script>alert('경매가 아직 종료되지 않았습니다.'); history.back();</script>");
            return;
        }

        if (receivedFlag == 1) {
            conn.rollback();
            out.println("<script>alert('이미 수령된 아이템입니다.'); history.back();</script>");
            return;
        }

        /* 2) 우승 입찰자 + 아이템 정보 조회 */
        String sqlInfo =
            "SELECT B.BidderID, A.ItemID, INV.Conditions " +
            "FROM AUCTION A " +
            "JOIN BIDDING_RECORD B ON A.AuctionID = B.AuctionID " +
            "JOIN INVENTORY INV ON A.RegisterInventoryID = INV.InventoryID " +
            "WHERE A.AuctionID = ? " +
            "ORDER BY B.BidAmount DESC, B.BidTime ASC FETCH FIRST 1 ROWS ONLY";

        psInfo = conn.prepareStatement(sqlInfo);
        psInfo.setInt(1, auctionId);
        rs = psInfo.executeQuery();

        if (!rs.next()) {
            conn.rollback();
            out.println("<script>alert('입찰 기록이 없어 수령할 수 없습니다.'); history.back();</script>");
            return;
        }

        String bidderId = rs.getString("BidderID");
        int itemId = rs.getInt("ItemID");
        String condition = rs.getString("Conditions");

        if (!userId.equals(bidderId)) {
            conn.rollback();
            out.println("<script>alert('낙찰자가 아닙니다.'); history.back();</script>");
            return;
        }

        rs.close();
        psInfo.close();

        /* 3) AUCTION.RegisterInventoryID 를 먼저 NULL 처리 (FK 충돌 방지 핵심) */
        psNullInv = conn.prepareStatement(
            "UPDATE AUCTION SET RegisterInventoryID = NULL WHERE AuctionID = ?"
        );
        psNullInv.setInt(1, auctionId);
        psNullInv.executeUpdate();

        /* 4) 판매자 인벤토리 삭제 */
        psDeleteInv = conn.prepareStatement(
            "DELETE FROM INVENTORY WHERE InventoryID = ?"
        );
        psDeleteInv.setInt(1, sellerInvenId);
        psDeleteInv.executeUpdate();

        /* 5) 새 인벤토리를 낙찰자에게 지급 */
        psGive = conn.prepareStatement(
            "INSERT INTO INVENTORY (InventoryID, UserID, ItemID, Quantity, Conditions, Acquired_Date) " +
            "VALUES (INVENTORY_SEQ.NEXTVAL, ?, ?, 1, ?, SYSDATE)"
        );
        psGive.setString(1, userId);
        psGive.setInt(2, itemId);
        psGive.setString(3, condition);
        psGive.executeUpdate();

        /* 6) 수령 플래그 체크 */
        psFlag = conn.prepareStatement(
            "UPDATE AUCTION SET ReceivedFlag = 1 WHERE AuctionID = ?"
        );
        psFlag.setInt(1, auctionId);
        psFlag.executeUpdate();

        conn.commit();
        out.println("<script>alert('아이템 수령 완료! 인벤토리를 확인하세요.'); location.href='my_history.jsp';</script>");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ignore) {}
        e.printStackTrace();
        out.println("<script>alert('오류 발생. 잠시 후 다시 시도해주세요.'); history.back();</script>");

    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignore) {}
        try { if (psInfo != null) psInfo.close(); } catch (Exception ignore) {}
        try { if (psNullInv != null) psNullInv.close(); } catch (Exception ignore) {}
        try { if (psDeleteInv != null) psDeleteInv.close(); } catch (Exception ignore) {}
        try { if (psGive != null) psGive.close(); } catch (Exception ignore) {}
        try { if (psFlag != null) psFlag.close(); } catch (Exception ignore) {}
        try { if (psAuctionLock != null) psAuctionLock.close(); } catch (Exception ignore) {}
        try {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        } catch (Exception ignore) {}
    }
%>
