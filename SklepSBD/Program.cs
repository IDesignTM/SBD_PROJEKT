using Microsoft.EntityFrameworkCore;
using Oracle.ManagedDataAccess.Client;
using System.Data;
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContext<AppDbContext>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapPost("/api/orders", async (int userID, AppDbContext context) =>
{
    try
    {
        var orderIDParam = new OracleParameter("p_order_id", OracleDbType.Decimal, ParameterDirection.Output);

        await context.Database.ExecuteSqlRawAsync("BEGIN OrdersPackage.CreateOrder(:p_user_id, :p_order_id); END;",
            new OracleParameter("p_user_id", userID), orderIDParam);

        var orderID = Convert.ToInt32(orderIDParam.Value.ToString());
        return Results.Ok(new { Status = "Sukces", OrderID = orderID });
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { Blad = ex.Message });
    }
});

app.MapPost("/api/orders/items", async (int orderId, int productId, int quantity, AppDbContext context) =>
{
    try
    {
        await context.Database.ExecuteSqlRawAsync("BEGIN OrdersPackage.AddOrderItem(:p0, :p1, :p2); END;", orderId, productId, quantity);
        return Results.Ok(new { Status = "Sukces", Message = "Produkt został pomyślnie dodany do zamówienia." });
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { Blad = ex.Message });
    }
});

app.MapGet("/api/orders/{id}/total", async (int id, AppDbContext context) =>
{
    try
    {
        var totalParam = new OracleParameter("result", OracleDbType.Decimal, ParameterDirection.Output);
        
        await context.Database.ExecuteSqlRawAsync("BEGIN :result := OrdersPackage.CalculateOrderTotal(:p_id); END;", totalParam, new OracleParameter("p_id", id));

        return Results.Ok(new { OrderId = id, TotalAmount = totalParam.Value.ToString() });
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { Blad = ex.Message });
    }
});

app.Run();

public class AppDbContext : DbContext
{
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseOracle("User Id=ApplicationIdentity;Password=Haslo1234!;Data Source=localhost:1521/XEPDB1;");
    }
}