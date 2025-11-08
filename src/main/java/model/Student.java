/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author ADMIN
 */
public class Student {
    private int id;
    private String student_code;
    private String full_name;
    private String email;
    private String major;

    // Constructor rỗng
    public Student() {}

    // Constructor đầy đủ
    public Student(int id, String student_code, String full_name, String email, String major) {
        this.id = id;
        this.student_code = student_code;
        this.full_name = full_name;
        this.email = email;
        this.major = major;
    }

    // Getter & Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getStudent_code() {
        return student_code;
    }

    public void setStudent_code(String student_code) {
        this.student_code = student_code;
    }

    public String getFull_name() {
        return full_name;
    }

    public void setFull_name(String full_name) {
        this.full_name = full_name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getMajor() {
        return major;
    }

    public void setMajor(String major) {
        this.major = major;
    }

    // Phương thức in ra thông tin sinh viên (dễ debug)
    @Override
    public String toString() {
        return "Student [id=" + id + ", code=" + student_code + ", name=" + full_name +
                ", email=" + email + ", major=" + major + "]";
    }
}