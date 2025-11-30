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
    PreparedStatement ps1 = null;
    PreparedStatement ps2 = null;
    PreparedStatement ps3 = null;
    PreparedStatement ps4 = null;
    PreparedStatement ps5 = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        String sqlCheck = "SELECT SellerID, ItemID, RegisterInventoryID FROM AUCTION WHERE AuctionID = ? FOR UPDATE";
        ps1 = conn.prepareStatement(sqlCheck);
        ps1.setInt(1, auctionId);
        rs = ps1.executeQuery();

        if (rs.next()) {
            String sellerId = rs.getString("SellerID");
            int itemId = rs.getInt("ItemID");
            int invenId = rs.getInt("RegisterInventoryID");

            String userTier = (String) session.getAttribute("userTier");
            if (!sellerId.equals(userId) && !"ADMIN".equals(userTier)) {
                out.println("<script>alert('본인이 등록한 물품만 삭제할 수 있습니다.'); history.back();</script>");
                return;
            }
            
            String sqlDelAuc = "DELETE FROM AUCTION WHERE AuctionID = ? AND NOT EXISTS (SELECT 1 FROM bidding_record where auctionid = ?)";
            ps2 = conn.prepareStatement(sqlDelAuc);
            ps2.setInt(1, auctionId);
            ps2.setInt(2, auctionId);

            int result = ps2.executeUpdate();
            if(result == 0){
                conn.rollback();
                out.println("<script>alert('경매 삭제에 실패했습니다.'); history.back();</script>");
                return;
            } else{
                String sqlInvenCheck = "SELECT * FROM INVENTORY WHERE InventoryID = ?";
                ps3 = conn.prepareStatement(sqlInvenCheck);
                ps3.setInt(1, invenId);
                ResultSet rsInven = ps3.executeQuery();
                
                boolean invenExists = false;
                if(rsInven.next()) {
                    invenExists = true;
                }
                rsInven.close();

                if (invenExists) {
                    String sqlRestore = "UPDATE INVENTORY SET Quantity = Quantity + 1 WHERE InventoryID = ?";
                    ps4 = conn.prepareStatement(sqlRestore);
                    ps4.setInt(1, invenId);
                    ps4.executeUpdate();
                } else {
                    String sqlInsert = "INSERT INTO INVENTORY (InventoryID, UserID, ItemID, Quantity, Conditions, Acquired_Date) " +
                                    "VALUES (?, ?, ?, 1, 'Return', SYSDATE)";
                    ps5 = conn.prepareStatement(sqlInsert);
                    ps5.setInt(1, invenId); 
                    ps5.setString(2, sellerId);
                    ps5.setInt(3, itemId);
                    ps5.executeUpdate();
                }

                conn.commit();
                out.println("<script>alert('경매가 취소되었습니다. 아이템이 인벤토리로 반환되었습니다.'); location.href='show_my_registered_item_list_action.jsp';</script>");
            }
        } else {
            out.println("<script>alert('존재하지 않는 경매입니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        try {if (rs != null)  rs.close(); } catch (Exception ignore) {}
        try {if (ps1 != null) pstmt.close(); } catch (Exception ignore) {}
        try {if (ps2 != null) pstmt.close(); } catch (Exception ignore) {}
        try {if (ps3 != null) pstmt.close(); } catch (Exception ignore) {}
        try {if (ps4 != null) pstmt.close(); } catch (Exception ignore) {}
        try {if (ps5 != null) pstmt.close(); } catch (Exception ignore) {}
        try {if (conn != null) conn.setAutoCommit(true); conn.close(); } catch (Exception ignore) {}
    }
%>