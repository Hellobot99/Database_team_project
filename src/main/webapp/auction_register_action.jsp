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
    PreparedStatement ps1 = null;
    PreparedStatement ps2 = null;
    PreparedStatement ps3 = null;
    PreparedStatement ps4 = null;
    ResultSet rs = null;

    int deleted = 0;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        String sqlCheck = "SELECT Quantity FROM INVENTORY WHERE InventoryID = ? AND UserID = ? FOR UPDATE";
        ps1 = conn.prepareStatement(sqlCheck);
        ps1.setInt(1, invenId);
        ps1.setString(2, userId);
        rs = ps1.executeQuery();
        
        if(rs.next()) {

            String sqlUpdate = "UPDATE INVENTORY SET Quantity = Quantity - 1 WHERE InventoryID = ? and Quantity > 1";
            ps2 = conn.prepareStatement(sqlUpdate);
            ps2.setInt(1, invenId);
            int updated = ps2.executeUpdate();
            if(updated==0) {
                String sqlDelete = "DELETE FROM INVENTORY WHERE InventoryID = ? and Quantity = 1";
                ps3 = conn.prepareStatement(sqlDelete);
                ps3.setInt(1, invenId);
                deleted = ps3.executeUpdate();

                if(deleted == 0){
                    conn.rollback();
                    throw new Exception("동시에 다른 요청이 처리되어 재고 변경에 실패했습니다. 다시 시도해주세요.");
                }
            }

            String sqlInsert = "INSERT INTO AUCTION (AUCTIONID, START_PRICE, STARTTIME, ENDTIME, CURRENTHIGHESTPRICE, ITEMID, SELLERID, REGISTERINVENTORYID) " +
                    "VALUES ((SELECT NVL(MAX(AUCTIONID), 0)+1 FROM AUCTION), ?, SYSDATE, SYSDATE + (?/24), ?, ?, ?, ?)";
            
            ps4 = conn.prepareStatement(sqlInsert);
            ps4.setLong(1, startPrice);
            ps4.setInt(2, duration);
            ps4.setLong(3, startPrice);
            ps4.setInt(4, itemId);
            ps4.setString(5, userId);
            ps4.setInt(6, invenId);
            ps4.executeUpdate();
            ps4.close();

            conn.commit();
            out.println("<script>alert('경매 등록이 완료되었습니다!'); location.href='show_my_registered_item_list_action.jsp';</script>");
        } else {
            out.println("<script>alert('아이템이 존재하지 않습니다.'); history.back();</script>");
        }

    } catch(Exception e) {
        e.printStackTrace();
        try{if (conn != null) conn.rollback();} catch(Exception ignore) {}
        out.println("<script>alert('등록 중 오류 발생: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        try { if (conn != null) conn.setAutoCommit(true);} catch (Exception ignore) {}
        try { if (rs != null) rs.close(); } catch (Exception ignore) {}
        try { if (ps1 != null) pstmt.close(); } catch (Exception ignore) {}
        try { if (ps2 != null) pstmt.close(); } catch (Exception ignore) {}
        try { if (ps3 != null) pstmt.close(); } catch (Exception ignore) {}
        try { if (ps4 != null) pstmt.close(); } catch (Exception ignore) {}
        try { if (conn != null) conn.close(); } catch (Exception ignore) {}
    }
%>