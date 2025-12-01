<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.html"); return; }

    String invenIdStr = request.getParameter("invenId");
    String startPriceStr = request.getParameter("startPrice");
    String durationStr = request.getParameter("durationHours");

    if(invenIdStr == null || startPriceStr == null || durationStr == null) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }

    int invenId = Integer.parseInt(invenIdStr);
    long startPrice = Long.parseLong(startPriceStr);
    int duration = Integer.parseInt(durationStr);

    if (duration <= 0) {
        out.println("<script>alert('경매 기간은 1시간 이상이어야 합니다.'); history.back();</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    PreparedStatement psCheck = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        String sqlCheck = "SELECT ItemID, Quantity FROM INVENTORY WHERE InventoryID = ? AND UserID = ?";
        psCheck = conn.prepareStatement(sqlCheck);
        psCheck.setInt(1, invenId);
        psCheck.setString(2, userId);
        rs = psCheck.executeQuery();

        int realItemId = 0;
        if (rs.next()) {
            realItemId = rs.getInt("ItemID");
            int qty = rs.getInt("Quantity");
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
        rs.close(); psCheck.close();

        String sqlUpdate = "UPDATE INVENTORY SET Quantity = Quantity - 1 WHERE InventoryID = ?";
        pstmt = conn.prepareStatement(sqlUpdate);
        pstmt.setInt(1, invenId);
        int updated = pstmt.executeUpdate();

        if (updated == 0){
            conn.rollback();
            out.println("<script>alert('아이템 차감 중 오류가 발생했습니다.'); history.back();</script>");
            return;
        }
        pstmt.close();

        String sqlInsert = "INSERT INTO AUCTION (AUCTIONID, START_PRICE, STARTTIME, ENDTIME, CURRENTHIGHESTPRICE, ITEMID, SELLERID, REGISTERINVENTORYID) " +
                        "VALUES ((SELECT NVL(MAX(AUCTIONID), 0) + 1 FROM AUCTION), ?, SYSDATE, SYSDATE + (?/24), ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sqlInsert);
        pstmt.setLong(1, startPrice);
        pstmt.setInt(2, duration);
        pstmt.setLong(3, startPrice);
        pstmt.setInt(4, realItemId);
        pstmt.setString(5, userId);
        pstmt.setInt(6, invenId);
        pstmt.executeUpdate();
        
        conn.commit();
        out.println("<script>alert('경매 등록이 완료되었습니다!'); location.href='show_my_registered_item_list_action.jsp';</script>");

    } catch(SQLException se) {
        try{if (conn != null) conn.rollback();} catch(Exception ignore) {}
        
        if (se.getErrorCode() == 1) {
            out.println("<script>alert('등록 요청이 많아 처리에 실패했습니다. 잠시 후 다시 시도해주세요.'); history.back();</script>");
        } else {
            se.printStackTrace();
            out.println("<script>alert('등록 중 오류가 발생했습니다: " + se.getMessage().replace("'", "") + "'); history.back();</script>");
        }
    } catch(Exception e) {
        e.printStackTrace();
        try{if (conn != null) conn.rollback();} catch(Exception ignore) {}
        out.println("<script>alert('오류가 발생했습니다.'); history.back();</script>");
    } finally {
        try{if(rs!=null) rs.close();} catch(Exception ignore){}
        try{if(psCheck!=null) psCheck.close();} catch(Exception ignore){}
        try{if(pstmt!=null) pstmt.close();} catch(Exception ignore){}
        try{if(conn!=null) conn.setAutoCommit(true); conn.close(); } catch(Exception ignore){}
    }
%>