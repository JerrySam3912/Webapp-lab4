/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package db;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class dbConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/student_management";
    private static final String USER = "root"; // đổi nếu MySQL của bạn có user khác
    private static final String PASSWORD = "Taolavodoi@123"; // điền mật khẩu nếu có

    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); // nạp driver
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("✅ Connect to MySQL successfully");
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("❌ Fail to connect: " + e.getMessage());
        }
        return conn;
    }
}