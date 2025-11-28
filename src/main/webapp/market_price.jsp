<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, TeamPrj.DBConnection, java.text.DecimalFormat" %>
<%@ page import="java.net.URLEncoder" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.html"); return; }
    DecimalFormat df = new DecimalFormat("#,###");

    String searchItem = request.getParameter("searchItem");
    if(searchItem == null) searchItem = "";
    
    String searchCategory = request.getParameter("searchCategory");
    if(searchCategory == null) searchCategory = "";
    
    String minPriceStr = request.getParameter("minPrice");
    if(minPriceStr == null) minPriceStr = "";
    
    String maxPriceStr = request.getParameter("maxPrice");
    if(maxPriceStr == null) maxPriceStr = "";

    String sort = request.getParameter("sort");
    if(sort == null || sort.isEmpty()) sort = "date";
    
    String order = request.getParameter("order");
    if(order == null || order.isEmpty()) order = "DESC";

    String baseUrl = "market_price.jsp?searchItem=" + URLEncoder.encode(searchItem, "UTF-8")
                   + "&searchCategory=" + URLEncoder.encode(searchCategory, "UTF-8")
                   + "&minPrice=" + minPriceStr
                   + "&maxPrice=" + maxPriceStr;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>시세 조회</title>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<style>
    body { background: #121212; color: #fff; font-family: 'Pretendard', sans-serif; margin: 0; padding: 0; }
    
    .main-wrapper { padding: 40px; }

    .container { max-width: 1000px; margin: 0 auto; }
    
    .search-box {
        background: #1e1e1e; padding: 25px; border-radius: 12px; border: 1px solid #333;
        display: flex; flex-wrap: wrap; gap: 15px; align-items: center; justify-content: center; margin-bottom: 30px;
    }
    
    .input-group { display: flex; align-items: center; gap: 8px; }
    label { font-weight: bold; color: #bbb; font-size: 0.9rem; }
    
    input[type=text], input[type=number] {
        padding: 10px; border-radius: 6px; border: 1px solid #444; background: #2a2a2a; color: #fff; 
        font-family: 'Pretendard';
    }
    input[type=text] { width: 140px; }
    input[type=number] { width: 100px; text-align: right; }

    .btn-search {
        background: #28a745; color: white; border: none; padding: 10px 20px; border-radius: 6px; 
        font-weight: bold; cursor: pointer; transition: background 0.2s;
    }
    .btn-search:hover { background: #218838; }

    table { width: 100%; border-collapse: collapse; background: #1e1e1e; border-radius: 8px; overflow: hidden; }
    th { background: #333; padding: 15px; color: #bbb; text-align: left; }
    td { padding: 15px; border-bottom: 1px solid #333; }
    
    th a { color: #fff; text-decoration: none; display: flex; align-items: center; gap: 5px; }
    th a:hover { color: #ffcc00; }
    .sort-arrow { font-size: 0.8em; color: #ffcc00; }

    .price { color: #ffcc00; font-weight: bold; }
    .date { color: #666; font-size: 0.9em; }
    h1 { border-left: 5px solid #28a745; padding-left: 15px; margin-bottom: 30px; }
    
    .home-btn {
        display: block; width: 150px; margin: 30px auto; text-align: center;
        padding: 12px; background: #444; color: white; text-decoration: none; border-radius: 30px;
    }
    .home-btn:hover { background: #555; }
</style>
</head>
<body>

<jsp:include page="header.jsp" />

<div class="main-wrapper">
    <div class="container">
        <h1>📈 아이템 시세 검색</h1>
        
        <form action="market_price.jsp" method="GET" class="search-box">
            <div class="input-group">
                <label>아이템명</label>
                <input type="text" name="searchItem" value="<%= searchItem %>" placeholder="예: 검">
            </div>
            
            <div class="input-group">
                <label>카테고리</label>
                <input type="text" name="searchCategory" value="<%= searchCategory %>" placeholder="예: 전사">
            </div>

            <div class="input-group">
                <label>가격대</label>
                <input type="number" name="minPrice" value="<%= minPriceStr %>" placeholder="최소">
                <span>~</span>
                <input type="number" name="maxPrice" value="<%= maxPriceStr %>" placeholder="최대">
            </div>
            
            <input type="hidden" name="sort" value="date">
            <input type="hidden" name="order" value="DESC">
            
            <button type="submit" class="btn-search">🔍 검색</button>
        </form>
        
        <table>
            <tr>
                <th>아이템명</th>
                <th>카테고리</th>
                <th>
                    <a href="<%= baseUrl %>&sort=price&order=<%= (sort.equals("price") && order.equals("DESC")) ? "ASC" : "DESC" %>">
                        낙찰가(시세)
                        <% if(sort.equals("price")) { %>
                            <span class="sort-arrow"><%= order.equals("ASC") ? "▲" : "▼" %></span>
                        <% } %>
                    </a>
                </th>
                <th>판매자</th>
                <th>
                    <a href="<%= baseUrl %>&sort=date&order=<%= (sort.equals("date") && order.equals("DESC")) ? "ASC" : "DESC" %>">
                        거래 일시
                        <% if(sort.equals("date")) { %>
                            <span class="sort-arrow"><%= order.equals("ASC") ? "▲" : "▼" %></span>
                        <% } %>
                    </a>
                </th>
            </tr>
            <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DBConnection.getConnection();
                
                String sql = "SELECT i.Name, c.Name AS CategoryName, a.CurrentHighestPrice, a.SellerID, a.EndTime " +
                             "FROM AUCTION a " + 
                             "JOIN ITEM i ON a.ItemID = i.ItemID " +
                             "LEFT JOIN CATEGORY c ON i.CategoryID = c.CategoryID " +
                             "WHERE a.EndTime < SYSDATE AND a.CurrentHighestPrice > 0 ";

                if (!searchItem.isEmpty()) sql += "AND UPPER(i.Name) LIKE UPPER(?) ";
                if (!searchCategory.isEmpty()) sql += "AND UPPER(c.Name) LIKE UPPER(?) ";
                if (!minPriceStr.isEmpty()) sql += "AND a.CurrentHighestPrice >= ? ";
                if (!maxPriceStr.isEmpty()) sql += "AND a.CurrentHighestPrice <= ? ";
                
                if (sort.equals("price")) {
                    sql += "ORDER BY a.CurrentHighestPrice " + (order.equals("ASC") ? "ASC" : "DESC");
                } else {
                    sql += "ORDER BY a.EndTime " + (order.equals("ASC") ? "ASC" : "DESC");
                }
                
                pstmt = conn.prepareStatement(sql);

                int pIndex = 1;
                if (!searchItem.isEmpty()) pstmt.setString(pIndex++, "%" + searchItem + "%");
                if (!searchCategory.isEmpty()) pstmt.setString(pIndex++, "%" + searchCategory + "%");
                if (!minPriceStr.isEmpty()) pstmt.setInt(pIndex++, Integer.parseInt(minPriceStr));
                if (!maxPriceStr.isEmpty()) pstmt.setInt(pIndex++, Integer.parseInt(maxPriceStr));
                
                rs = pstmt.executeQuery();
                
                boolean hasData = false;
                while(rs.next()) {
                    hasData = true;
                    String catName = rs.getString("CategoryName");
                    if(catName == null) catName = "기타";
            %>
                <tr>
                    <td style="display:flex; align-items:center; gap:10px;">
                        <img src="images/<%= rs.getString(1) %>.png" width="40" onerror="this.src='https://via.placeholder.com/40/333/fff?text=IMG'">
                        <%= rs.getString(1) %>
                    </td>
                    <td><span style="background:#333; padding:4px 8px; border-radius:4px; font-size:0.8em;"><%= catName %></span></td>
                    <td class="price"><%= df.format(rs.getInt(3)) %> G</td>
                    <td><%= rs.getString(4) %></td>
                    <td class="date"><%= rs.getTimestamp(5) %></td>
                </tr>
            <%
                }
                if (!hasData) {
                    out.println("<tr><td colspan='5' style='text-align:center; padding:50px; color:#666;'>조건에 맞는 거래 내역이 없습니다.</td></tr>");
                }
            } catch(Exception e) { 
                e.printStackTrace(); 
                out.println("<tr><td colspan='5' style='color:red; text-align:center;'>오류: " + e.getMessage() + "</td></tr>");
            } finally { 
                if(rs!=null) rs.close(); 
                if(pstmt!=null) pstmt.close(); 
                if(conn!=null) conn.close(); 
            }
            %>
        </table>
        
        <a href="index.jsp" class="home-btn">로비로 돌아가기</a>
    </div>
</div>
</body>
</html>