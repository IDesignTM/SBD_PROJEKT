/* CZYSZCZENIE BAZY */

drop table OrderStatusHistory;
drop table PriceHistory;
drop table OrderItems;
drop table Orders;
drop table Products;
drop table Categories;
drop table Users;
drop table OrderStatus;
drop table Roles;

drop sequence seq_roles;
drop sequence seq_order_status;
drop sequence seq_categories;
drop sequence seq_users;
drop sequence seq_products;
drop sequence seq_orders;
drop sequence seq_order_items;
drop sequence seq_price_hist;
drop sequence seq_order_hist;

drop trigger trg_roles_id;
drop trigger trg_order_status_id;
drop trigger trg_categories_id;
drop trigger trg_users_id;
drop trigger trg_products_id;
drop trigger trg_orders_id;
drop trigger trg_order_items_id;
drop trigger trg_price_history_id;
drop trigger trg_order_history_id;
drop trigger trg_price_history;
drop trigger trg_order_status_history;

/* SEKWENCJE */

create sequence seq_roles;
create sequence seq_order_status;
create sequence seq_categories;
create sequence seq_users;
create sequence seq_products;
create sequence seq_orders;
create sequence seq_order_items;
create sequence seq_price_hist;
create sequence seq_order_hist;

/* TABELE SLOWNIKOWE */

create table Roles (
    ID number primary key,
    RoleName varchar2(50) not null unique
);

create table OrderStatus (
    ID number primary key,
    StatusName varchar2(50) not null unique
);

create table Categories (
    ID number primary key,
    CategoryName varchar2(100) not null unique
);

/* TABELE GLOWNE */

create table Users (
    ID number primary key,
    FirstName varchar2(50) not null,
    LastName varchar2(50) not null,
    Email varchar2(100) not null unique,
    PasswordHash varchar2(256) not null,
    RoleID number not null,
    constraint fk_user_role foreign key (RoleID) references Roles(ID)
);

create table Products (
    ID number primary key,
    Name varchar2(150) not null,
    Description varchar2(1000),
    Price number(10,2) not null check (Price > 0),
    StockQuantity number not null check (StockQuantity >= 0),
    CategoryID number not null,
    constraint fk_product_category foreign key (CategoryID) references Categories(ID)
);

create table Orders (
    ID number primary key,
    UserID number not null,
    StatusID number not null,
    OrderDate date default sysdate not null,
    TotalAmount number(10,2) default 0.00 not null check (TotalAmount >= 0),
    constraint fk_order_user foreign key (UserID) references Users(ID),
    constraint fk_order_status foreign key (StatusID) references OrderStatus(ID)
);

create table OrderItems (
    ID number primary key,
    OrderID number not null,
    ProductID number not null,
    Quantity number not null check (Quantity > 0),
    Price number(10,2) not null check (Price > 0),
    constraint fk_item_order foreign key (OrderID) references Orders(ID),
    constraint fk_item_product foreign key (ProductID) references Products(ID)
);

/* HISTORIA */

create table PriceHistory (
    ID number primary key,
    ProductID number not null,
    OldPrice number(10,2) not null,
    NewPrice number(10,2) not null,
    ChangedAt timestamp default current_timestamp not null,
    constraint fk_price_hist_prod foreign key (ProductID) references Products(ID)
);

create table OrderStatusHistory (
    ID number primary key,
    OrderID number not null,
    OldStatus number,
    NewStatus number not null,
    ChangedAt timestamp default current_timestamp not null,
    constraint fk_order_hist_ord foreign key (OrderID) references Orders(ID)
);

/* TRIGGERY UZUPELNIAJACE ID */

create or replace trigger trg_roles_id
before insert on Roles
for each row
begin
    :new.id := seq_roles.nextval;
end;
/

create or replace trigger trg_order_status_id
before insert on OrderStatus
for each row
begin
    :new.id := seq_order_status.nextval;
end;
/

create or replace trigger trg_categories_id
before insert on Categories
for each row
begin
    :new.id := seq_categories.nextval;
end;
/

create or replace trigger trg_users_id
before insert on Users
for each row
begin
    :new.id := seq_users.nextval;
end;
/

create or replace trigger trg_products_id
before insert on Products
for each row
begin
    :new.id := seq_products.nextval;
end;
/

create or replace trigger trg_orders_id
before insert on Orders for each row
begin
    :new.id := seq_orders.nextval;
end;
/

create or replace trigger trg_order_items_id
before insert on OrderItems
for each row
begin
    :new.id := seq_order_items.nextval;
end;
/

create or replace trigger trg_price_history_id
before insert on PriceHistory
for each row
begin
    :new.id := seq_price_hist.nextval;
end;
/

create or replace trigger trg_order_history_id
before insert on OrderStatusHistory
for each row
begin
    :new.id := seq_order_hist.nextval;
end;
/
/* WSTAWIANIE DANYCH SLOWNIKOWYCH */

insert into Roles (RoleName) values ('User');
insert into Roles (RoleName) values ('Employee');
insert into Roles (RoleName) values ('Admin');

insert into OrderStatus (StatusName) values ('New');
insert into OrderStatus (StatusName) values ('Paid');
insert into OrderStatus (StatusName) values ('Shipped');
insert into OrderStatus (StatusName) values ('Completed');
insert into OrderStatus (StatusName) values ('Cancelled');

insert into Categories (CategoryName) values ('Tops');
insert into Categories (CategoryName) values ('Bottoms');
insert into Categories (CategoryName) values ('Outerwear');
insert into Categories (CategoryName) values ('Shoes');
commit;

/* GENEROWANIE DANYCH TESTOWYCH */

begin
    /* PRODUKTY */
    for i in 1..1000 loop
        insert into Products (Name, Description, Price, StockQuantity, CategoryID)
        values ('Koszulka ' || i, 'Opis koszulki ' || i, 49.99 + (i * 0.1), 20, 1);
    end loop;
    
    for i in 1..1000 loop
        insert into Products (Name, Description, Price, StockQuantity, CategoryID)
        values ('Spodnie ' || i, 'Opis spodni ' || i, 99.99 + (i * 0.1), 20, 2);
    end loop;
    
    for i in 1..1000 loop
        insert into Products (Name, Description, Price, StockQuantity, CategoryID)
        values ('Kurtka ' || i, 'Opis kurtki ' || i, 399.99 + (i * 0.1), 20, 3);
    end loop;
    
    for i in 1..1000 loop
        insert into Products (Name, Description, Price, StockQuantity, CategoryID)
        values ('Buty ' || i, 'Opis butów ' || i, 299.99 + (i * 0.1), 20, 4);
    end loop;

    /* UZYTKOWNICY */
    for i in 1..500 loop
        insert into Users (FirstName, LastName, Email, PasswordHash, RoleID)
        values ('User ' || i, 'Nazwisko ' || i, 'user' || i || '@gmail.com', 'hash_' || i, 1);
    end loop;
    
    /* ZAMOWIENIA */
    for i in 1..750 loop
        insert into Orders (UserID, StatusID, OrderDate, TotalAmount)
        values (mod(i, 500) + 1, mod(i, 5) + 1, sysdate, 0);
        end loop;
        
    /* PRZEDMIOTY W ZAMOWIENIACH */
    for i in 1..1500 loop
        insert into OrderItems (OrderID, ProductID, Quantity, Price)
        values (mod(i, 750) + 1, mod(i, 4000) + 1, mod(i, 5) + 1, 100);
    end loop;
    
    update Orders o
    set o.TotalAmount = ( select nvl(sum(oi.Quantity * oi.Price), 0)
                            from OrderItems oi
                            where o.id = oi.OrderID );
    
    commit;
end;
/
select * from products;

/* INDEKSY */
explain plan for
    select * from products
    where name = 'Koszulka 999';
    
select * from table(dbms_xplan.display());

create index idx_products_name on products(name);

explain plan for
    select * from products
    where name = 'Koszulka 999';
    
select * from table(dbms_xplan.display());

EXPLAIN PLAN FOR
    SELECT c.CategoryName, COUNT(oi.ID) AS TotalSales, SUM(oi.Quantity) AS TotalQty
    FROM Categories c
    JOIN Products p ON c.id = p.CategoryID
    JOIN OrderItems oi ON p.id = oi.ProductID
    WHERE p.Price < (SELECT AVG(Price) FROM Products)
    GROUP BY c.CategoryName;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());

CREATE INDEX idx_prod_cat_price on Products(CategoryID, Price);

EXPLAIN PLAN FOR
    WITH RankedProducts AS ( 
        SELECT id, CategoryID, Price, AVG(Price) OVER () AS AvgPrice
        FROM Products
    )
    SELECT c.CategoryName, COUNT(oi.ID) AS TotalSales, SUM(oi.Quantity) AS TotalQty
    FROM Categories c
    JOIN RankedProducts rp ON c.id = rp.CategoryID
    JOIN OrderItems oi ON rp.id = oi.ProductID
    WHERE rp.Price < rp.AvgPrice
    GROUP BY c.CategoryName;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());

/* WIDOKI */
create or replace view vw_products_catalog as
    select p.id, p.name, p.description, c.categoryname, p.price, p.stockquantity
    from products p
    join categories c on p.categoryid = c.id;
/
    
/* TRIGGERY */
create or replace trigger trg_price_history
after update of price on products
for each row
begin
    insert into pricehistory (productid,  oldprice, newprice)
    values (:old.id, :old.price, :new.price);
end;
/

create or replace trigger trg_order_status_history
after update of statusid on orders
for each row
begin
    insert into orderstatushistory (orderid,  oldstatus, newstatus)
    values (:old.id, :old.statusid, :new.statusid);
end;
/

/* Pakiet */
CREATE OR REPLACE PACKAGE OrdersPackage AS
    PROCEDURE CreateOrder(
        p_user_id IN NUMBER,
        p_order_id OUT NUMBER
    );
    
    PROCEDURE AddOrderItem(
        p_order_id IN NUMBER,
        p_product_id IN NUMBER,
        p_quantity IN NUMBER
    );
    
    PROCEDURE ChangeOrderStatus(
        p_order_id IN NUMBER,
        p_new_status_id IN NUMBER
    );
    
    FUNCTION CalculateOrderTotal(
        p_order_id IN NUMBER
    ) RETURN NUMBER;
    
    FUNCTION CheckProductStock(
        p_product_id IN NUMBER
    ) RETURN NUMBER;
        
END OrdersPackage;
/

CREATE OR REPLACE PACKAGE BODY OrdersPackage AS

    PROCEDURE CreateOrder(
        p_user_id IN NUMBER,
        p_order_id OUT NUMBER
    ) IS
    BEGIN
        INSERT INTO Orders (UserID, StatusID, OrderDate, TotalAmount)
        VALUES (p_user_id, 1, SYSDATE, 0)
        RETURNING ID INTO p_order_id;
    END CreateOrder;

    PROCEDURE AddOrderItem(
        p_order_id IN NUMBER,
        p_product_id IN NUMBER,
        p_quantity IN NUMBER
    ) IS
        v_price Products.Price%TYPE;
        v_stock Products.StockQuantity%TYPE;
    BEGIN
        SELECT Price, StockQuantity
        INTO v_price, v_stock
        FROM Products
        WHERE ID = p_product_id;

        IF v_stock < p_quantity THEN
            RAISE_APPLICATION_ERROR(-20001, 'Brak produktu w magazynie');
        END IF;

        INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price)
        VALUES (p_order_id, p_product_id, p_quantity, v_price);

        UPDATE Products
        SET StockQuantity = StockQuantity - p_quantity
        WHERE ID = p_product_id;
        
        UPDATE Orders
        SET TotalAmount = TotalAmount + (v_price * p_quantity)
        WHERE ID = p_order_id;
    END AddOrderItem;
    
    PROCEDURE ChangeOrderStatus(
        p_order_id IN NUMBER,
        p_new_status_id IN NUMBER
    ) IS
        v_old_status NUMBER;
    BEGIN
        SELECT StatusID
        INTO v_old_status
        FROM Orders
        WHERE ID = p_order_id;

        UPDATE Orders
        SET StatusID = p_new_status_id
        WHERE ID = p_order_id;

    END ChangeOrderStatus;
    
    FUNCTION CalculateOrderTotal(
        p_order_id IN NUMBER
    ) RETURN NUMBER
    IS
        v_total NUMBER;
    BEGIN
        SELECT NVL(SUM(Quantity * Price), 0)
        INTO v_total
        FROM OrderItems
        WHERE OrderID = p_order_id;

        RETURN v_total;
    END CalculateOrderTotal;
    
    FUNCTION CheckProductStock(
        p_product_id IN NUMBER
    ) RETURN NUMBER
    IS
        v_stock Products.StockQuantity%TYPE;
    BEGIN
        SELECT StockQuantity
        INTO v_stock
        FROM Products
        WHERE ID = p_product_id;

        RETURN v_stock;
    END CheckProductStock;
    
END OrdersPackage;
/

/* Konta użytkowników i audyt */
/*
SELECT username, account_status, created 
FROM dba_users 
ORDER BY username;
*/

CREATE USER Admin IDENTIFIED BY "Admin1234!" DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
CREATE USER ApplicationIdentity IDENTIFIED BY "Haslo1234!" DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;

CREATE USER Dev1 IDENTIFIED BY "Dev1234!";
CREATE USER Dev2 IDENTIFIED BY "Dev1234!";

CREATE ROLE db_procexecutor;
GRANT EXECUTE ANY PROCEDURE TO db_procexecutor;

GRANT ALL PRIVILEGES TO Admin;

GRANT SELECT ANY TABLE, INSERT ANY TABLE, UPDATE ANY TABLE, DELETE ANY TABLE TO ApplicationIdentity;
GRANT db_procexecutor TO ApplicationIdentity;
GRANT CREATE SESSION TO ApplicationIdentity;

GRANT CREATE SESSION TO Dev1;
GRANT SELECT ANY TABLE TO Dev1;

GRANT CREATE SESSION TO Dev2;
GRANT SELECT ANY TABLE TO Dev2;

CREATE AUDIT POLICY sklep_audyt
ACTIONS 
    SELECT,
    INSERT,
    UPDATE,
    DELETE;
    
AUDIT POLICY sklep_audyt;

SELECT event_timestamp, 
       dbusername, 
       action_name, 
       object_schema, 
       object_name, 
       sql_text
FROM UNIFIED_AUDIT_TRAIL
ORDER BY event_timestamp DESC;

select * from orders;
select * from orderitems;
/* DECLARE
    v_order_id NUMBER;
BEGIN
    OrdersPackage.CreateOrder(1, v_order_id);
    OrdersPackage.AddOrderItem(v_order_id, 2, 2);
END;
/

EXECUTE OrdersPackage.ChangeOrderStatus(6,5);

SELECT OrdersPackage.CalculateOrderTotal(6)
FROM DUAL;

SELECT OrdersPackage.CheckProductStock(1)
FROM dual; */