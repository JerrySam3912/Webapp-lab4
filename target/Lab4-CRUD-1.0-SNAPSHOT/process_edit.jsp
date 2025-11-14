<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String idParam = request.getParameter("id");
    String studentCode = request.getParameter("student_code");  // EX6.2 - thêm dòng này
    String fullName = request.getParameter("full_name");
    String email = request.getParameter("email");
    String major = request.getParameter("major");
    
    // EX6.0 - Basic required check (giữ nguyên logic thầy)
    if (idParam == null || fullName == null || fullName.trim().isEmpty()) {
        response.sendRedirect("list_students.jsp?error=Invalid data");
        return;
    }

    // EX6.2 - Student code pattern validation on edit (2 uppercase letters + 3+ digits)
    // studentCode thường là readonly trong form, nhưng ta vẫn validate cho đúng đề.
    if (studentCode == null || !studentCode.matches("[A-Z]{2}[0-9]{3,}")) {
        response.sendRedirect("edit_student.jsp?id=" + idParam + "&error=Invalid student code format");
        return;
    }

    // EX6.1 - Email validation (optional)
    if (email != null && !email.trim().isEmpty()) {
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            response.sendRedirect("edit_student.jsp?id=" + idParam + "&error=Invalid email format");
            return;
        }
    }
    
    int studentId = Integer.parseInt(idParam);
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "Taolavodoi@123"
        );
        
        String sql = "UPDATE students SET full_name = ?, email = ?, major = ? WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, fullName);
        pstmt.setString(2, email);
        pstmt.setString(3, major);
        pstmt.setInt(4, studentId);
        
        int rowsAffected = pstmt.executeUpdate();
        
        if (rowsAffected > 0) {
            response.sendRedirect("list_students.jsp?message=Student updated successfully");
        } else {
            response.sendRedirect("edit_student.jsp?id=" + studentId + "&error=Update failed");
        }
        
    } catch (Exception e) {
        response.sendRedirect("edit_student.jsp?id=" + studentId + "&error=Error occurred");
        e.printStackTrace();
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
