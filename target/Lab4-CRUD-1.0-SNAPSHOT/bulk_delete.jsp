<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String[] selectedIds = request.getParameterValues("selectedIds");

    if (selectedIds == null || selectedIds.length == 0) {
        response.sendRedirect("list_students.jsp?error=No students selected for deletion");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    int deletedCount = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "Taolavodoi@123"
        );

        // Tạo câu SQL với số lượng ? tương ứng
        StringBuilder sb = new StringBuilder("DELETE FROM students WHERE id IN (");
        for (int i = 0; i < selectedIds.length; i++) {
            if (i > 0) sb.append(",");
            sb.append("?");
        }
        sb.append(")");

        pstmt = conn.prepareStatement(sb.toString());
        for (int i = 0; i < selectedIds.length; i++) {
            pstmt.setInt(i + 1, Integer.parseInt(selectedIds[i]));
        }

        deletedCount = pstmt.executeUpdate();

        if (deletedCount > 0) {
            response.sendRedirect("list_students.jsp?message=Deleted " + deletedCount + " student(s) successfully");
        } else {
            response.sendRedirect("list_students.jsp?error=No student was deleted");
        }

    } catch (Exception e) {
        // Có thể log lỗi chi tiết hơn nếu cần
        response.sendRedirect("list_students.jsp?error=Error while deleting selected students");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (SQLException ex) {}
        try { if (conn != null) conn.close(); } catch (SQLException ex) {}
    }
%>
