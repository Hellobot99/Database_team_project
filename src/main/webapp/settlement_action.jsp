<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%
    String userId = (String) session.getAttribute("userId");
    String auctionIdStr = request.getParameter("auctionId");

    if (userId == null || auctionIdStr == null) {
        response.sendRedirect("login.html");
        return;
    }

    int auctionId = Integer.parseInt(auctionIdStr);
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        String sqlCheckHistory = "SELECT count(*) FROM MARKET_HISTORY WHERE AuctionID = ?";
        pstmt = conn.prepareStatement(sqlCheckHistory);
        pstmt.setInt(1, auctionId);
        rs = pstmt.executeQuery();
        if (rs.next() && rs.getInt(1) > 0) {
            conn.rollback();
            out.println("<script>alert('이미 정산(입금)된 아이템입니다.'); history.back();</script>");
            return;
        }
        rs.close(); pstmt.close();

        String sqlAuction = "SELECT CurrentHighestPrice FROM AUCTION WHERE AuctionID = ? AND SellerID = ?";
        pstmt = conn.prepareStatement(sqlAuction);
        pstmt.setInt(1, auctionId);
        pstmt.setString(2, userId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            long price = rs.getLong("CurrentHighestPrice");

            String sqlUpdateUser = "UPDATE USERS SET Balance = Balance + ? WHERE UserID = ?";
            PreparedStatement psUser = conn.prepareStatement(sqlUpdateUser);
            psUser.setLong(1, price);
            psUser.setString(2, userId);
            psUser.executeUpdate();
            psUser.close();

            String sqlInsertHistory = "INSERT INTO MARKET_HISTORY (HistoryID, AuctionID, TradeTime, FinalPrice) " +
                                      "VALUES ((SELECT NVL(MAX(HistoryID), 0)+1 FROM MARKET_HISTORY), ?, SYSDATE, ?)";
            PreparedStatement psHistory = conn.prepareStatement(sqlInsertHistory);
            psHistory.setInt(1, auctionId);
            psHistory.setLong(2, price);
            psHistory.executeUpdate();
            psHistory.close();

            conn.commit();
            out.println("<script>alert('정산 완료! " + price + " G가 입금되었습니다.'); location.href='my_history.jsp';</script>");
        } else {
            out.println("<script>alert('잘못된 접근이거나 판매자 정보가 일치하지 않습니다.'); history.back();</script>");
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