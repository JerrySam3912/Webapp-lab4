<%@page language="java" contentType="text/html ; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, db.dbConnection"%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8"/>
  <title>Student List</title>
</head>
<body>
  <h2>📋 Student List</h2>
  <p>
    <a href="addStudent.jsp">➕ Add Student</a>
  </p>

  <table border="1" cellpadding="8" cellspacing="0">
    <tr>
      <th>ID</th><th>Code</th><th>Name</th><th>Email</th><th>Major</th><th>Actions</th>
    </tr>
    <%
      try (Connection conn = dbConnection.getConnection();
           PreparedStatement ps = conn.prepareStatement("SELECT * FROM students ORDER BY id DESC");
           ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
    %>
      <tr>
        <td><%= rs.getInt("id") %></td>
        <td><%= rs.getString("student_code") %></td>
        <td><%= rs.getString("full_name") %></td>
        <td><%= rs.getString("email") %></td>
        <td><%= rs.getString("major") %></td>
        <td>
          <a href="editStudent.jsp?id=<%=rs.getInt("id")%>">Edit</a> |
          <a href="deleteStudent.jsp?id=<%=rs.getInt("id")%>" 
             onclick="return confirm('Delete this student?');">Delete</a>
        </td>
      </tr>
    <%
        }
      } catch (Exception e) {
        out.println("<p style='color:red'>Error: " + e.getMessage() + "</p>");
      }
    %>
  </table>
</body>
</html>
