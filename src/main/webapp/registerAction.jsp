<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");

    String userID = request.getParameter("userID");
    String userPW = request.getParameter("password");
    String userName = request.getParameter("name");

    if (userID == null || userPW == null || userName == null ||
        userID.isEmpty() || userPW.isEmpty() || userName.isEmpty()) {
        out.println("<script>alert('모든 정보를 입력해주세요.'); history.back();</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBConnection.getConnection();

        String sql = "INSERT INTO USERS (UserID, Password, Name, Tier, Balance) VALUES (?, ?, ?, 'ROOKIE', 3000)";
        
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userID);
        pstmt.setString(2, userPW);
        pstmt.setString(3, userName);
        
        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>");
            out.println("alert('회원가입 성공! ROOKIE 등급으로 시작하며, 정착 지원금 3,000G가 지급되었습니다.');");
            out.println("location.href='login.html';");
            out.println("</script>");
        } else {
            out.println("<script>alert('회원가입에 실패했습니다.'); history.back();</script>");
        }

    } catch (SQLIntegrityConstraintViolationException e) {
        out.println("<script>alert('이미 존재하는 아이디입니다.'); history.back();</script>");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>