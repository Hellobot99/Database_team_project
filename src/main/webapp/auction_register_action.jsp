<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.html"); return; }

    int invenId = Integer.parseInt(request.getParameter("invenId"));
    int itemId = Integer.parseInt(request.getParameter("itemId"));
    long startPrice = Long.parseLong(request.getParameter("startPrice"));
    int duration = Integer.parseInt(request.getParameter("durationHours"));

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        
        String sqlCheck = "SELECT Quantity FROM INVENTORY WHERE InventoryID = ? AND UserID = ?";
        pstmt = conn.prepareStatement(sqlCheck);
        pstmt.setInt(1, invenId);
        pstmt.setString(2, userId);
        rs = pstmt.executeQuery();
        
        if(rs.next()) {
            int qty = rs.getInt(1);
            rs.close(); pstmt.close();

            String sqlInsert = "INSERT INTO AUCTION (AUCTIONID, START_PRICE, STARTTIME, ENDTIME, CURRENTHIGHESTPRICE, ITEMID, SELLERID, REGISTERINVENTORYID) " +
                               "VALUES ((SELECT NVL(MAX(AUCTIONID), 0)+1 FROM AUCTION), ?, SYSDATE, SYSDATE + (?/24), ?, ?, ?, ?)";
            
            pstmt = conn.prepareStatement(sqlInsert);
            pstmt.setLong(1, startPrice);
            pstmt.setInt(2, duration);
            pstmt.setLong(3, startPrice);
            pstmt.setInt(4, itemId);
            pstmt.setString(5, userId);
            pstmt.setInt(6, invenId);
            pstmt.executeUpdate();
            pstmt.close();

            if(qty > 1) {
                String sqlUpdate = "UPDATE INVENTORY SET Quantity = Quantity - 1 WHERE InventoryID = ?";
                pstmt = conn.prepareStatement(sqlUpdate);
                pstmt.setInt(1, invenId);
                pstmt.executeUpdate();
            } else {
                String sqlDelete = "DELETE FROM INVENTORY WHERE InventoryID = ?";
                pstmt = conn.prepareStatement(sqlDelete);
                pstmt.setInt(1, invenId);
                pstmt.executeUpdate();
            }
            
            out.println("<script>alert('경매 등록이 완료되었습니다!'); location.href='show_my_registered_item_list_action.jsp';</script>");
        } else {
            out.println("<script>alert('아이템이 존재하지 않습니다.'); history.back();</script>");
        }

    } catch(Exception e) {
        e.printStackTrace();
        out.println("<script>alert('등록 중 오류 발생: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close(); if(conn!=null) conn.close();
    }
%>