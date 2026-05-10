using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TodoApi.Data;
using TodoApi.Models;
using TodoApi.Services;

namespace TodoApi.Controllers;

[ApiController]
[Route("api/todos")]
[Authorize]
public class TodosController : ControllerBase
{
    private readonly AppDbContext _db;

    public TodosController(AppDbContext db)
    {
        _db = db;
    }

    private int CurrentUserId => JwtService.GetUserId(User);

    // GET /api/todos
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var todos = await _db.Todos
            .Where(t => t.UserId == CurrentUserId)
            .OrderByDescending(t => t.CreatedAt)
            .Select(t => new TodoResponseDto
            {
                Id = t.Id,
                Title = t.Title,
                Description = t.Description,
                IsCompleted = t.IsCompleted,
                CreatedAt = t.CreatedAt,
                UpdatedAt = t.UpdatedAt,
            })
            .ToListAsync();

        return Ok(new { todos });
    }

    // GET /api/todos/{id}
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var todo = await _db.Todos
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == CurrentUserId);

        if (todo == null) return NotFound(new { message = "Không tìm thấy todo" });

        return Ok(new { todo = MapToDto(todo) });
    }

    // POST /api/todos
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTodoDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var todo = new Todo
        {
            Title = dto.Title,
            Description = dto.Description,
            UserId = CurrentUserId,
        };

        _db.Todos.Add(todo);
        await _db.SaveChangesAsync();

        return StatusCode(201, new { todo = MapToDto(todo) });
    }

    // PUT /api/todos/{id}
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateTodoDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var todo = await _db.Todos
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == CurrentUserId);

        if (todo == null) return NotFound(new { message = "Không tìm thấy todo" });

        todo.Title = dto.Title;
        todo.Description = dto.Description;
        todo.IsCompleted = dto.IsCompleted;
        todo.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();

        return Ok(new { todo = MapToDto(todo) });
    }

    // DELETE /api/todos/{id}
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var todo = await _db.Todos
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == CurrentUserId);

        if (todo == null) return NotFound(new { message = "Không tìm thấy todo" });

        _db.Todos.Remove(todo);
        await _db.SaveChangesAsync();

        return Ok(new { message = "Đã xoá todo thành công" });
    }

    // PATCH /api/todos/{id}/toggle
    [HttpPatch("{id:int}/toggle")]
    public async Task<IActionResult> Toggle(int id)
    {
        var todo = await _db.Todos
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == CurrentUserId);

        if (todo == null) return NotFound(new { message = "Không tìm thấy todo" });

        todo.IsCompleted = !todo.IsCompleted;
        todo.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();

        return Ok(new { todo = MapToDto(todo) });
    }

    private static TodoResponseDto MapToDto(Todo t) => new()
    {
        Id = t.Id,
        Title = t.Title,
        Description = t.Description,
        IsCompleted = t.IsCompleted,
        CreatedAt = t.CreatedAt,
        UpdatedAt = t.UpdatedAt,
    };
}
