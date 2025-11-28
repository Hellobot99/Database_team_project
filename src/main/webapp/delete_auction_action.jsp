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
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        String sqlCheck = "SELECT SellerID, ItemID, RegisterInventoryID FROM AUCTION WHERE AuctionID = ?";
        pstmt = conn.prepareStatement(sqlCheck);
        pstmt.setInt(1, auctionId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            String sellerId = rs.getString("SellerID");
            int itemId = rs.getInt("ItemID");
            int invenId = rs.getInt("RegisterInventoryID");

            String userTier = (String) session.getAttribute("userTier");
            if (!sellerId.equals(userId) && !"ADMIN".equals(userTier)) {
                out.println("<script>alert('본인이 등록한 물품만 삭제할 수 있습니다.'); history.back();</script>");
                return;
            }
            
            pstmt.close();
            String sqlInvenCheck = "SELECT count(*) FROM INVENTORY WHERE InventoryID = ?";
            pstmt = conn.prepareStatement(sqlInvenCheck);
            pstmt.setInt(1, invenId);
            ResultSet rsInven = pstmt.executeQuery();
            
            boolean invenExists = false;
            if(rsInven.next() && rsInven.getInt(1) > 0) {
                invenExists = true;
            }
            rsInven.close();
            pstmt.close();

            if (invenExists) {
                String sqlRestore = "UPDATE INVENTORY SET Quantity = Quantity + 1 WHERE InventoryID = ?";
                pstmt = conn.prepareStatement(sqlRestore);
                pstmt.setInt(1, invenId);
                pstmt.executeUpdate();
                pstmt.close();
            } else {
                String sqlInsert = "INSERT INTO INVENTORY (InventoryID, UserID, ItemID, Quantity, Conditions, Acquired_Date) " +
                                   "VALUES (?, ?, ?, 1, 'Return', SYSDATE)";
                pstmt = conn.prepareStatement(sqlInsert);
                pstmt.setInt(1, invenId); 
                pstmt.setString(2, sellerId);
                pstmt.setInt(3, itemId);
                pstmt.executeUpdate();
                pstmt.close();
            }

            String sqlDelFav = "DELETE FROM FAVORITE WHERE AuctionID = ?";
            pstmt = conn.prepareStatement(sqlDelFav);
            pstmt.setInt(1, auctionId);
            pstmt.executeUpdate();
            pstmt.close();

            String sqlDelBid = "DELETE FROM BIDDING_RECORD WHERE AuctionID = ?";
            pstmt = conn.prepareStatement(sqlDelBid);
            pstmt.setInt(1, auctionId);
            pstmt.executeUpdate();
            pstmt.close();

            String sqlDelAuc = "DELETE FROM AUCTION WHERE AuctionID = ?";
            pstmt = conn.prepareStatement(sqlDelAuc);
            pstmt.setInt(1, auctionId);
            int result = pstmt.executeUpdate();

            if (result > 0) {
                conn.commit();
                out.println("<script>alert('경매가 취소되었습니다. 아이템이 인벤토리로 반환되었습니다.'); location.href='show_my_registered_item_list_action.jsp';</script>");
            } else {
                conn.rollback();
                out.println("<script>alert('경매 삭제에 실패했습니다.'); history.back();</script>");
            }

        } else {
            out.println("<script>alert('존재하지 않는 경매입니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (Exception e) {}
    }
%>