<%@ page language="java" contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("text/csv; charset=UTF-8");
    response.setHeader("Content-Disposition", "attachment; filename=\"students.csv\"");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "Taolavodoi@123"
        );

        String sql = "SELECT id, student_code, full_name, email, major, created_at FROM students ORDER BY id ASC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        out.println("ID,Student Code,Full Name,Email,Major,Created At");

        while (rs.next()) {
            int id = rs.getInt("id");
            String code = rs.getString("student_code");
            String name = rs.getString("full_name");
            String email = rs.getString("email");
            String major = rs.getString("major");
            java.sql.Timestamp createdAt = rs.getTimestamp("created_at");

            if (code == null) code = "";
            if (name == null) name = "";
            if (email == null) email = "";
            if (major == null) major = "";
            String createdAtStr = (createdAt != null) ? createdAt.toString() : "";

            code = code.replace("\"", "\"\"");
            name = name.replace("\"", "\"\"");
            email = email.replace("\"", "\"\"");
            major = major.replace("\"", "\"\"");
            createdAtStr = createdAtStr.replace("\"", "\"\"");

            out.println(
                "\"" + id + "\"," +
                "\"" + code + "\"," +
                "\"" + name + "\"," +
                "\"" + email + "\"," +
                "\"" + major + "\"," +
                "\"" + createdAtStr + "\""
            );
        }

    } catch (Exception e) {
        out.println("\"Error\",\"" + e.getMessage().replace("\"", "\"\"") + "\"");
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException ex) {}
        try { if (pstmt != null) pstmt.close(); } catch (SQLException ex) {}
        try { if (conn != null) conn.close(); } catch (SQLException ex) {}
    }

    out.flush();
%>
