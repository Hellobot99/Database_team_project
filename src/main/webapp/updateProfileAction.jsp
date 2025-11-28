<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="TeamPrj.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");
    String userId = (String) session.getAttribute("userId");
    
    String newName = request.getParameter("name");
    String newPassword = request.getParameter("password"); 

    if (userId == null || newName == null || newPassword == null) {
        response.sendRedirect("login.html");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        
        String sqlCheck = "SELECT Name, Balance FROM USERS WHERE UserID = ?";
        pstmt = conn.prepareStatement(sqlCheck);
        pstmt.setString(1, userId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            String currentName = rs.getString("Name");
            long currentBalance = rs.getLong("Balance");
            rs.close(); pstmt.close();
            
            boolean isNameChanged = !newName.equals(currentName);
            long cost = 0;
            
            if (isNameChanged) {
                cost = 10000;
                if (currentBalance < cost) {
                    out.println("<script>");
                    out.println("alert('닉네임 변경 비용(10,000 G)이 부족합니다.');");
                    out.println("history.back();");
                    out.println("</script>");
                    return;
                }
            }
            
            String sqlUpdate = "UPDATE USERS SET Name = ?, Password = ?, Balance = Balance - ? WHERE UserID = ?";
            pstmt = conn.prepareStatement(sqlUpdate);
            pstmt.setString(1, newName);
            pstmt.setString(2, newPassword);
            pstmt.setLong(3, cost);
            pstmt.setString(4, userId);
            
            int affectedRows = pstmt.executeUpdate();

            if (affectedRows > 0) {
                session.setAttribute("loggedInName", newName);
                
                String msg = "정보가 수정되었습니다.";
                if (isNameChanged) {
                    msg += "\\n(닉네임 변경 수수료 10,000 G가 차감되었습니다)";
                }
                
                out.println("<script>");
                out.println("alert('" + msg + "');");
                out.println("location.href='myProfile.jsp';");
                out.println("</script>");
            } else {
                out.println("<script>");
                out.println("alert('정보 변경에 실패했습니다.');");
                out.println("history.back();");
                out.println("</script>");
            }
        } else {
            out.println("<script>alert('사용자 정보를 찾을 수 없습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        out.println("<h2>오류 발생</h2><p>" + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>