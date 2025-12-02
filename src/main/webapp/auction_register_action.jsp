<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>

<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.html"); return; }
    String invenIdStr = request.getParameter("invenId");
    String startPriceStr = request.getParameter("startPrice");
    String durationStr = request.getParameter("durationHours");

    if(invenIdStr == null || startPriceStr == null || durationStr == null ||
       invenIdStr.trim().isEmpty() || startPriceStr.trim().isEmpty() || durationStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다. (입력 누락)'); history.back();</script>");
        return;
    }
    if(!invenIdStr.matches("\\d+") || !startPriceStr.matches("\\d+") || !durationStr.matches("\\d+")) {
        out.println("<script>alert('입력값은 숫자만 가능합니다.'); history.back();</script>");
        return;
    }

    int invenId = Integer.parseInt(invenIdStr);
    long startPrice = Long.parseLong(startPriceStr);
    int duration = Integer.parseInt(durationStr);

    if(startPrice <= 0) {
        out.println("<script>alert('시작 가격은 1 이상이어야 합니다.'); history.back();</script>");
        return;
    }

    if(duration <= 0) {
        out.println("<script>alert('경매 기간은 1시간 이상이어야 합니다.'); history.back();</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement psLockInv = null;
    PreparedStatement psDeduct = null;
    PreparedStatement psInsert = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);
        String sqlLock =
            "SELECT ItemID, Quantity FROM INVENTORY WHERE InventoryID = ? AND UserID = ? FOR UPDATE";

        psLockInv = conn.prepareStatement(sqlLock);
        psLockInv.setInt(1, invenId);
        psLockInv.setString(2, userId);
        rs = psLockInv.executeQuery();

        int realItemId = 0;
        int qty = 0;

        if (rs.next()) {
            realItemId = rs.getInt("ItemID");
            qty = rs.getInt("Quantity");

            if (qty <= 0) {
                conn.rollback();
                out.println("<script>alert('아이템 수량이 부족합니다.'); history.back();</script>");
                return;
            }
        } else {
            conn.rollback();
            out.println("<script>alert('존재하지 않는 아이템입니다.'); history.back();</script>");
            return;
        }
        rs.close();
        String sqlUpdateInv =
            "UPDATE INVENTORY SET Quantity = Quantity - 1 WHERE InventoryID = ? AND Quantity > 0";

        psDeduct = conn.prepareStatement(sqlUpdateInv);
        psDeduct.setInt(1, invenId);

        int updated = psDeduct.executeUpdate();
        if(updated == 0){
            conn.rollback();
            out.println("<script>alert('아이템 차감 중 오류가 발생했습니다.'); history.back();</script>");
            return;
        }
        String sqlInsert =
            "INSERT INTO AUCTION " +
            "(AUCTIONID, START_PRICE, STARTTIME, ENDTIME, CURRENTHIGHESTPRICE, ITEMID, SELLERID, REGISTERINVENTORYID) " +
            "VALUES (AUCTION_SEQ.NEXTVAL, ?, SYSDATE, SYSDATE + (?/24), ?, ?, ?, ?)";

        psInsert = conn.prepareStatement(sqlInsert);
        psInsert.setLong(1, startPrice);
        psInsert.setInt(2, duration);
        psInsert.setLong(3, startPrice);
        psInsert.setInt(4, realItemId);
        psInsert.setString(5, userId);
        psInsert.setInt(6, invenId);
        psInsert.executeUpdate();

        conn.commit();

        out.println("<script>alert('경매 등록이 완료되었습니다!'); location.href='show_my_registered_item_list_action.jsp';</script>");

    } catch(SQLException se) {
        try{ if(conn != null) conn.rollback(); } catch(Exception ignore) {}

        if (se.getErrorCode() == 1) {
            out.println("<script>alert('등록 요청이 많아 실패했습니다. 다시 시도해주세요.'); history.back();</script>");
        } else {
            log("Auction Register SQL Error: " + se.getMessage(), se);
            out.println("<script>alert('DB 오류가 발생했습니다.'); history.back();</script>");
        }

    } catch(Exception e) {
        try{ if(conn != null) conn.rollback(); } catch(Exception ignore) {}
        log("Auction Register Error: " + e.getMessage(), e);
        out.println("<script>alert('오류가 발생했습니다.'); history.back();</script>");

    } finally {
        try{if(rs!=null) rs.close();}catch(Exception ignore){}
        try{if(psLockInv!=null) psLockInv.close();}catch(Exception ignore){}
        try{if(psDeduct!=null) psDeduct.close();}catch(Exception ignore){}
        try{if(psInsert!=null) psInsert.close();}catch(Exception ignore){}
        try{
            if(conn!=null){
                conn.setAutoCommit(true);
                conn.close();
            }
        }catch(Exception ignore){}
    }
%>
