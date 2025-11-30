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
    PreparedStatement psSel = null;
    ResultSet rs = null;


    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        String sqlSel = "SELECT SellerID, ItemID, RegisterInventoryID FROM AUCTION WHERE AuctionID = ?";
        psSel = conn.prepareStatement(sqlSel);
        psSel.setInt(1, auctionId);
        rs = psSel.executeQuery();

        if (!rs.next()) {

            out.println("<script>alert('존재하지 않는 경매입니다.'); history.back();</script>");
            return;
        }

        String sellerId = rs.getString("SellerID");
        int itemId = rs.getInt("ItemID");
        int invenId = rs.getInt("RegisterInventoryID");

        String userTier = (String) session.getAttribute("userTier");
        if (!sellerId.equals(userId) && !"ADMIN".equals(userTier)) {
            out.println("<script>alert('본인이 등록한 물품만 삭제할 수 있습니다.'); history.back();</script>");
            return;
        }

        Timestamp now = new Timestamp(System.currentTimeMillis());
        String sqlDelAuc = "DELETE FROM AUCTION WHERE AuctionID = ? AND EndTime > ? AND NOT EXISTS (SELECT 1 FROM bidding_record where auctionid = ?)";
        ps1 = conn.prepareStatement(sqlDelAuc);
        ps1.setInt(1, auctionId);
        ps1.setTimestamp(2, now);
        ps1.setInt(3, auctionId);
        int deleted = ps1.executeUpdate();

        if(deleted == 0){
                conn.rollback();
                out.println("<script>alert('이미 입찰이 시작 된 경매입니다.'); history.back();</script>");
                return;
        }   
        
        String sqlRestore = "UPDATE INVENTORY SET Quantity = Quantity + 1 WHERE InventoryID = ?";
        ps2 = conn.prepareStatement(sqlRestore);
        ps2.setInt(1, invenId);
        int updated = ps2.executeUpdate();

        if(updated == 0){
            conn.rollback();
            out.println("<script>alert('인벤토리 복원에 실패했습니다. 관리자에게 문의해주세요.'); history.back();</script>");
        }

        conn.commit();
        out.println("<script>alert('경매가 취소되었습니다. 아이템이 인벤토리로 반환되었습니다.'); location.href='show_my_registered_item_list_action.jsp';</script>");
    } catch (Exception e) {
        try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        try {if (ps1 != null) ps1.close(); } catch (Exception ignore) {}
        try {if (ps2 != null) ps2.close(); } catch (Exception ignore) {}
        try {if (ps3 != null) ps3.close(); } catch (Exception ignore) {}
        try {if (psSel != null) psSel.close(); } catch (Exception ignore) {}
        try {if (rs != null) rs.close(); } catch (Exception ignore) {}
        try {if (conn != null) conn.setAutoCommit(true); conn.close(); } catch (Exception ignore) {}
    }
%>