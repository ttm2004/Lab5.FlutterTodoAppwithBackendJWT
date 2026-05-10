using System.ComponentModel.DataAnnotations;

namespace TodoApi.Models;

// ─── Auth DTOs ────────────────────────────────────────────────────────────────

public class RegisterDto
{
    [Required(ErrorMessage = "Tên người dùng là bắt buộc")]
    [MinLength(3, ErrorMessage = "Tên ít nhất 3 ký tự")]
    [MaxLength(50)]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "Email là bắt buộc")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Mật khẩu là bắt buộc")]
    [MinLength(6, ErrorMessage = "Mật khẩu ít nhất 6 ký tự")]
    public string Password { get; set; } = string.Empty;
}

public class LoginDto
{
    [Required(ErrorMessage = "Email là bắt buộc")]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Mật khẩu là bắt buộc")]
    public string Password { get; set; } = string.Empty;
}

public class AuthResponseDto
{
    public string Token { get; set; } = string.Empty;
    public UserDto User { get; set; } = null!;
}

public class UserDto
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
}

// ─── Todo DTOs ────────────────────────────────────────────────────────────────

public class CreateTodoDto
{
    [Required(ErrorMessage = "Tiêu đề là bắt buộc")]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string Description { get; set; } = string.Empty;
}

public class UpdateTodoDto
{
    [Required]
    public int Id { get; set; }

    [Required(ErrorMessage = "Tiêu đề là bắt buộc")]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string Description { get; set; } = string.Empty;

    public bool IsCompleted { get; set; }
}

public class TodoResponseDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public bool IsCompleted { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
