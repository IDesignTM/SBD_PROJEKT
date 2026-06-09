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
    for i in 1..1000 loop
        insert into Products (Name, Description, Price, StockQuantity, CategoryID)
        values ('Koszulka ' || i, 'Opis koszulki ' || i, 49.99 + (i * 0.1), 20, 1);
    end loop;
    
    commit;
end;
/
begin
    for i in 1..1000 loop
        insert into Products (Name, Description, Price, StockQuantity, CategoryID)
        values ('Spodnie ' || i, 'Opis spodni ' || i, 99.99 + (i * 0.1), 20, 2);
    end loop;
    
    commit;
end;
/
begin
    for i in 1..1000 loop
        insert into Products (Name, Description, Price, StockQuantity, CategoryID)
        values ('Kurtka ' || i, 'Opis kurtki ' || i, 399.99 + (i * 0.1), 20, 3);
    end loop;
    
    commit;
end;
/
begin
    for i in 1..1000 loop
        insert into Products (Name, Description, Price, StockQuantity, CategoryID)
        values ('Buty ' || i, 'Opis butów ' || i, 299.99 + (i * 0.1), 20, 4);
    end loop;
    
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