<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 { color: #333; }

        /* Message box (EX7) */
        .message {
            padding: 10px 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 14px;
            display: inline-block;
            min-width: 260px;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin-bottom: 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .btn:hover {
            background-color: #0056b3;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
        }
        th {
            background-color: #007bff;
            color: white;
            padding: 12px;
            text-align: left;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover { background-color: #f8f9fa; }

        .action-link {
            color: #007bff;
            text-decoration: none;
            margin-right: 10px;
        }
        .delete-link { color: #dc3545; }

        /* EX5 Search Form */
        .search-box input {
            padding: 10px;
            width: 250px;
        }
        .search-box button {
            padding: 10px 20px;
        }

        /* Pagination (EX7) */
        .pagination {
            margin-top: 15px;
        }
        .pagination a {
            display: inline-block;
            padding: 6px 10px;
            margin-right: 4px;
            text-decoration: none;
            border: 1px solid #ccc;
            border-radius: 4px;
            color: #007bff;
            font-size: 14px;
        }
        .pagination a.active {
            background-color: #007bff;
            color: white;
            border-color: #007bff;
        }
        .pagination a.disabled {
            color: #aaa;
            border-color: #eee;
            pointer-events: none;
        }
    </style>
</head>
<body>
    <h1>📚 Student Management System</h1>

<%
    String success = request.getParameter("message");
    if (success == null || success.trim().isEmpty()) {
        success = request.getParameter("success");
    }
    String error = request.getParameter("error");
%>

    <% if (success != null && !success.trim().isEmpty()) { %>
        <div id="messageBox" class="message success">✓ <%= success %></div>
    <% } else if (error != null && !error.trim().isEmpty()) { %>
        <div id="messageBox" class="message error">✗ <%= error %></div>
    <% } %>

<%
    // BONUS 2: Sorting parameters
    String sortBy = request.getParameter("sortBy");
    if (sortBy == null || sortBy.trim().isEmpty()) {
        sortBy = "id";   // default
    }

    String order = request.getParameter("order");
    if (order == null || order.trim().isEmpty()) {
        order = "desc";  // default
    }
%>

    <!-- Top buttons -->
    <a href="add_student.jsp" class="btn">➕ Add New Student</a>
    <a href="export_students_csv.jsp" 
       class="btn" 
       style="margin-left: 10px; background-color:#28a745;">
       ⬇ Export CSV
    </a>

    <!-- SEARCH + CLEAR + SORT -->
    <form class="search-box" action="list_students.jsp" method="get" style="margin-bottom: 20px;">
        <input 
            type="text" 
            name="keyword" 
            placeholder="Search by code, name, email, major..." 
            value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>"
        />

        <span style="margin-left: 20px;">Sort by:</span>
        <select name="sortBy">
            <option value="id" <%= "id".equals(sortBy) ? "selected" : "" %>>ID</option>
            <option value="student_code" <%= "student_code".equals(sortBy) ? "selected" : "" %>>Student Code</option>
            <option value="full_name" <%= "full_name".equals(sortBy) ? "selected" : "" %>>Full Name</option>
            <option value="email" <%= "email".equals(sortBy) ? "selected" : "" %>>Email</option>
            <option value="major" <%= "major".equals(sortBy) ? "selected" : "" %>>Major</option>
        </select>

        <select name="order">
            <option value="asc"  <%= "asc".equalsIgnoreCase(order)  ? "selected" : "" %>>ASC</option>
            <option value="desc" <%= "desc".equalsIgnoreCase(order) ? "selected" : "" %>>DESC</option>
        </select>

        <button type="submit" style="margin-left: 10px;">🔍 Search</button>

        <a href="list_students.jsp" class="btn" style="margin-left: 10px; padding: 10px 20px;">
            Clear
        </a>
    </form>

<%
    String keyword = request.getParameter("keyword");
    boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());

    int recordsPerPage = 10;   // EX7: 10 students per page
    int currentPage = 1;

    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.trim().isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1;
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    int offset = (currentPage - 1) * recordsPerPage;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    int totalRecords = 0;
    int totalPages = 1;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "Taolavodoi@123"
        );

        // Đếm tổng số record (có hoặc không search)
        String countSql = "SELECT COUNT(*) FROM students";
        if (hasKeyword) {
            countSql += " WHERE student_code LIKE ? OR full_name LIKE ? OR email LIKE ? OR major LIKE ?";
        }

        pstmt = conn.prepareStatement(countSql);
        if (hasKeyword) {
            String kw = "%" + keyword.trim() + "%";
            pstmt.setString(1, kw);
            pstmt.setString(2, kw);
            pstmt.setString(3, kw);
            pstmt.setString(4, kw);
        }
        rs = pstmt.executeQuery();
        if (rs.next()) {
            totalRecords = rs.getInt(1);
        }
        rs.close();
        pstmt.close();

        if (totalRecords > 0) {
            totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
        } else {
            totalPages = 1;
        }

        // BONUS 2: sanitize sortBy & order
        String sortColumn = "id";
        if ("student_code".equals(sortBy) ||
            "full_name".equals(sortBy) ||
            "email".equals(sortBy) ||
            "major".equals(sortBy)) {
            sortColumn = sortBy;
        }

        String sortOrder = "DESC";
        if ("asc".equalsIgnoreCase(order)) {
            sortOrder = "ASC";
        }

        // Lấy dữ liệu theo trang (EX5 + EX7 + BONUS SORT)
        String sql = "SELECT * FROM students";
        if (hasKeyword) {
            sql += " WHERE student_code LIKE ? OR full_name LIKE ? OR email LIKE ? OR major LIKE ?";
        }
        sql += " ORDER BY " + sortColumn + " " + sortOrder + " LIMIT ? OFFSET ?";

        pstmt = conn.prepareStatement(sql);
        int idx = 1;
        if (hasKeyword) {
            String kw = "%" + keyword.trim() + "%";
            pstmt.setString(idx++, kw);
            pstmt.setString(idx++, kw);
            pstmt.setString(idx++, kw);
            pstmt.setString(idx++, kw);
        }
        pstmt.setInt(idx++, recordsPerPage);
        pstmt.setInt(idx, offset);

        rs = pstmt.executeQuery();
%>

    <!-- 🔥 FORM BULK DELETE BAO QUANH BẢNG + PAGINATION -->
    <form id="bulkForm" action="bulk_delete.jsp" method="post"
          onsubmit="return confirm('Are you sure you want to delete selected students?');">

        <!-- Nút Bulk Delete -->
        <button type="submit"
                class="btn"
                style="background-color:#dc3545; margin-bottom:10px;">
            🗑️ Delete Selected
        </button>

        <table>
            <thead>
                <tr>
                    <th>
                        <input type="checkbox" id="selectAll" onclick="toggleAll(this)">
                    </th>
                    <th>ID</th>
                    <th>Student Code</th>
                    <th>Full Name</th>
                    <th>Email</th>
                    <th>Major</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
<%
        while (rs.next()) {
            int id = rs.getInt("id");
            String studentCode = rs.getString("student_code");
            String fullName = rs.getString("full_name");
            String emailVal = rs.getString("email");
            String majorVal = rs.getString("major");
%>
                <tr>
                    <td>
                        <input type="checkbox" name="selectedIds" value="<%= id %>">
                    </td>
                    <td><%= id %></td>
                    <td><%= studentCode %></td>
                    <td><%= fullName %></td>
                    <td><%= (emailVal != null ? emailVal : "N/A") %></td>
                    <td><%= (majorVal != null ? majorVal : "N/A") %></td>
                    <td>
                        <a href="edit_student.jsp?id=<%= id %>" class="action-link">✏️ Edit</a>
                        <a href="delete_student.jsp?id=<%= id %>"
                           class="action-link delete-link"
                           onclick="return confirm('Are you sure?')">🗑️ Delete</a>
                    </td>
                </tr>
<%
        }

    } catch (ClassNotFoundException e) {
%>
        <tr><td colspan="7">Error: JDBC Driver not found!</td></tr>
<%
    } catch (SQLException e) {
%>
        <tr><td colspan="7">Database Error: <%= e.getMessage() %></td></tr>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) {}
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }
%>

            </tbody>
        </table>

        <!-- Pagination (EX7) -->
        <div class="pagination">
<%
    // giữ lại keyword + sortBy + order khi chuyển trang
    String extra = "";
    if (hasKeyword) {
        extra += "&keyword=" + keyword;
    }
    if (sortBy != null && !sortBy.trim().isEmpty()) {
        extra += "&sortBy=" + sortBy;
    }
    if (order != null && !order.trim().isEmpty()) {
        extra += "&order=" + order;
    }

    if (currentPage > 1) {
%>
            <a href="list_students.jsp?page=<%= currentPage - 1 %><%= extra %>">Previous</a>
<%
    }

    for (int i = 1; i <= totalPages; i++) {
        if (i == currentPage) {
%>
            <a href="list_students.jsp?page=<%= i %><%= extra %>" class="active"><%= i %></a>
<%
        } else {
%>
            <a href="list_students.jsp?page=<%= i %><%= extra %>"><%= i %></a>
<%
        }
    }

    if (currentPage < totalPages) {
%>
            <a href="list_students.jsp?page=<%= currentPage + 1 %><%= extra %>">Next</a>
<%
    }
%>
        </div>
    </form>

    <!-- Auto-hide message sau 3s (EX7) -->
    <script>
        setTimeout(function () {
            var box = document.getElementById('messageBox');
            if (box) {
                box.style.transition = 'opacity 0.5s';
                box.style.opacity = '0';
                setTimeout(function () {
                    box.style.display = 'none';
                }, 500);
            }
        }, 3000);

        // BONUS 3: Select All checkbox
        function toggleAll(source) {
            const checkboxes = document.querySelectorAll('input[name="selectedIds"]');
            checkboxes.forEach(cb => cb.checked = source.checked);
        }
    </script>

</body>
</html>
