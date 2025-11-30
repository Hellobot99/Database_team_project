<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%
    String userId = (String) session.getAttribute("userId");
    String auctionIdStr = request.getParameter("auctionId");

    if (userId == null || auctionIdStr == null) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }

    int auctionId = Integer.parseInt(auctionIdStr);
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);
        
        String sqlCheckWinner = "SELECT BidderID FROM BIDDING_RECORD WHERE AuctionID = ? ORDER BY BidAmount DESC, BidTime ASC FETCH FIRST 1 ROWS ONLY";
        pstmt = conn.prepareStatement(sqlCheckWinner);
        pstmt.setInt(1, auctionId);
        rs = pstmt.executeQuery();
        
        if (!rs.next() || !userId.equals(rs.getString("BidderID"))) {
            out.println("<script>alert('낙찰자가 아니거나 입찰 기록이 없습니다.'); history.back();</script>");
            return;
        }
        rs.close(); pstmt.close();

        String sqlInfo = "SELECT A.ItemID, A.RegisterInventoryID, INV.Conditions " +
                         "FROM AUCTION A " +
                         "JOIN INVENTORY INV ON A.RegisterInventoryID = INV.InventoryID " +
                         "WHERE A.AuctionID = ?";
        
        pstmt = conn.prepareStatement(sqlInfo);
        pstmt.setInt(1, auctionId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            int itemId = rs.getInt("ItemID");
            int sellerInvenId = rs.getInt("RegisterInventoryID");
            String condition = rs.getString("Conditions");

            String sqlGiveItem = "INSERT INTO INVENTORY (InventoryID, UserID, ItemID, Quantity, Conditions, Acquired_Date) " +
                                 "VALUES ((SELECT NVL(MAX(InventoryID), 0)+1 FROM INVENTORY), ?, ?, 1, ?, SYSDATE)";
            
            PreparedStatement psGive = conn.prepareStatement(sqlGiveItem);
            psGive.setString(1, userId);
            psGive.setInt(2, itemId);
            psGive.setString(3, condition);
            psGive.executeUpdate();
            psGive.close();

            String sqlDeleteGhost = "DELETE FROM INVENTORY WHERE InventoryID = ?";
            PreparedStatement psDel = conn.prepareStatement(sqlDeleteGhost);
            psDel.setInt(1, sellerInvenId);
            psDel.executeUpdate();
            psDel.close();
            
            conn.commit();
            out.println("<script>alert('아이템 수령 완료! 인벤토리를 확인하세요.'); location.href='my_history.jsp';</script>");

        } else {
            out.println("<script>alert('이미 수령한 아이템이거나 정보를 찾을 수 없습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (Exception e) {}
    }
%>