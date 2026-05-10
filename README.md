# Todo App – Flutter + ASP.NET Core + JWT

Ứng dụng Todo đầy đủ với xác thực JWT, backend ASP.NET Core và frontend Flutter.

---

## Cấu trúc dự án

```
├── TodoApi/                          # Backend ASP.NET Core
│   ├── Controllers/
│   │   ├── AuthController.cs         # Đăng ký / Đăng nhập
│   │   └── TodosController.cs        # CRUD Todo
│   ├── Data/
│   │   └── AppDbContext.cs           # EF Core DbContext (SQLite)
│   ├── Models/
│   │   ├── User.cs
│   │   ├── Todo.cs
│   │   └── DTOs.cs
│   ├── Services/
│   │   └── JwtService.cs             # Tạo & đọc JWT token
│   ├── Program.cs
│   └── appsettings.json
│
└── lab5_2224802010260_trantrongmanh/ # Frontend Flutter
    └── lib/
        ├── main.dart
        ├── models/
        │   ├── user_model.dart
        │   └── todo_model.dart
        ├── providers/
        │   ├── auth_provider.dart
        │   └── todo_provider.dart
        ├── screens/
        │   ├── login_screen.dart
        │   ├── register_screen.dart
        │   ├── todo_list_screen.dart
        │   └── todo_form_screen.dart
        ├── services/
        │   └── api_service.dart
        └── widgets/
            └── todo_card.dart
```

---

## Chạy Backend (ASP.NET Core)

### Yêu cầu
- .NET 8 SDK: https://dotnet.microsoft.com/download

### Các bước

```bash
cd TodoApi

# Restore packages
dotnet restore

# Chạy server (tự tạo database SQLite)
dotnet run
```

Server chạy tại: `http://localhost:5000`  
Swagger UI: `http://localhost:5000/swagger`

---

## Chạy Frontend (Flutter)

### Cấu hình URL

Mở file `lib/services/api_service.dart` và chỉnh `baseUrl`:

| Môi trường | URL |
|---|---|
| Android Emulator | `http://10.0.2.2:5000/api` |
| iOS Simulator | `http://localhost:5000/api` |
| Thiết bị thật | `http://<IP_máy_tính>:5000/api` |

### Các bước

```bash
cd lab5_2224802010260_trantrongmanh

flutter pub get
flutter run
```

---

## API Endpoints

### Auth
| Method | Endpoint | Mô tả |
|---|---|---|
| POST | `/api/auth/register` | Đăng ký tài khoản |
| POST | `/api/auth/login` | Đăng nhập, nhận JWT |

### Todos (yêu cầu Bearer Token)
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `/api/todos` | Lấy tất cả todo của user |
| GET | `/api/todos/{id}` | Lấy todo theo ID |
| POST | `/api/todos` | Tạo todo mới |
| PUT | `/api/todos/{id}` | Cập nhật todo |
| DELETE | `/api/todos/{id}` | Xoá todo |
| PATCH | `/api/todos/{id}/toggle` | Đổi trạng thái hoàn thành |

---

## Tính năng

- ✅ Đăng ký / Đăng nhập với JWT
- ✅ Token lưu an toàn bằng `flutter_secure_storage`
- ✅ Tự động kiểm tra đăng nhập khi mở app
- ✅ CRUD đầy đủ cho Todo
- ✅ Toggle trạng thái hoàn thành
- ✅ Swipe để xoá (Dismissible)
- ✅ Tab: Tất cả / Chờ / Xong
- ✅ Pull-to-refresh
- ✅ Validation form
- ✅ Swagger UI cho backend
