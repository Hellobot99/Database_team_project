<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%@ include file="admin_check.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String actionType = request.getParameter("actionType");
    String targetUserId = request.getParameter("userId");
    String itemIdStr = request.getParameter("itemId");
    String quantityStr = request.getParameter("quantity");
    String conditions = request.getParameter("conditions");

    if (targetUserId == null || itemIdStr == null || quantityStr == null) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }

    int targetItemId = Integer.parseInt(itemIdStr);
    int amount = Integer.parseInt(quantityStr);
    if(conditions == null) conditions = "New"; 

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();

        String checkSql = "SELECT Quantity FROM INVENTORY WHERE UserID = ? AND ItemID = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, targetUserId);
        pstmt.setInt(2, targetItemId);
        rs = pstmt.executeQuery();

        boolean hasItem = rs.next();
        int currentQty = hasItem ? rs.getInt("Quantity") : 0;
        
        rs.close();
        pstmt.close();


        if ("GIVE".equals(actionType)) {
            if (hasItem) {

                String updateSql = "UPDATE INVENTORY SET Quantity = Quantity + ? WHERE UserID = ? AND ItemID = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setInt(1, amount);
                pstmt.setString(2, targetUserId);
                pstmt.setInt(3, targetItemId);
                pstmt.executeUpdate();
                pstmt.close();
            } else {

                String insertSql = "INSERT INTO INVENTORY (InventoryID, UserID, ItemID, Quantity, Conditions, Acquired_Date) "
                                 + "VALUES ((SELECT NVL(MAX(InventoryID), 0) + 1 FROM INVENTORY), ?, ?, ?, ?, SYSTIMESTAMP)";
                pstmt = conn.prepareStatement(insertSql);
                pstmt.setString(1, targetUserId);
                pstmt.setInt(2, targetItemId);
                pstmt.setInt(3, amount);
                pstmt.setString(4, conditions);
                pstmt.executeUpdate();
                pstmt.close();
            }
            out.println("<script>alert('✅ 지급 완료! (" + amount + "개, " + conditions + ")'); location.href='admin_inventory_manage.jsp';</script>");
        } 
        
        else if ("TAKE".equals(actionType)) {
            if (!hasItem) {
                out.println("<script>alert('⚠ 오류: 유저가 아이템을 가지고 있지 않습니다.'); history.back();</script>");
            } else {
                if (currentQty <= amount) {
                    String deleteSql = "DELETE FROM INVENTORY WHERE UserID = ? AND ItemID = ?";
                    pstmt = conn.prepareStatement(deleteSql);
                    pstmt.setString(1, targetUserId);
                    pstmt.setInt(2, targetItemId);
                    pstmt.executeUpdate();
                    pstmt.close();
                    out.println("<script>alert('🗑 전량 회수(삭제)되었습니다.'); location.href='admin_inventory_manage.jsp';</script>");
                } else {
                    String updateSql = "UPDATE INVENTORY SET Quantity = Quantity - ? WHERE UserID = ? AND ItemID = ?";
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setInt(1, amount);
                    pstmt.setString(2, targetUserId);
                    pstmt.setInt(3, targetItemId);
                    pstmt.executeUpdate();
                    pstmt.close();
                    out.println("<script>alert('🔽 " + amount + "개 회수 완료!'); location.href='admin_inventory_manage.jsp';</script>");
                }
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>