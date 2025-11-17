<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    String userTier = (String) session.getAttribute("userTier");

    if (!"ADMIN".equals(userTier)) {
        response.sendRedirect("../index.jsp");
        return;
    }
%>