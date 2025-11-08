# 🧾 EX1 – Report: `list_students.jsp`

## DEMO

<img src="image/list.png">

## 1️⃣ Purpose and Scope
**Goal:**  
Display a table of all students from the MySQL table **`students`** (database: `student_management`), including **Add**, **Edit**, and **Delete** links.

**Assessed Skills:**
- Correct JSP directive and encoding setup  
- JDBC connection and SQL `SELECT` execution  
- Looping through `ResultSet` and generating HTML table  
- Navigation between JSP pages (Add/Edit/Delete)

---

## 2️⃣ File Location and How the Server Finds It

### 📁 Physical location
```
src/main/webapp/list_students.jsp
```

### 🌐 Runtime URL (Tomcat)
```
http://localhost:8080/Lab4-CRUD/list_students.jsp
```

Tomcat automatically maps JSP files inside `src/main/webapp` to URL paths matching their filenames.  
➡️ No `web.xml` configuration or servlet mapping is required for static JSP files.

---

## 3️⃣ JSP Directive and Import Explanation

```jsp
<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="java.sql.*, db.dbConnection" %>
```

| Attribute | Purpose |
|------------|----------|
| `contentType="text/html; charset=UTF-8"` | Ensures the response is HTML with UTF-8 encoding. |
| `pageEncoding="UTF-8"` | Ensures the JSP file itself is read using UTF-8 encoding (avoids Vietnamese character corruption). |
| `import="java.sql.*, db.dbConnection"` | Allows use of JDBC classes (`Connection`, `PreparedStatement`, `ResultSet`) and the shared connection class `dbConnection`. |

> ⚠️ Important: Attributes must be separated by spaces — otherwise Tomcat (Jasper) throws an error.

---

## 4️⃣ Code Flow (Request → DB → HTML)

### 🔁 Simplified JSP Flow

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, db.dbConnection" %>
<!DOCTYPE html>
<html>
<body>

<!-- (A) Read messages from query parameters -->
<%
String msg = request.getParameter("msg");
String err = request.getParameter("error");
%>

<!-- (B) Navigation button -->
<a href="add_student.jsp">➕ Add New Student</a>

<!-- (C) Table header -->
<table> ... </table>

<!-- (D) Connect to database and execute SELECT -->
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
      <td><%= rs.getTimestamp("created_at") %></td>
      <td>
        <a href="edit_student.jsp?id=<%= rs.getInt("id") %>">Edit</a> |
        <a href="delete_student.jsp?id=<%= rs.getInt("id") %>"
           onclick="return confirm('Are you sure?');">Delete</a>
      </td>
    </tr>
<%
  }
} catch (Exception e) {
  out.println("<tr><td colspan='7'>Error: " + e.getMessage() + "</td></tr>");
}
%>

</body>
</html>
```

### 🧠 Step-by-step explanation

| Step | Description |
|------|--------------|
| **(A)** | Reads `msg` and `error` query params to show feedback banners (e.g., “Added successfully”). |
| **(B)** | Displays navigation link to `add_student.jsp`. |
| **(C)** | Builds table headers for `ID`, `Student Code`, `Full Name`, etc. |
| **(D)** | Calls `dbConnection.getConnection()` → internally loads `com.mysql.cj.jdbc.Driver` → `DriverManager.getConnection(...)`. |
| **(E)** | Executes `SELECT * FROM students ORDER BY id DESC` using `PreparedStatement`. |
| **(F)** | Loops through `ResultSet` to print `<tr>` rows for each student. |
| **(G)** | Appends **Edit** and **Delete** links, passing `id` via query string. |
| **(H)** | Catches any exception, printing an inline error message within the table. |

---

## 5️⃣ How Tomcat Resolves Navigation Links

| Link | File Mapped To | Function |
|------|----------------|-----------|
| `href="add_student.jsp"` | `/webapp/add_student.jsp` | Opens Add form |
| `href="edit_student.jsp?id=..."` | `/webapp/edit_student.jsp` | Opens Edit form, passing `id` |
| `href="delete_student.jsp?id=..."` | `/webapp/delete_student.jsp` | Calls Delete logic (EX4) |

If the context path changes, use:
```jsp
<a href="${pageContext.request.contextPath}/add_student.jsp">Add Student</a>
```

---

## 6️⃣ Visual Flow Diagram

```
Browser GET /Lab4-CRUD/list_students.jsp
   │
   ├─ JSP directive: setup encoding + import JDBC + dbConnection
   ├─ Read ?msg & ?error → show feedback banners
   ├─ Open DB connection via dbConnection.getConnection()
   │    └─ DriverManager.getConnection("jdbc:mysql://...","root","****")
   ├─ Run SELECT * FROM students ORDER BY id DESC
   ├─ Loop ResultSet → output <tr> rows
   └─ Render links (Add/Edit/Delete)
Response → Browser renders full HTML table
```

---

## 7️⃣ Common Issues and Fixes

| Problem | Cause | Solution |
|----------|--------|----------|
| `HTTP 500 – JSP attribute name error` | Missing whitespace between directive attributes | Fix: `<%@ page contentType="..." pageEncoding="..." %>` |
| `Access denied for user 'root'@'localhost'` | Wrong DB credentials | Update `dbConnection.java` with correct username/password |
| `ClassNotFoundException: com.mysql.cj.jdbc.Driver` | Missing MySQL Connector | Add dependency `mysql-connector-j` in `pom.xml` |
| Empty table | DB has no rows | Run `SELECT * FROM students;` in MySQL Workbench |

---

## 8️⃣ Why Use `PreparedStatement`
Even though EX1 doesn’t have parameters, using `PreparedStatement`:
- Prevents SQL injection when parameters appear in later exercises (EX2–EX4).  
- Improves readability and consistency.  
- Allows database-side statement caching for performance.

---

## 9️⃣ What the Grader Should See
✅ Accessing  
```
http://localhost:8080/Lab4-CRUD/list_students.jsp
```  
shows:
- 5 sample student records  
- “Add New Student” button  
- “Edit” and “Delete” links per row  
- Proper UTF-8 display  
- No runtime errors  
- Newest records appear first (`ORDER BY id DESC`)

---

## 🔟 Quick Reference

| Item | Value |
|------|-------|
| **Project view** | Web Pages → `list_students.jsp` |
| **On disk (Maven)** | `src/main/webapp/list_students.jsp` |
| **URL (Tomcat)** | `http://localhost:8080/Lab4-CRUD/list_students.jsp` |

---


### ✅ Expected Output
| ID | Student Code |   Full Name  |       Email       |       Major      | Created At |    Actions    |
|----|--------------|--------------|-------------------|------------------|------------|---------------|
| 5  | SV005        | David Wilson | david.w@email.com | Computer Science | .......... | Edit | Delete |
| 4  | SV004        | Sarah Davis  | sarah.d@email.com |   Data Science   | ... .......| Edit | Delete |
| ... | ... | ... | ... | ... | ... | ... |

---

> 💡 Next step: create **EX2 report (add_student.jsp + process_add.jsp)** following the same structure — purpose, mapping, directive explanation, request→DB→response flow, and code walkthrough.
---
# 🧾 EX2 – Report: `add_student.jsp` + `process_add.jsp`

## DEMO
<img src="image/add.png">
<img src="image/success.png">
<img src="image/error.png">

## 1️⃣ Purpose and User Story
- From **`list_students.jsp`**, the user clicks **Add New Student**.  
- Show a form (`add_student.jsp`).  
- Validate input. If valid → **INSERT** a new row via `process_add.jsp` → redirect back to list with a success banner.  
- If invalid or duplicate → show an error and guide the user.

---

## 2️⃣ How the server finds the pages (routing)
- On the list page, the “Add” button is an anchor:  
  ```html
  <a href="add_student.jsp">➕ Add New Student</a>
  ```
  ➜ Browser sends **GET** to `/Lab4-CRUD/add_student.jsp` (Tomcat maps to `src/main/webapp/add_student.jsp`).

- The form in `add_student.jsp` posts to `process_add.jsp`:  
  ```jsp
  <form action="process_add.jsp" method="post" accept-charset="UTF-8">
  ```
  ➜ Browser sends **POST** to `/Lab4-CRUD/process_add.jsp`.

- **Cancel** is just an anchor back to the list (no server-side action):  
  ```html
  <a class="btn" href="list_students.jsp">Cancel</a>
  ```

---

## 3️⃣ `add_student.jsp` — What runs when you click “Add Student”
**Code skeleton (cleaned and annotated):**
```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head> ... CSS omitted ... </head>
<body>
  <div class="wrap">
    <h2>➕ Add Student</h2>

    <%-- (A) Show error banner if a previous validation failed --%>
    <% String error = request.getParameter("error"); 
       if (error != null) { %>
       <div class="err"><%= error %></div>
    <% } %>

    <%-- (B) Main form. User POSTs data to process_add.jsp --%>
    <form action="process_add.jsp" method="post" accept-charset="UTF-8">
      <label>Student Code *</label>
      <input name="student_code" required>

      <label>Full Name *</label>
      <input name="full_name" required>

      <div class="row">
        <div>
          <label>Email</label>
          <input name="email" type="email" placeholder="name@example.com">
        </div>
        <div>
          <label>Major</label>
          <input name="major" placeholder="Computer Science">
        </div>
      </div>

      <div class="actions">
        <button class="btn primary" type="submit">Save</button>
        <%-- (C) Cancel = simple link, no server-side code executes --%>
        <a class="btn" href="list_students.jsp">Cancel</a>
      </div>
    </form>
  </div>
</body>
</html>
```

### Flow when **Add Student** is clicked on the list page
1) Browser navigates to `add_student.jsp` (GET).  
2) JSP evaluates section **(A)**: if the previous attempt failed, `?error=...` will exist and the banner appears.  
3) User fills **Student Code** and **Full Name** (required).  
4) Clicking **Save** triggers **(B)**: the browser sends a **POST** to `process_add.jsp`.  
5) Clicking **Cancel** triggers **(C)**: just navigates back to `list_students.jsp` (no DB/query at all).

---

## 4️⃣ `process_add.jsp` — Which code runs on submit?

**Canonical implementation (with validation & duplicate handling):**
```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%
  request.setCharacterEncoding("UTF-8");

  // (1) Read form fields
  String code  = request.getParameter("student_code");
  String name  = request.getParameter("full_name");
  String email = request.getParameter("email");
  String major = request.getParameter("major");

  // (2) Server-side validation: required fields
  if (code == null || code.isEmpty() || name == null || name.isEmpty()) {
    response.sendRedirect("add_student.jsp?error=Student Code and Full Name are required");
    return;
  }
  // (3) Optional: email format validation
  if (email != null && !email.isEmpty() && !email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
    response.sendRedirect("add_student.jsp?error=Invalid email format");
    return;
  }

  // (4) Insert using shared dbConnection
  try (Connection conn = db.dbConnection.getConnection();
       PreparedStatement ps = conn.prepareStatement(
           "INSERT INTO students(student_code, full_name, email, major) VALUES (?,?,?,?)")) {

    ps.setString(1, code.trim());
    ps.setString(2, name.trim());
    ps.setString(3, (email == null || email.isEmpty()) ? null : email.trim());
    ps.setString(4, (major == null || major.isEmpty()) ? null : major.trim());
    ps.executeUpdate();

    // (5) On success → back to list with success message
    response.sendRedirect("list_students.jsp?msg=Added successfully");
  } catch (SQLException e) {
    // (6) Handle unique constraint (duplicate student_code) or other SQL errors
    String msg = e.getMessage();
    if (msg != null && msg.toLowerCase().contains("duplicate")) {
      response.sendRedirect("add_student.jsp?error=Student Code already exists");
    } else {
      response.sendRedirect("list_students.jsp?error=" + msg.replaceAll("\s+","%20"));
    }
  } catch (Exception e) {
    // (7) Generic error
    response.sendRedirect("list_students.jsp?error=" + e.getMessage().replaceAll("\s+","%20"));
  }
%>
```

### Detailed code-flow breakdown
- **On submit (Save)**  
  → Steps **(1)–(7)** execute in order.
  - **(1)** Read the posted fields by name.  
  - **(2)** Validate required fields (**Student Code**, **Full Name**). If either missing → **redirect back to form** with `?error=...` (the banner in `add_student.jsp` shows it).  
  - **(3)** Validate email format (optional but recommended). If invalid → redirect back with error.  
  - **(4)** Open a DB connection via `dbConnection.getConnection()` and run an **INSERT** using `PreparedStatement` to prevent SQL injection.  
  - **(5)** If INSERT succeeds → redirect to `list_students.jsp?msg=Added successfully`. The list page shows a green success banner and the new record appears at the top (because `ORDER BY id DESC`).  
  - **(6)** If a **duplicate** key happens (e.g., `student_code` is UNIQUE and already exists), we check the exception message and redirect to `add_student.jsp?error=Student Code already exists`. The user sees a red error box and can edit the input.  
  - **(7)** Any other exception is redirected to the list with an error banner.

- **On cancel**  
  → No code in `process_add.jsp` runs. The anchor navigates directly to `list_students.jsp`.

---

## 5️⃣ What happens in each user scenario?

| Scenario | Which file runs | Which lines run | Result |
|---------|------------------|------------------|--------|
| Click **Add New Student** on the list page | `add_student.jsp` (GET) | Section **(A)** shows previous error (if any). The HTML form in **(B)** renders. | Form appears. |
| Click **Save** with **missing required fields** | `process_add.jsp` (POST) | Validation **(2)** triggers: `response.sendRedirect("add_student.jsp?error=...")` | Back to form, red banner shown. |
| Click **Save** with **invalid email** | `process_add.jsp` (POST) | Validation **(3)** triggers → redirect back with error | Back to form, red banner shown. |
| Click **Save** with **valid, non-duplicate** data | `process_add.jsp` (POST) | DB block **(4)** does `INSERT`, then **(5)** redirect to list `?msg=Added successfully` | List shows green banner + new row at top. |
| Click **Save** with **duplicate `student_code`** | `process_add.jsp` (POST) | Catch block **(6)** detects “duplicate” → redirect to `add_student.jsp?error=Student Code already exists` | Back to form with red banner; user changes code. |
| Click **Cancel** | (No server code) | Only the **anchor** executes (client-side navigation) | Return to `list_students.jsp`. |

---

## 6️⃣ Sequence diagrams (high-level)

### (a) Normal happy path
```
List → [click Add] → add_student.jsp (GET)
   → [fill form + Save] → process_add.jsp (POST)
      → validate OK → INSERT → redirect list_students.jsp?msg=Added successfully
         → List reloads → shows success banner + new row
```

### (b) Missing fields / invalid email
```
List → [Add] → add_student.jsp → [Save with missing/invalid]
   → process_add.jsp → validation fails → redirect add_student.jsp?error=...
      → Form reloads with red banner
```

### (c) Duplicate student_code
```
List → [Add] → add_student.jsp → [Save duplicate code]
   → process_add.jsp → SQLException "duplicate" → redirect add_student.jsp?error=Student Code already exists
      → User edits → Save again → success path
```

### (d) Cancel
```
add_student.jsp → [Cancel anchor] → list_students.jsp
(no server-side validation/insert occurs)
```

---

## 7️⃣ Common pitfalls (and how this code avoids them)
- **Relying on client-side `required` only** → We always perform **server-side** validation in `process_add.jsp`.  
- **String concatenation SQL** → We use `PreparedStatement` to eliminate SQL injection risks.  
- **Driver not found / wrong credentials** → Shared `dbConnection.getConnection()` centralizes driver and credentials, so we fix in one place.  
- **Not closing resources** → Try-with-resources ensures `Connection`/`PreparedStatement` are closed even on exceptions.  
- **Blank screen after submit** → We always **redirect** to a visible page (form or list) with a clear banner message.  

---

## 8️⃣ Acceptance checklist (what your teacher sees)
- Clicking **Add** navigates to a clean, UTF-8 form page.  
- Submitting incomplete/invalid inputs correctly returns to the form with a clear **error** banner.  
- Submitting valid data inserts a row and returns to the list with a **success** banner; new row is visible on top.  
- Duplicate `student_code` is handled gracefully with a **specific error** back on the form.  
- **Cancel** takes the user back to the list without any changes to the database.

---

# 🧾 EX3 – Report: `edit_student.jsp` + `process_edit.jsp`

## DEMO
<img src="image/edit.png">
<img src="image/upSucces.png">

---

## 1️⃣ Purpose and User Story
From the **student list** page, a user clicks **Edit** on a specific row.  
The app must:
- Read the `id` from the query string.
- Load the current data for that `id` and **prefill** a form (`edit_student.jsp`).
- Validate inputs, then **UPDATE** the row via `process_edit.jsp`.
- Redirect with banners for success or error cases.

> In your implementation, `student_code` is **read-only** on the edit form (cannot be changed), while **full_name**, **email**, and **major** can be updated.

---

## 2️⃣ Routing / How the server finds pages

### On the list page (`list_students.jsp`)
Each row renders an **Edit** link that carries the primary key:
```jsp
<a href="edit_student.jsp?id=<%= rs.getInt("id") %>">✏️ Edit</a>
```
➡️ Browser does **GET** `/Lab4-CRUD/edit_student.jsp?id=123`.

### On the edit page (`edit_student.jsp`)
The **form** posts to the **processor**:
```jsp
<form action="process_edit.jsp" method="post" accept-charset="UTF-8">
  <input type="hidden" name="id" value="<%= studentId %>">
  ...
</form>
```
➡️ Browser does **POST** `/Lab4-CRUD/process_edit.jsp` on Save.

### Cancel
Just a link back to the list (no server-side work):
```html
<a href="list_students.jsp" class="btn-cancel">Cancel</a>
```

---

## 3️⃣ `edit_student.jsp` – What it does when you click “Edit”

**Key responsibilities:**
1) Validate the presence/format of `id`.  
2) Load the record by `id`.  
3) Prefill the form fields.  
4) Render an **Update** button that posts to `process_edit.jsp`.  
5) Offer a **Cancel** link back to the list.

**Annotated skeleton:**

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, db.dbConnection" %>
<%
  // (A) Validate id in query string
  String idParam = request.getParameter("id");
  if (idParam == null || idParam.trim().isEmpty()) {
    response.sendRedirect("list_students.jsp?error=Invalid student ID"); return;
  }
  int studentId;
  try { studentId = Integer.parseInt(idParam); }
  catch (NumberFormatException e) {
    response.sendRedirect("list_students.jsp?error=Invalid ID format"); return;
  }

  // (B) Fetch current values from DB
  String studentCode="", fullName="", email="", major="";
  try (Connection conn = dbConnection.getConnection();
       PreparedStatement ps = conn.prepareStatement("SELECT * FROM students WHERE id=?")) {
    ps.setInt(1, studentId);
    try (ResultSet rs = ps.executeQuery()) {
      if (!rs.next()) {
        response.sendRedirect("list_students.jsp?error=Student not found"); return;
      }
      studentCode = rs.getString("student_code");
      fullName    = rs.getString("full_name");
      email       = rs.getString("email");   if (email==null) email="";
      major       = rs.getString("major");   if (major==null) major="";
    }
  } catch (Exception e) {
    response.sendRedirect("list_students.jsp?error="+e.getMessage()); return;
  }
%>
<!DOCTYPE html>
<html>
<head> ... CSS ... </head>
<body>
  <div class="container">
    <h2>✏️ Edit Student Information</h2>

    <%-- (C) Show any error passed via query string --%>
    <% if (request.getParameter("error") != null) { %>
      <div class="error"><%= request.getParameter("error") %></div>
    <% } %>

    <%-- (D) Prefilled form, code is readonly --%>
    <form action="process_edit.jsp" method="POST" accept-charset="UTF-8">
      <input type="hidden" name="id" value="<%= studentId %>">

      <label>Student Code</label>
      <input type="text" name="student_code" value="<%= studentCode %>" readonly>

      <label>Full Name *</label>
      <input type="text" name="full_name" value="<%= fullName %>" required>

      <label>Email</label>
      <input type="email" name="email" value="<%= email %>">

      <label>Major</label>
      <input type="text" name="major" value="<%= major %>">

      <button type="submit" class="btn-submit">💾 Update</button>
      <a href="list_students.jsp" class="btn-cancel">Cancel</a>
    </form>
  </div>
</body>
</html>
```

### Code flow (GET edit page)
1. **(A)** Validate `id`: must exist and be an integer. Otherwise redirect with error.  
2. **(B)** Query the DB by `id`. If not found, redirect with error.  
3. Render the HTML form with **prefilled** values.  
4. Wait for user to click **Update** (POST to `process_edit.jsp`) or **Cancel** (back to list).

---

## 4️⃣ `process_edit.jsp` – What runs on Update (POST)

**Responsibilities:**
- Validate posted fields (`id`, required fields, optional email format).  
- Update the row.  
- Redirect to list with success or return to edit with error.

**Annotated skeleton:**

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, db.dbConnection" %>
<%
  request.setCharacterEncoding("UTF-8");

  // (1) Read form params
  String sid   = request.getParameter("id");
  String code  = request.getParameter("student_code"); // readonly, but still posted
  String name  = request.getParameter("full_name");
  String email = request.getParameter("email");
  String major = request.getParameter("major");

  // (2) Validate basics
  if (sid==null || sid.isEmpty() || name==null || name.isEmpty()) {
    response.sendRedirect("list_students.jsp?error=Invalid input"); return;
  }
  int id;
  try { id = Integer.parseInt(sid); }
  catch (NumberFormatException e) {
    response.sendRedirect("list_students.jsp?error=Invalid ID format"); return;
  }

  // (3) Optional: validate email format
  if (email != null && !email.isEmpty() && !email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
    response.sendRedirect("edit_student.jsp?id="+sid+"&error=Invalid email format"); return;
  }

  // (4) Perform UPDATE with PreparedStatement
  try (Connection conn = dbConnection.getConnection();
       PreparedStatement ps = conn.prepareStatement(
         "UPDATE students SET full_name=?, email=?, major=? WHERE id=?")) {
    ps.setString(1, name.trim());
    ps.setString(2, (email==null || email.isEmpty()) ? null : email.trim());
    ps.setString(3, (major==null || major.isEmpty()) ? null : major.trim());
    ps.setInt(4, id);

    int n = ps.executeUpdate();
    if (n == 0) {
      response.sendRedirect("list_students.jsp?error=ID not found");
    } else {
      response.sendRedirect("list_students.jsp?msg=Updated successfully");
    }
  } catch (Exception e) {
    response.sendRedirect("list_students.jsp?error=" + e.getMessage());
  }
%>
```

> **Why not update `student_code`?** In your UI, `student_code` is read-only to preserve uniqueness and avoid business confusion. If you allowed it to change, you’d also need to handle **duplicate code** checks similar to EX2.

### Code flow (POST update)
1. Read form fields.  
2. Validate: must have a valid numeric `id`, and `full_name` cannot be empty.  
3. Validate optional **email** format.  
4. Execute the `UPDATE` query.  
5. If `n == 0`, that `id` no longer exists → redirect with error. Otherwise redirect with **success**.  

---

## 5️⃣ User scenarios and which lines run

| Scenario | Which file runs | Which lines run | Result |
|---------|------------------|------------------|--------|
| Click **Edit** on a row | `edit_student.jsp` (GET) | (A) validate id → (B) fetch row → render form | Prefilled form appears |
| **Cancel** from edit | (No server processing) | Anchor to `list_students.jsp` | Return to list |
| **Update** with missing `full_name` | `process_edit.jsp` (POST) | (2) validation fails → `sendRedirect("list...error=Invalid input")` | Back to list with error |
| **Update** with invalid email | `process_edit.jsp` (POST) | (3) email validation fails → `sendRedirect("edit_student.jsp?id=...&error=Invalid email format")` | Back to edit form with banner |
| **Update** with valid values** | `process_edit.jsp` (POST) | (4) runs UPDATE → redirect `list_students.jsp?msg=Updated successfully` | List shows success banner |
| **ID not found** (deleted concurrently) | `process_edit.jsp` (POST) | `n==0` branch → `sendRedirect("list_students.jsp?error=ID not found")` | List shows error banner |

> **Note:** If you want to keep the user on the edit page for *all* validation errors, you can redirect back to `edit_student.jsp?id=...` with an error param instead of the list page. Your current approach shows a concise list-level message for some errors.

---

## 6️⃣ Sequence diagrams

### (a) Normal edit flow
```
List → [Edit?id] → edit_student.jsp (GET)
  → loads current values → render form
    → [Update POST] → process_edit.jsp
      → validate OK → UPDATE → redirect list?msg=Updated successfully
         → list shows banner + updated row
```

### (b) Invalid ID or not found
```
List → edit_student.jsp?id=abc  → invalid id → redirect list?error=Invalid ID format
List → edit_student.jsp?id=9999 → not found → redirect list?error=Student not found
```

### (c) Validation failures on POST
```
edit_student.jsp → [Update POST] → process_edit.jsp
  → missing full_name → redirect list?error=Invalid input

edit_student.jsp → [Update POST] → process_edit.jsp
  → invalid email → redirect edit_student.jsp?id=...&error=Invalid email format
```

---

## 7️⃣ Common pitfalls (+ fixes)
- **Manually building SQL with strings** → use `PreparedStatement` to prevent SQL injection.  
- **Forgetting to validate `id`** → always check presence and integer format on **both** GET and POST.  
- **Trusting client-side required** → keep **server-side** validations for `full_name` (and email format if used).  
- **Not handling concurrent delete** → `UPDATE` could return `0` if the row disappears; handle with a proper error message.  
- **Leaking connections** → use try-with-resources for `Connection/PreparedStatement/ResultSet`.

---

## 8️⃣ Acceptance checklist (what the teacher expects)
- Clicking **Edit** opens a prefilled form for the correct row.  
- **Cancel** returns to the list immediately.  
- Submitting invalid data shows clear error banners and does **not** update the DB.  
- Submitting valid data updates the row and shows **“Updated successfully”** on the list.  
- Edge cases (`id` missing/invalid/not found) are handled gracefully with redirects and messages.  

---

## 9️⃣ Optional improvement ideas
- Keep user on the edit page for all errors (always redirect back to `edit_student.jsp?id=...&error=...`).  
- Add HTML5 validation hints (`minlength`, pattern for email).  
- Add server-side trimming/normalization for `full_name` (e.g., collapse multiple spaces).  
- Audit logs: store who updated and when.  
- Soft-delete instead of hard deletion in EX4 (for auditability).  

---

# 🧾 EX4 – Report: `delete_student.jsp`

## DEMO
<img src="image/delete.png">
<img src="image/deSuccess.png">

## 1️⃣ Purpose and User Story
From the **student list** page, when a user clicks **Delete** on a specific row:
- The browser asks for **confirmation** (JavaScript `confirm` dialog).
- If confirmed, navigate to `delete_student.jsp?id=...`.
- The server validates the `id`, executes **DELETE** on the DB, and redirects back to the list with a result banner (success or error).

> This report explains **exactly which code runs** after you click **Delete**, in what **order**, and **why**.

---

## 2️⃣ Routing / How the server finds `delete_student.jsp`

### On the list page (`list_students.jsp`)
Each row renders a **Delete** link that carries the primary key and a confirm dialog:
```jsp
<a class="delete" href="delete_student.jsp?id=<%= rs.getInt("id") %>"
   onclick="return confirm('Delete this student?');">🗑️ Delete</a>
```
- **`onclick="return confirm(...)"`**:  
  - If the user clicks **Cancel**, the **link is not followed** (the browser cancels navigation). **No server code runs**.  
  - If the user clicks **OK**, the browser performs **GET** to:  
    `/Lab4-CRUD/delete_student.jsp?id=123`

Tomcat maps this URL directly to `src/main/webapp/delete_student.jsp`.

---

## 3️⃣ `delete_student.jsp` – What runs on GET (after user confirms)

**Responsibilities:**
1) **Validate** presence & format of `id`.  
2) Execute **DELETE** by `id` using `PreparedStatement`.  
3) Redirect back to the list with a clear **message** (`?msg=...` or `?error=...`).

**Canonical skeleton (annotated):**
```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, db.dbConnection" %>
<%
  // (A) Read and validate 'id' parameter
  String sid = request.getParameter("id");
  if (sid == null || sid.trim().isEmpty()) {
    response.sendRedirect("list_students.jsp?error=Missing id");
    return;
  }
  int id;
  try {
    id = Integer.parseInt(sid);
  } catch (NumberFormatException e) {
    response.sendRedirect("list_students.jsp?error=Invalid id");
    return;
  }

  // (B) Execute DELETE using PreparedStatement (prevents SQL injection)
  try (Connection conn = dbConnection.getConnection();
       PreparedStatement ps = conn.prepareStatement("DELETE FROM students WHERE id=?")) {
    ps.setInt(1, id);
    int n = ps.executeUpdate();

    // (C) Redirect with result banner
    if (n == 0) {
      response.sendRedirect("list_students.jsp?error=ID not found");
    } else {
      response.sendRedirect("list_students.jsp?msg=Deleted successfully");
    }
  } catch (SQLException e) {
    response.sendRedirect("list_students.jsp?error=" + e.getMessage());
  } catch (Exception e) {
    response.sendRedirect("list_students.jsp?error=" + e.getMessage());
  }
%>
```

### Code flow (GET delete page)
1. **(A)** Validate `id`: must exist and be an integer. On failure → redirect to list with `?error=...`.  
2. **(B)** Run parameterized `DELETE FROM students WHERE id=?` to remove exactly one row.  
3. **(C)** If `n == 0`, the `id` did not match any row (maybe already deleted) → show error. Otherwise, **success**.  
4. Always **redirect** back to `list_students.jsp` with a banner (`msg` or `error`).

---

## 4️⃣ User scenarios and which lines run

| Scenario | Which file runs | Which lines run | Result |
|---------|------------------|------------------|--------|
| Click **Delete** → press **Cancel** in confirm dialog | (No server processing) | The anchor is **not** followed (`return false`) | Stay on list; nothing changes |
| Click **Delete** → press **OK** | `delete_student.jsp` (GET) | (A) validate id → (B) execute DELETE → (C) redirect with msg/error | Back to list with banner |
| `id` missing or not a number | `delete_student.jsp` (GET) | (A) fails → `sendRedirect("list_students.jsp?error=...")` | Back to list with error |
| Row already removed / not found | `delete_student.jsp` (GET) | (B) `executeUpdate()` returns `0` → (C) `error=ID not found` | Back to list with error |
| DB error (foreign key, etc.) | `delete_student.jsp` (GET) | Caught in `catch(SQLException e)` | Back to list with SQL error message |

---

## 5️⃣ Sequence diagrams

### (a) Normal delete path
```
List → [click Delete?id=123] → JS confirm → OK
  → GET delete_student.jsp?id=123
     → validate OK → DELETE → redirect list?msg=Deleted successfully
        → List reloads → green success banner
```

### (b) Cancel at confirm
```
List → [click Delete] → JS confirm → CANCEL
  → (no HTTP request)
  → Stay on list; no DB changes
```

### (c) Invalid or missing id
```
GET delete_student.jsp?id=abc → invalid int → redirect list?error=Invalid id
GET delete_student.jsp        → missing id → redirect list?error=Missing id
```

### (d) Concurrency: already deleted
```
GET delete_student.jsp?id=123
  → DELETE affects 0 rows → redirect list?error=ID not found
```

---

## 6️⃣ Why `PreparedStatement` and try-with-resources
- `PreparedStatement` prevents **SQL injection** and avoids string concatenation bugs.  
- Try-with-resources guarantees the `Connection/PreparedStatement` are **closed** even if exceptions occur.

---

## 7️⃣ Common pitfalls (+ fixes)
- **Hardcoding absolute paths**: keep `href="delete_student.jsp?id=..."` (or use `${pageContext.request.contextPath}` prefix) to avoid 404s when context changes.  
- **Skipping validation**: always validate `id` to avoid `NumberFormatException`.  
- **Silent failures**: always redirect with a clear `?msg` or `?error` so the user knows what happened.  
- **Foreign key constraints**: if students are referenced elsewhere, a hard delete may fail. Consider **soft delete** or ON DELETE rules.

---

## 8️⃣ Acceptance checklist (what the teacher expects)
- Clicking **Delete** shows a confirm dialog; **Cancel** does nothing.  
- **OK** triggers a server-side delete by **id** with `PreparedStatement`.  
- Success redirects to the list with a **green success** banner.  
- Errors (missing/invalid id, not found, SQL) redirect with a **clear error** banner.  
- Resources are closed properly; no JSP 500 errors.

---

## 9️⃣ Optional improvement ideas
- **Soft delete**: add `is_deleted TINYINT DEFAULT 0`, change list to `WHERE is_deleted=0`, and in delete set `is_deleted=1`.  
- **Audit trail**: log who deleted at what time.  
- **CSRF protection**: move delete to a POST endpoint with a token instead of GET link.  
- **Flash messages**: store messages in session to avoid long query strings.
