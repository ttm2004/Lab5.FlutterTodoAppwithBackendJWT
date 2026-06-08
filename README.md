# BÁO CÁO BÀI TẬP THỰC HÀNH - LAB 5

**Môn học:** Phát triển Ứng dụng Di động Đa nền tảng  
**Sinh viên:** Trần Trọng Mạnh  
**MSSV:** 2224802010260  
**Ngày nộp:** 10/05/2026  

---

## Video Demo

[![Xem video demo](https://drive.google.com/thumbnail?id=1izMBkDXEZvb4yK9KrObtv09uYgxoqRJG&sz=w640)](https://drive.google.com/file/d/1izMBkDXEZvb4yK9KrObtv09uYgxoqRJG/view?usp=drive_link)

👉 [Nhấn vào đây để xem video demo](https://drive.google.com/file/d/1izMBkDXEZvb4yK9KrObtv09uYgxoqRJG/view?usp=drive_link)

---

## 1. Giới thiệu đề tài

Bài lab này em thực hiện xây dựng ứng dụng **Todo App** gồm 2 phần:

- **Backend:** REST API sử dụng ASP.NET Core Web API với xác thực JWT
- **Frontend:** Ứng dụng Flutter kết nối với backend qua HTTP

Ứng dụng cho phép người dùng đăng ký tài khoản, đăng nhập và quản lý danh sách công việc cá nhân (thêm, xem, sửa, xoá, đánh dấu hoàn thành).

**Tài liệu tham khảo:**
- https://protocoderspoint.com/flutter-todo-app-with-nodejs-mongodb-at-backend/
- https://dotnettutorials.net/lesson/user-microservice-withasp-net-core-web-api/
- https://medium.com/@areesh-ali/building-a-secure-flutter-app-with-jwt-and-apis-e22ade2b2d5f

---

## 2. Công nghệ sử dụng

### Backend
| Thành phần | Công nghệ |
|---|---|
| Framework | ASP.NET Core Web API (.NET 8) |
| ORM | Entity Framework Core |
| Cơ sở dữ liệu | SQLite |
| Xác thực | JWT Bearer Token |
| Mã hoá mật khẩu | BCrypt.Net |
| Tài liệu API | Swagger / OpenAPI |

### Frontend (Flutter)
| Package | Mục đích |
|---|---|
| `http` | Gọi REST API |
| `shared_preferences` | Lưu JWT token xuống thiết bị |
| `jwt_decoder` | Giải mã token, kiểm tra hết hạn |
| `flutter_slidable` | Vuốt để xoá / sửa todo |
| `provider` | Quản lý state toàn cục |
| `intl` | Định dạng ngày giờ |

---

## 3. Cấu trúc dự án

```
├── TodoApi/                              # Backend ASP.NET Core
│   ├── Controllers/
│   │   ├── AuthController.cs             # Đăng ký, đăng nhập
│   │   └── TodosController.cs            # CRUD todo
│   ├── Data/
│   │   └── AppDbContext.cs               # EF Core + SQLite
│   ├── Models/
│   │   ├── User.cs
│   │   ├── Todo.cs
│   │   └── DTOs.cs                       # Các lớp request/response
│   ├── Services/
│   │   └── JwtService.cs                 # Tạo và đọc JWT
│   ├── Program.cs
│   └── appsettings.json
│
└── lab5_2224802010260_trantrongmanh/     # Frontend Flutter
    └── lib/
        ├── main.dart                     # Điểm khởi động, kiểm tra token
        ├── models/
        │   ├── user_model.dart
        │   └── todo_model.dart
        ├── providers/
        │   ├── auth_provider.dart
        │   └── todo_provider.dart
        ├── screens/
        │   ├── login_screen.dart
        │   ├── register_screen.dart
        │   ├── dashboard_screen.dart     # Màn hình chính
        │   └── todo_form_screen.dart     # Form thêm / sửa
        └── services/
            └── api_service.dart          # Xử lý gọi API và token
```

---

## 4. Các chức năng đã thực hiện

- [x] Đăng ký tài khoản (username, email, mật khẩu)
- [x] Đăng nhập và nhận JWT token
- [x] Lưu token vào `SharedPreferences`, kiểm tra hết hạn khi mở app
- [x] Tự động chuyển màn hình Login / Dashboard khi khởi động
- [x] Xem danh sách todo (chia tab: Tất cả / Chờ / Xong)
- [x] Thêm todo mới qua popup dialog (nhấn nút +)
- [x] Sửa todo (vuốt sang trái → nhấn nút Sửa)
- [x] Xoá todo (vuốt sang trái → nhấn nút Xoá, có xác nhận)
- [x] Đánh dấu hoàn thành / chưa hoàn thành (nhấn checkbox)
- [x] Pull-to-refresh làm mới danh sách
- [x] Đăng xuất xoá token và về màn hình Login
- [x] Swagger UI để test API trên trình duyệt

---

## 5. Hướng dẫn chạy chương trình

### Bước 1 – Chạy Backend

Yêu cầu cài đặt: [.NET 8 SDK](https://dotnet.microsoft.com/download)

```bash
cd TodoApi
dotnet restore
dotnet run
```

Server khởi động tại: `http://localhost:5000`  
Swagger UI (test API): `http://localhost:5000/swagger`

> Database SQLite (`todo.db`) sẽ tự động được tạo khi chạy lần đầu, không cần cấu hình thêm.

---

### Bước 2 – Cấu hình URL cho Flutter

Mở file `lab5_2224802010260_trantrongmanh/lib/services/api_service.dart`, tìm dòng `baseUrl` và chỉnh theo môi trường:

| Môi trường chạy | Giá trị baseUrl |
|---|---|
| Android Emulator (mặc định) | `http://10.0.2.2:5000/api` |
| iOS Simulator | `http://localhost:5000/api` |
| Điện thoại thật (cùng mạng WiFi) | `http://<IP_máy_tính>:5000/api` |

---

### Bước 3 – Chạy Flutter

```bash
cd lab5_2224802010260_trantrongmanh
flutter pub get
flutter run
```

---

## 6. API Endpoints

### Xác thực (không cần token)
| Method | Endpoint | Dữ liệu gửi lên | Mô tả |
|---|---|---|---|
| POST | `/api/auth/register` | `{ username, email, password }` | Đăng ký tài khoản mới |
| POST | `/api/auth/login` | `{ email, password }` | Đăng nhập, nhận JWT token |

### Todo (cần header `Authorization: Bearer <token>`)
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `/api/todos` | Lấy danh sách todo của người dùng |
| GET | `/api/todos/{id}` | Lấy chi tiết một todo |
| POST | `/api/todos` | Tạo todo mới |
| PUT | `/api/todos/{id}` | Cập nhật todo |
| DELETE | `/api/todos/{id}` | Xoá todo |
| PATCH | `/api/todos/{id}/toggle` | Đổi trạng thái hoàn thành |

---

## 7. Luồng hoạt động chính

```
Mở app
  │
  ├── Đọc token từ SharedPreferences
  ├── Dùng jwt_decoder kiểm tra token còn hạn không?
  │       ├── Còn hạn  →  Vào thẳng Dashboard
  │       └── Hết hạn / chưa đăng nhập  →  Màn hình Login
  │
Đăng nhập
  └── Gửi email + password → nhận token → lưu SharedPreferences → vào Dashboard

Dashboard
  ├── Giải mã token lấy thông tin user (email)
  ├── Gọi GET /api/todos để tải danh sách
  ├── Nhấn nút [+]  →  Dialog thêm todo mới
  ├── Vuốt trái item  →  Nút [Xoá] hoặc [Sửa]
  ├── Nhấn checkbox  →  Toggle hoàn thành
  └── Nhấn [Đăng xuất]  →  Xoá token, về Login
```

---

## 8. Ghi chú

- Mật khẩu được mã hoá bằng BCrypt trước khi lưu vào database, không lưu dạng plain text.
- JWT token có thời hạn 24 giờ (1440 phút), sau khi hết hạn người dùng cần đăng nhập lại.
- Mỗi người dùng chỉ thấy và thao tác được với todo của chính mình.
- Backend sử dụng SQLite nên không cần cài đặt thêm phần mềm database.
