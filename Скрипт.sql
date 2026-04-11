


-- Очистка базы данных (выполняется в начале)
DROP TABLE IF EXISTS Employee_Room;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Service_In_Bill;
DROP TABLE IF EXISTS Service_Bill;
DROP TABLE IF EXISTS Stay;
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Fines;
DROP TABLE IF EXISTS Fine_Types;
DROP TABLE IF EXISTS Service_Types;
DROP TABLE IF EXISTS Guests;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Employee_Roles;
DROP TABLE IF EXISTS Tariffs;
DROP TABLE IF EXISTS Rooms;
DROP TABLE IF EXISTS Room_Views;
DROP TABLE IF EXISTS Room_Types;
DROP TABLE IF EXISTS Hotels;
DROP TABLE IF EXISTS Localities;
DROP TABLE IF EXISTS Regions;
DROP TABLE IF EXISTS Type;
DROP TABLE IF EXISTS Owners;

-- Создание таблиц
CREATE TABLE Owners (
    owner_id SERIAL,
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    middle_name TEXT,
    passport_data TEXT NOT NULL,
    birth_date DATE NOT NULL
);

ALTER TABLE Owners 
ADD CONSTRAINT PK_Owners 
    PRIMARY KEY (owner_id);

CREATE TABLE Type (
    type_id SERIAL,
    name TEXT NOT NULL
);

ALTER TABLE Type 
ADD CONSTRAINT PK_Type 
    PRIMARY KEY (type_id);

ALTER TABLE Type 
ADD CONSTRAINT U_Type_name
    UNIQUE(name);

CREATE TABLE Regions (
    region_id SERIAL,
    name TEXT NOT NULL
);

ALTER TABLE Regions 
ADD CONSTRAINT PK_Regions 
    PRIMARY KEY (region_id);

ALTER TABLE Regions 
ADD CONSTRAINT U_Regions_name
    UNIQUE(name);

CREATE TABLE Room_Types (
    room_type_id SERIAL,
    name TEXT NOT NULL,
    class TEXT NOT NULL,
    description TEXT,
    number_of_places SMALLINT NOT NULL
);

ALTER TABLE Room_Types 
ADD CONSTRAINT PK_Room_Types 
    PRIMARY KEY (room_type_id);

ALTER TABLE Room_Types 
ADD CONSTRAINT U_Room_Types_name
    UNIQUE(name);

ALTER TABLE Room_Types 
ADD CONSTRAINT CH_Room_Types_number_of_places
    CHECK (number_of_places > 0);

CREATE TABLE Room_Views (
    view_id SERIAL,
    location TEXT NOT NULL
);

ALTER TABLE Room_Views 
ADD CONSTRAINT PK_Room_Views 
    PRIMARY KEY (view_id);

ALTER TABLE Room_Views 
ADD CONSTRAINT U_Room_Views_location
    UNIQUE(location);

CREATE TABLE Employee_Roles (
    role_id SERIAL,
    role_name TEXT NOT NULL
);

ALTER TABLE Employee_Roles 
ADD CONSTRAINT PK_Employee_Roles 
    PRIMARY KEY (role_id);

ALTER TABLE Employee_Roles 
ADD CONSTRAINT U_Employee_Roles_role_name
    UNIQUE(role_name);

CREATE TABLE Service_Types (
    service_type_id SERIAL,
    name TEXT NOT NULL,
    description TEXT
);

ALTER TABLE Service_Types 
ADD CONSTRAINT PK_Service_Types 
    PRIMARY KEY (service_type_id);

ALTER TABLE Service_Types 
ADD CONSTRAINT U_Service_Types_name
    UNIQUE(name);

CREATE TABLE Fine_Types (
    fine_type_id SERIAL,
    name TEXT NOT NULL,
    description TEXT
);

ALTER TABLE Fine_Types 
ADD CONSTRAINT PK_Fine_Types 
    PRIMARY KEY (fine_type_id);

ALTER TABLE Fine_Types 
ADD CONSTRAINT U_Fine_Types_name
    UNIQUE(name);


CREATE TABLE Localities (
    locality_id SERIAL,
    name TEXT NOT NULL,
    region_id INT NOT NULL,
    type_id INT 
);

ALTER TABLE Localities 
ADD CONSTRAINT PK_Localities 
    PRIMARY KEY (locality_id);

ALTER TABLE Localities 
ADD CONSTRAINT U_Localities_name
    UNIQUE(name);

CREATE TABLE Hotels (
    hotel_id SERIAL,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    opening_year SMALLINT NOT NULL,
    owner_id INT NOT NULL,
    street TEXT NOT NULL,
    building_number TEXT NOT NULL,
    area DECIMAL(10,2) NOT NULL,
    locality_id INT NOT NULL
);

ALTER TABLE Hotels 
ADD CONSTRAINT PK_Hotels 
    PRIMARY KEY (hotel_id);

ALTER TABLE Hotels 
ADD CONSTRAINT U_Hotels_name
    UNIQUE(name);
ALTER TABLE Hotels 
ADD CONSTRAINT CH_Hotels_opening_year
    CHECK (opening_year > 1900);

ALTER TABLE Hotels 
ADD CONSTRAINT CH_Hotels_area
    CHECK (area > 0);

CREATE TABLE Tariffs (
    tariff_id SERIAL,
    daily_price DECIMAL(10,2) NOT NULL,
    description TEXT,
    room_type_id INT NOT NULL,
    start_date DATE NOT NULL
);

ALTER TABLE Tariffs 
ADD CONSTRAINT PK_Tariffs 
    PRIMARY KEY (tariff_id);

ALTER TABLE Tariffs 
ADD CONSTRAINT CH_Tariffs_daily_price
    CHECK (daily_price > 0);

CREATE TABLE Rooms (
    room_id SERIAL,
    floor SMALLINT NOT NULL,
    room_number TEXT NOT NULL,
    hotel_id INT NOT NULL,
    view_id INT NOT NULL,
    room_type_id INT NOT NULL
);

ALTER TABLE Rooms 
ADD CONSTRAINT PK_Rooms 
    PRIMARY KEY (room_id);

ALTER TABLE Rooms 
ADD CONSTRAINT CH_Rooms_floor
    CHECK (floor > 0);

ALTER TABLE Rooms 
ADD CONSTRAINT U_Rooms_room_number_hotel_id
    UNIQUE(room_number, hotel_id);

CREATE TABLE Employees (
    employee_id SERIAL,
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    middle_name TEXT,
    passport_data TEXT NOT NULL,
    work_type TEXT NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    birth_date DATE NOT NULL
);

ALTER TABLE Employees 
ADD CONSTRAINT PK_Employees 
    PRIMARY KEY (employee_id);

ALTER TABLE Employees 
ADD CONSTRAINT CH_Employees_salary
    CHECK (salary > 0);

CREATE TABLE Guests (
    guest_id SERIAL,
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    middle_name TEXT,
    passport_data TEXT NOT NULL,
    birth_date DATE NOT NULL
);

ALTER TABLE Guests 
ADD CONSTRAINT PK_Guests 
    PRIMARY KEY (guest_id);

CREATE TABLE Fines (
    fine_id SERIAL,
    amount DECIMAL(10,2) NOT NULL,
    fine_date DATE NOT NULL,
    fine_type_id INT NOT NULL
);

ALTER TABLE Fines 
ADD CONSTRAINT PK_Fines 
    PRIMARY KEY (fine_id);

ALTER TABLE Fines 
ADD CONSTRAINT CH_Fines_amount
    CHECK (amount >= 0);

CREATE TABLE Employee_Room (
    room_id INT NOT NULL,
    employee_id INT NOT NULL
);

ALTER TABLE Employee_Room 
ADD CONSTRAINT PK_Employee_Room 
    PRIMARY KEY (room_id, employee_id);

CREATE TABLE Stay (
    stay_id SERIAL,
    check_in_date_actual DATE NOT NULL,
    check_out_date_actual DATE NOT NULL,
    check_in_date_planned DATE NOT NULL,
    check_out_date_planned DATE NOT NULL,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    fine_id INT,
    tariff_id INT NOT NULL
);

ALTER TABLE Stay 
ADD CONSTRAINT PK_Stay 
    PRIMARY KEY (stay_id);

ALTER TABLE Stay 
ADD CONSTRAINT CH_Stay_actual_dates
    CHECK (check_out_date_actual >= check_in_date_actual);

ALTER TABLE Stay 
ADD CONSTRAINT CH_Stay_planned_dates
    CHECK (check_out_date_planned >= check_in_date_planned);

CREATE TABLE Service_Bill (
    service_bill_id SERIAL,
    bill_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    stay_id INT NOT NULL
);

ALTER TABLE Service_Bill 
ADD CONSTRAINT PK_Service_Bill 
    PRIMARY KEY (service_bill_id);

ALTER TABLE Service_Bill 
ADD CONSTRAINT CH_Service_Bill_amount
    CHECK (amount >= 0);

CREATE TABLE Service_In_Bill (
    service_in_bill_id SERIAL,
    service_type_id INT NOT NULL,
    quantity SMALLINT NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    service_bill_id INT NOT NULL
);

ALTER TABLE Service_In_Bill 
ADD CONSTRAINT PK_Service_In_Bill 
    PRIMARY KEY (service_in_bill_id);

ALTER TABLE Service_In_Bill 
ADD CONSTRAINT CH_Service_In_Bill_quantity
    CHECK (quantity > 0);

ALTER TABLE Service_In_Bill 
ADD CONSTRAINT CH_Service_In_Bill_cost
    CHECK (cost >= 0);


ALTER TABLE Localities 
ADD CONSTRAINT FK_Localities_Regions 
    FOREIGN KEY (region_id) REFERENCES Regions(region_id);

ALTER TABLE Localities 
ADD CONSTRAINT FK_Localities_Type 
    FOREIGN KEY (type_id) REFERENCES Type(type_id);

ALTER TABLE Hotels 
ADD CONSTRAINT FK_Hotels_Owners 
    FOREIGN KEY (owner_id) REFERENCES Owners(owner_id);

ALTER TABLE Hotels 
ADD CONSTRAINT FK_Hotels_Localities 
    FOREIGN KEY (locality_id) REFERENCES Localities(locality_id);

ALTER TABLE Tariffs 
ADD CONSTRAINT FK_Tariffs_Room_Types 
    FOREIGN KEY (room_type_id) REFERENCES Room_Types(room_type_id);

ALTER TABLE Rooms 
ADD CONSTRAINT FK_Rooms_Hotels 
    FOREIGN KEY (hotel_id) REFERENCES Hotels(hotel_id);

ALTER TABLE Rooms 
ADD CONSTRAINT FK_Rooms_Room_Views 
    FOREIGN KEY (view_id) REFERENCES Room_Views(view_id);

ALTER TABLE Rooms 
ADD CONSTRAINT FK_Rooms_Room_Types 
    FOREIGN KEY (room_type_id) REFERENCES Room_Types(room_type_id);

ALTER TABLE Employee_Room 
ADD CONSTRAINT FK_Employee_Room_Rooms 
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id);

ALTER TABLE Employee_Room 
ADD CONSTRAINT FK_Employee_Room_Employees 
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id);

ALTER TABLE Stay 
ADD CONSTRAINT FK_Stay_Guests 
    FOREIGN KEY (guest_id) REFERENCES Guests(guest_id);

ALTER TABLE Stay 
ADD CONSTRAINT FK_Stay_Rooms 
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id);

ALTER TABLE Stay 
ADD CONSTRAINT FK_Stay_Fines 
    FOREIGN KEY (fine_id) REFERENCES Fines(fine_id);

ALTER TABLE Stay 
ADD CONSTRAINT FK_Stay_Tariffs 
    FOREIGN KEY (tariff_id) REFERENCES Tariffs(tariff_id);

ALTER TABLE Fines 
ADD CONSTRAINT FK_Fines_Fine_Types 
    FOREIGN KEY (fine_type_id) REFERENCES Fine_Types(fine_type_id);

ALTER TABLE Service_Bill 
ADD CONSTRAINT FK_Service_Bill_Stay 
    FOREIGN KEY (stay_id) REFERENCES Stay(stay_id);

ALTER TABLE Service_In_Bill 
ADD CONSTRAINT FK_Service_In_Bill_Service_Types 
    FOREIGN KEY (service_type_id) REFERENCES Service_Types(service_type_id);

ALTER TABLE Service_In_Bill 
ADD CONSTRAINT FK_Service_In_Bill_Service_Bill 
    FOREIGN KEY (service_bill_id) REFERENCES Service_Bill(service_bill_id);
TRUNCATE TABLE 
    Service_In_Bill,
    Service_Bill,
    Stay,
    Employee_Room,
    Fines,
    Guests,
    Employees,
    Rooms,
    Tariffs,
    Hotels,
    Localities,
    Owners,
    Fine_Types,
    Service_Types,
    Employee_Roles,
    Room_Views,
    Room_Types,
    Regions,
    Type
RESTART IDENTITY CASCADE;

INSERT INTO Type (name) VALUES
('город'),
('поселок городского типа'),
('деревня'),
('село'),
('не указан');

INSERT INTO Regions (name) VALUES
('Московская область'),
('Ленинградская область'),
('Краснодарский край'),
('Крым');

INSERT INTO Room_Types (name, class, description, number_of_places) VALUES
('Люкс', 'премиум', 'Просторный номер с улучшенной отделкой', 3),
('Стандарт', 'эконом', 'Комфортный номер по доступной цене', 2),
('Семейный', 'бизнес', 'Номер для семейного отдыха', 4),
('Делюкс', 'премиум', 'Улучшенный стандарт', 2);

INSERT INTO Room_Views (location) VALUES
('Море'),
('Горы'),
('Город'),
('Парк'),
('Бассейн');

INSERT INTO Employee_Roles (role_name) VALUES
('Горничная'),
('Портье'),
('Менеджер'),
('Технический специалист'),
('Администратор'),
('Уборщик-ремонтник'),
('Специалист по обслуживанию'),
('Консьерж');

INSERT INTO Service_Types (name, description) VALUES
('Завтрак', 'Континентальный завтрак'),
('Ужин', 'Трехразовое питание'),
('СПА', 'Спа-процедуры'),
('Трансфер', 'Трансфер из аэропорта'),
('Экскурсия', 'Обзорная экскурсия'),
('Прачечная', 'Стирка и глажка белья'),
('Фитнес', 'Посещение фитнес-зала'),
('Бар', 'Мини-бар в номере'),
('Парковка', 'Парковочное место'),
('Бизнес-центр', 'Рабочее место с ПК');

INSERT INTO Fine_Types (name, description) VALUES
('Порча имущества', 'Повреждение мебели или оборудования'),
('Курение', 'Курение в номере'),
('Шум', 'Нарушение тишины в ночное время'),
('Потеря ключа', 'Утеря ключа от номера'),
('Просрочка выезда', 'Несвоевременный выезд');

INSERT INTO Owners (last_name, first_name, middle_name, passport_data, birth_date) VALUES
('Иванов', 'Иван', 'Иванович', '4501 123456', '1985-05-15'),
('Петров-Сидоров', 'Алексей', 'Викторович', '4501 654321', '1992-12-20'),
('Кузнецова', 'Мария', 'Сергеевна', '4501 789012', '1978-08-10'),
('Смирнова', 'Ольга', 'Дмитриевна', '4501 345678', '1990-02-28'),
('Васильев', 'Дмитрий', 'Алексеевич', '4501 901234', '1988-11-15');

INSERT INTO Localities (name, region_id, type_id) VALUES
('Москва', (SELECT region_id FROM Regions WHERE name = 'Московская область'), (SELECT type_id FROM Type WHERE name = 'город')),
('Санкт-Петербург', (SELECT region_id FROM Regions WHERE name = 'Ленинградская область'), (SELECT type_id FROM Type WHERE name = 'город')),
('Сочи', (SELECT region_id FROM Regions WHERE name = 'Краснодарский край'), (SELECT type_id FROM Type WHERE name = 'город')),
('Адлер', (SELECT region_id FROM Regions WHERE name = 'Краснодарский край'), (SELECT type_id FROM Type WHERE name = 'город')),
('Ялта', (SELECT region_id FROM Regions WHERE name = 'Крым'), (SELECT type_id FROM Type WHERE name = 'город')),
('Симферополь', (SELECT region_id FROM Regions WHERE name = 'Крым'), (SELECT type_id FROM Type WHERE name = 'город')),
('Поселок без отеля', (SELECT region_id FROM Regions WHERE name = 'Московская область'), (SELECT type_id FROM Type WHERE name = 'поселок городского типа')),
-- ИЗМЕНЕНИЕ: вместо типа "не указан" устанавливаем NULL
('Деревня без типа', (SELECT region_id FROM Regions WHERE name = 'Ленинградская область'), NULL);

INSERT INTO Hotels (name, email, opening_year, owner_id, street, building_number, area, locality_id) VALUES
('Морская звезда', 'sea_star@mail.ru', 2015, (SELECT owner_id FROM Owners WHERE last_name = 'Иванов' AND first_name = 'Иван'), 'Курортный проспект', '15А', 2500.50, (SELECT locality_id FROM Localities WHERE name = 'Сочи')),
('Горный воздух', 'mountain_air@mail.ru', 2018, (SELECT owner_id FROM Owners WHERE last_name = 'Иванов' AND first_name = 'Иван'), 'Ленина', '42', 1800.75, (SELECT locality_id FROM Localities WHERE name = 'Сочи')),
('Столичный', 'capital@mail.ru', 2010, (SELECT owner_id FROM Owners WHERE last_name = 'Петров-Сидоров' AND first_name = 'Алексей'), 'Тверская', '25', 3200.00, (SELECT locality_id FROM Localities WHERE name = 'Москва')),
('Нева', 'neva@mail.ru', 2012, (SELECT owner_id FROM Owners WHERE last_name = 'Смирнова' AND first_name = 'Ольга'), 'Невский проспект', '10', 2800.00, (SELECT locality_id FROM Localities WHERE name = 'Санкт-Петербург')),
('Южный', 'southern@mail.ru', 2019, (SELECT owner_id FROM Owners WHERE last_name = 'Иванов' AND first_name = 'Иван'), 'Приморская', '5', 2200.00, (SELECT locality_id FROM Localities WHERE name = 'Адлер')),
('Ялта-Палас', 'yalta_palace@mail.ru', 2017, (SELECT owner_id FROM Owners WHERE last_name = 'Смирнова' AND first_name = 'Ольга'), 'Набережная', '33', 3500.00, (SELECT locality_id FROM Localities WHERE name = 'Ялта'));

INSERT INTO Tariffs (daily_price, description, room_type_id, start_date) VALUES
(5000.00, 'Высокий сезон', (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс'), '2024-01-01'),
(3500.00, 'Стандартный тариф', (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт'), '2024-01-01'),
(4500.00, 'Семейный тариф', (SELECT room_type_id FROM Room_Types WHERE name = 'Семейный'), '2024-01-01'),
(4000.00, 'Низкий сезон', (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс'), '2024-11-01'),
(6000.00, 'Пиковый сезон', (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс'), '2024-07-01'),
(3000.00, 'Эконом', (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт'), '2024-01-01');

INSERT INTO Rooms (floor, room_number, hotel_id, view_id, room_type_id) VALUES
-- Отель "Морская звезда" (6 номеров)
(2, '201', (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс')),
(2, '202', (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс')),
(3, '301', (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(3, '302', (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(4, '401', (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Семейный')),
(4, '402', (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Семейный')),
-- Отель "Горный воздух" (4 номера)
(1, '101', (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух'), (SELECT view_id FROM Room_Views WHERE location = 'Горы'), (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс')),
(1, '102', (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух'), (SELECT view_id FROM Room_Views WHERE location = 'Горы'), (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(2, '201', (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух'), (SELECT view_id FROM Room_Views WHERE location = 'Город'), (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(2, '202', (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух'), (SELECT view_id FROM Room_Views WHERE location = 'Город'), (SELECT room_type_id FROM Room_Types WHERE name = 'Семейный')),
-- Отель "Столичный" (5 номеров)
(5, '501', (SELECT hotel_id FROM Hotels WHERE name = 'Столичный'), (SELECT view_id FROM Room_Views WHERE location = 'Город'), (SELECT room_type_id FROM Room_Types WHERE name = 'Семейный')),
(5, '502', (SELECT hotel_id FROM Hotels WHERE name = 'Столичный'), (SELECT view_id FROM Room_Views WHERE location = 'Город'), (SELECT room_type_id FROM Room_Types WHERE name = 'Семейный')),
(6, '601', (SELECT hotel_id FROM Hotels WHERE name = 'Столичный'), (SELECT view_id FROM Room_Views WHERE location = 'Город'), (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс')),
(6, '602', (SELECT hotel_id FROM Hotels WHERE name = 'Столичный'), (SELECT view_id FROM Room_Views WHERE location = 'Город'), (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(7, '701', (SELECT hotel_id FROM Hotels WHERE name = 'Столичный'), (SELECT view_id FROM Room_Views WHERE location = 'Парк'), (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс')),
-- Отель "Нева" (3 номера)
(3, '301', (SELECT hotel_id FROM Hotels WHERE name = 'Нева'), (SELECT view_id FROM Room_Views WHERE location = 'Парк'), (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(3, '302', (SELECT hotel_id FROM Hotels WHERE name = 'Нева'), (SELECT view_id FROM Room_Views WHERE location = 'Парк'), (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(4, '401', (SELECT hotel_id FROM Hotels WHERE name = 'Нева'), (SELECT view_id FROM Room_Views WHERE location = 'Парк'), (SELECT room_type_id FROM Room_Types WHERE name = 'Семейный')),
-- Отель "Южный" (4 номера)
(2, '201', (SELECT hotel_id FROM Hotels WHERE name = 'Южный'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс')),
(2, '202', (SELECT hotel_id FROM Hotels WHERE name = 'Южный'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(3, '301', (SELECT hotel_id FROM Hotels WHERE name = 'Южный'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(3, '302', (SELECT hotel_id FROM Hotels WHERE name = 'Южный'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Семейный')),
-- Отель "Ялта-Палас" (4 номера)
(1, '101', (SELECT hotel_id FROM Hotels WHERE name = 'Ялта-Палас'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс')),
(1, '102', (SELECT hotel_id FROM Hotels WHERE name = 'Ялта-Палас'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс')),
(2, '201', (SELECT hotel_id FROM Hotels WHERE name = 'Ялта-Палас'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Семейный')),
(2, '202', (SELECT hotel_id FROM Hotels WHERE name = 'Ялта-Палас'), (SELECT view_id FROM Room_Views WHERE location = 'Море'), (SELECT room_type_id FROM Room_Types WHERE name = 'Делюкс'));

INSERT INTO Employees (last_name, first_name, middle_name, passport_data, work_type, salary, birth_date) VALUES
('Смирнова-Иванова', 'Елена', 'Петровна', '4511 111111', 'полная', 45000.00, '1990-05-20'),
('Козлова', 'Анна', 'Александровна', '4511 222222', 'полная', 55000.00, '1985-12-10'),
('Новикова', 'Ирина', NULL, '4511 333333', 'сменная', 38000.00, '1992-08-15'),
('Петрова', 'Мария', 'Дмитриевна', '4511 444444', 'полная', 42000.00, '1988-03-25'),
('Сидорова', 'Ольга', 'Викторовна', '4511 555555', 'сменная', 35000.00, '1995-11-30'),
('Васильева', 'Татьяна', 'Алексеевна', '4511 666666', 'полная', 48000.00, '1987-07-12');

INSERT INTO Guests (last_name, first_name, middle_name, passport_data, birth_date) VALUES
('Попов', 'Андрей', 'Викторович', '4512 444444', '1982-12-12'),
('Ковалева', 'Мария', 'Дмитриевна', '4512 555555', '1991-01-25'),
('Федоров', 'Сергей', 'Павлович', '4512 666666', '1978-02-03'),
('Иванов', 'Алексей', 'Сергеевич', '4512 777777', '1985-06-15'),
('Петров', 'Дмитрий', 'Игоревич', '4512 888888', '1990-09-20'),
('Сидорова', 'Елена', 'Владимировна', '4512 999999', '1988-03-10'),
('Кузнецов', 'Михаил', 'Анатольевич', '4512 000000', '1975-11-05'),
('Иванов', 'Иван', 'Иванович', '4512 111111', '1980-04-18'),
('Морозова', 'Наталья', 'Сергеевна', '4512 222222', '1992-07-22'),
('Соколов', 'Владимир', 'Петрович', '4512 333333', '1983-08-14'),
('Лебедева', 'Анна', 'Викторовна', '4512 444444', '1993-10-30'),
('Новиков', 'Петр', 'Сергеевич', '4512 555555', '1987-03-15');
INSERT INTO Fines (amount, fine_date, fine_type_id) VALUES
(2000.00, '2022-05-15', (SELECT fine_type_id FROM Fine_Types WHERE name = 'Порча имущества')),
(1000.00, '2023-06-20', (SELECT fine_type_id FROM Fine_Types WHERE name = 'Курение')),
(1500.00, '2023-07-10', (SELECT fine_type_id FROM Fine_Types WHERE name = 'Шум')),
(3000.00, '2024-01-15', (SELECT fine_type_id FROM Fine_Types WHERE name = 'Порча имущества')),
(1200.00, '2024-02-20', (SELECT fine_type_id FROM Fine_Types WHERE name = 'Потеря ключа')),
(1800.00, '2024-03-05', (SELECT fine_type_id FROM Fine_Types WHERE name = 'Курение'));

INSERT INTO Employee_Room (room_id, employee_id) VALUES
((SELECT room_id FROM Rooms WHERE room_number = '201' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), (SELECT employee_id FROM Employees WHERE last_name = 'Смирнова-Иванова')),
((SELECT room_id FROM Rooms WHERE room_number = '202' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), (SELECT employee_id FROM Employees WHERE last_name = 'Смирнова-Иванова')),
((SELECT room_id FROM Rooms WHERE room_number = '301' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), (SELECT employee_id FROM Employees WHERE last_name = 'Козлова')),
((SELECT room_id FROM Rooms WHERE room_number = '302' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), (SELECT employee_id FROM Employees WHERE last_name = 'Козлова')),
((SELECT room_id FROM Rooms WHERE room_number = '401' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), (SELECT employee_id FROM Employees WHERE last_name = 'Новикова')),
((SELECT room_id FROM Rooms WHERE room_number = '402' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), (SELECT employee_id FROM Employees WHERE last_name = 'Новикова')),
((SELECT room_id FROM Rooms WHERE room_number = '101' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух')), (SELECT employee_id FROM Employees WHERE last_name = 'Петрова')),
((SELECT room_id FROM Rooms WHERE room_number = '102' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух')), (SELECT employee_id FROM Employees WHERE last_name = 'Петрова')),
((SELECT room_id FROM Rooms WHERE room_number = '201' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух')), (SELECT employee_id FROM Employees WHERE last_name = 'Сидорова')),
((SELECT room_id FROM Rooms WHERE room_number = '202' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух')), (SELECT employee_id FROM Employees WHERE last_name = 'Сидорова')),
((SELECT room_id FROM Rooms WHERE room_number = '501' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Столичный')), (SELECT employee_id FROM Employees WHERE last_name = 'Васильева')),
((SELECT room_id FROM Rooms WHERE room_number = '502' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Столичный')), (SELECT employee_id FROM Employees WHERE last_name = 'Васильева'));

INSERT INTO Stay (check_in_date_actual, check_out_date_actual, check_in_date_planned, check_out_date_planned, guest_id, room_id, fine_id, tariff_id) VALUES
-- Проживания в прошлом
('2023-01-15', '2023-01-20', '2023-01-15', '2023-01-20', (SELECT guest_id FROM Guests WHERE last_name = 'Попов' AND first_name = 'Андрей'), (SELECT room_id FROM Rooms WHERE room_number = '201' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), (SELECT fine_id FROM Fines WHERE amount = 2000.00), (SELECT tariff_id FROM Tariffs WHERE daily_price = 5000.00)),
('2023-02-10', '2023-02-15', '2023-02-10', '2023-02-15', (SELECT guest_id FROM Guests WHERE last_name = 'Ковалева' AND first_name = 'Мария'), (SELECT room_id FROM Rooms WHERE room_number = '202' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), NULL, (SELECT tariff_id FROM Tariffs WHERE daily_price = 3500.00)),
('2023-03-05', '2023-03-10', '2023-03-05', '2023-03-10', (SELECT guest_id FROM Guests WHERE last_name = 'Федоров' AND first_name = 'Сергей'), (SELECT room_id FROM Rooms WHERE room_number = '301' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), (SELECT fine_id FROM Fines WHERE amount = 1000.00), (SELECT tariff_id FROM Tariffs WHERE daily_price = 4500.00)),
-- Многократные проживания одного гостя
('2025-04-01', '2025-04-05', '2025-04-01', '2025-04-05', (SELECT guest_id FROM Guests WHERE last_name = 'Иванов' AND first_name = 'Алексей'), (SELECT room_id FROM Rooms WHERE room_number = '302' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), NULL, (SELECT tariff_id FROM Tariffs WHERE daily_price = 5000.00)),
('2025-06-10', '2025-06-15', '2025-06-10', '2025-06-15', (SELECT guest_id FROM Guests WHERE last_name = 'Иванов' AND first_name = 'Алексей'), (SELECT room_id FROM Rooms WHERE room_number = '401' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), (SELECT fine_id FROM Fines WHERE amount = 1500.00), (SELECT tariff_id FROM Tariffs WHERE daily_price = 3500.00)),
('2025-09-20', '2025-09-25', '2025-09-20', '2025-09-25', (SELECT guest_id FROM Guests WHERE last_name = 'Иванов' AND first_name = 'Алексей'), (SELECT room_id FROM Rooms WHERE room_number = '402' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), NULL, (SELECT tariff_id FROM Tariffs WHERE daily_price = 4500.00)),
-- Проживания с штрафами
('2023-05-10', '2023-05-15', '2023-05-10', '2023-05-15', (SELECT guest_id FROM Guests WHERE last_name = 'Петров' AND first_name = 'Дмитрий'), (SELECT room_id FROM Rooms WHERE room_number = '101' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух')), (SELECT fine_id FROM Fines WHERE amount = 3000.00), (SELECT tariff_id FROM Tariffs WHERE daily_price = 5000.00)),
('2023-08-15', '2023-08-20', '2023-08-15', '2023-08-20', (SELECT guest_id FROM Guests WHERE last_name = 'Петров' AND first_name = 'Дмитрий'), (SELECT room_id FROM Rooms WHERE room_number = '102' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух')), (SELECT fine_id FROM Fines WHERE amount = 1200.00), (SELECT tariff_id FROM Tariffs WHERE daily_price = 3500.00)),
-- Проживания в разных отелях одного населенного пункта
('2025-07-01', '2025-07-05', '2025-07-01', '2025-07-05', (SELECT guest_id FROM Guests WHERE last_name = 'Сидорова' AND first_name = 'Елена'), (SELECT room_id FROM Rooms WHERE room_number = '201' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), NULL, (SELECT tariff_id FROM Tariffs WHERE daily_price = 5000.00)),
('2025-10-10', '2025-10-15', '2025-10-10', '2025-10-15', (SELECT guest_id FROM Guests WHERE last_name = 'Сидорова' AND first_name = 'Елена'), (SELECT room_id FROM Rooms WHERE room_number = '201' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух')), NULL, (SELECT tariff_id FROM Tariffs WHERE daily_price = 3500.00)),
-- Проживания в текущем месяце
('2025-11-17', '2025-11-25', '2025-11-17', '2025-11-25', (SELECT guest_id FROM Guests WHERE last_name = 'Кузнецов' AND first_name = 'Михаил'), (SELECT room_id FROM Rooms WHERE room_number = '201' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух')), NULL, (SELECT tariff_id FROM Tariffs WHERE daily_price = 5000.00)),
('2025-11-12', '2025-12-01', '2025-11-12', '2025-12-01', (SELECT guest_id FROM Guests WHERE last_name = 'Иванов' AND first_name = 'Иван'), (SELECT room_id FROM Rooms WHERE room_number = '202' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух')), (SELECT fine_id FROM Fines WHERE amount = 1800.00), (SELECT tariff_id FROM Tariffs WHERE daily_price = 3500.00)),
-- Бронирования на будущее
('2025-12-17', '2025-12-25', '2025-12-17', '2025-12-25', (SELECT guest_id FROM Guests WHERE last_name = 'Морозова' AND first_name = 'Наталья'), (SELECT room_id FROM Rooms WHERE room_number = '501' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Столичный')), NULL, (SELECT tariff_id FROM Tariffs WHERE daily_price = 4500.00)),
('2025-12-12', '2025-12-20', '2025-12-12', '2025-12-20', (SELECT guest_id FROM Guests WHERE last_name = 'Соколов' AND first_name = 'Владимир'), (SELECT room_id FROM Rooms WHERE room_number = '502' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Столичный')), NULL, (SELECT tariff_id FROM Tariffs WHERE daily_price = 5000.00)),
-- для 37
('2024-11-01', '2024-11-05', '2024-11-01', '2024-11-05', (SELECT guest_id FROM Guests WHERE last_name = 'Попов' AND first_name = 'Андрей'), (SELECT room_id FROM Rooms WHERE room_number = '201' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), NULL, 
 (SELECT tariff_id FROM Tariffs WHERE daily_price = 5000.00)),

-- Второй гость в той же комнате 201 отеля "Морская звезда"  
('2024-11-10', '2024-11-15', '2024-11-10', '2024-11-15', (SELECT guest_id FROM Guests WHERE last_name = 'Ковалева' AND first_name = 'Мария'), (SELECT room_id FROM Rooms WHERE room_number = '201' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), NULL, (SELECT tariff_id FROM Tariffs WHERE daily_price = 5000.00)),
 -- Проживание в отеле "Морская звезда" (Сочи)
('2024-01-10', '2024-01-15', '2024-01-10', '2024-01-15', (SELECT guest_id FROM Guests WHERE last_name = 'Новиков' AND first_name = 'Петр'), (SELECT room_id FROM Rooms WHERE room_number = '201' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), NULL, (SELECT tariff_id FROM Tariffs WHERE daily_price = 5000.00)),

-- Проживание в отеле "Столичный" (Москва) 
('2024-02-20', '2024-02-25', '2024-02-20', '2024-02-25',(SELECT guest_id FROM Guests WHERE last_name = 'Новиков' AND first_name = 'Петр'),(SELECT room_id FROM Rooms WHERE room_number = '501' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Столичный')),NULL,(SELECT tariff_id FROM Tariffs WHERE daily_price = 4500.00)),

-- Проживание в отеле "Нева" (Санкт-Петербург)
('2024-03-15', '2024-03-20', '2024-03-15', '2024-03-20',(SELECT guest_id FROM Guests WHERE last_name = 'Новиков' AND first_name = 'Петр'),(SELECT room_id FROM Rooms WHERE room_number = '301' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Нева')),NULL,(SELECT tariff_id FROM Tariffs WHERE daily_price = 3500.00));

INSERT INTO Service_Bill (bill_date, amount, stay_id) VALUES
('2023-01-16', 2500.00, (SELECT stay_id FROM Stay WHERE guest_id = (SELECT guest_id FROM Guests WHERE last_name = 'Попов') AND check_in_date_actual = '2023-01-15')),
('2023-02-11', 3500.00, (SELECT stay_id FROM Stay WHERE guest_id = (SELECT guest_id FROM Guests WHERE last_name = 'Ковалева') AND check_in_date_actual = '2023-02-10')),
('2023-03-06', 1800.00, (SELECT stay_id FROM Stay WHERE guest_id = (SELECT guest_id FROM Guests WHERE last_name = 'Федоров') AND check_in_date_actual = '2023-03-05')),
('2023-04-02', 4200.00, (SELECT stay_id FROM Stay WHERE guest_id = (SELECT guest_id FROM Guests WHERE last_name = 'Иванов' AND first_name = 'Алексей') AND check_in_date_actual = '2025-04-01')),
('2023-06-11', 3100.00, (SELECT stay_id FROM Stay WHERE guest_id = (SELECT guest_id FROM Guests WHERE last_name = 'Иванов' AND first_name = 'Алексей') AND check_in_date_actual = '2025-06-10')),
('2023-09-21', 2800.00, (SELECT stay_id FROM Stay WHERE guest_id = (SELECT guest_id FROM Guests WHERE last_name = 'Иванов' AND first_name = 'Алексей') AND check_in_date_actual = '2025-09-20'));

INSERT INTO Service_In_Bill (service_type_id, quantity, cost, service_bill_id) VALUES
((SELECT service_type_id FROM Service_Types WHERE name = 'Завтрак'), 2, 500.00, (SELECT service_bill_id FROM Service_Bill WHERE amount = 2500.00 AND bill_date = '2023-01-16')),
((SELECT service_type_id FROM Service_Types WHERE name = 'Ужин'), 1, 2000.00, (SELECT service_bill_id FROM Service_Bill WHERE amount = 2500.00 AND bill_date = '2023-01-16')),
((SELECT service_type_id FROM Service_Types WHERE name = 'СПА'), 1, 1500.00, (SELECT service_bill_id FROM Service_Bill WHERE amount = 3500.00 AND bill_date = '2023-02-11')),
((SELECT service_type_id FROM Service_Types WHERE name = 'Трансфер'), 1, 1800.00, (SELECT service_bill_id FROM Service_Bill WHERE amount = 1800.00 AND bill_date = '2023-03-06')),
((SELECT service_type_id FROM Service_Types WHERE name = 'Экскурсия'), 2, 2100.00, (SELECT service_bill_id FROM Service_Bill WHERE amount = 4200.00 AND bill_date = '2023-04-02')),
((SELECT service_type_id FROM Service_Types WHERE name = 'Прачечная'), 1, 1000.00, (SELECT service_bill_id FROM Service_Bill WHERE amount = 3100.00 AND bill_date = '2023-06-11')),
((SELECT service_type_id FROM Service_Types WHERE name = 'Фитнес'), 3, 1800.00, (SELECT service_bill_id FROM Service_Bill WHERE amount = 2800.00 AND bill_date = '2023-09-21'));



--------Дополнительные под условия
-- Гости
INSERT INTO Guests (last_name, first_name, middle_name, passport_data, birth_date) VALUES
('Иванов', 'Петр', 'Сергеевич', '4512 777888', '1990-05-20'),
('Смирнова', 'Анна', 'Викторовна', '4512 888999', '1988-12-10'),
('Кузнецов', 'Дмитрий', 'Игоревич', '4512 999000', '1992-08-25'),
('Волков', 'Алексей', 'Александрович', '4512 111222', '1995-10-10');

-- Владельцы
INSERT INTO Owners (last_name, first_name, middle_name, passport_data, birth_date) VALUES
('Кузнецов', 'Андрей', 'Петрович', '4501 567890', '1982-03-15'),
('Волков', 'Александр', 'Игоревич', '4501 123987', '1980-05-15');

-- Отели
INSERT INTO Hotels (name, email, opening_year, owner_id, street, building_number, area, locality_id) VALUES
('Северная Пальмира', 'north_palmyra@mail.ru', 2020, 
 (SELECT owner_id FROM Owners WHERE last_name = 'Смирнова' AND first_name = 'Ольга'), 
 'Невский проспект', '50', 1500.00, 
 (SELECT locality_id FROM Localities WHERE name = 'Санкт-Петербург')),
('Кузнецкий Мост', 'kuznetsky@mail.ru', 2019, 
 (SELECT owner_id FROM Owners WHERE last_name = 'Кузнецов' AND first_name = 'Андрей'), 
 'Кузнецкий мост', '10', 2000.00, 
 (SELECT locality_id FROM Localities WHERE name = 'Москва')),
('Арбатский', 'arbatsky@mail.ru', 2021, 
 (SELECT owner_id FROM Owners WHERE last_name = 'Кузнецов' AND first_name = 'Андрей'), 
 'Арбат', '25', 1800.00, 
 (SELECT locality_id FROM Localities WHERE name = 'Москва')),
('Волков Плаза', 'volkov_plaza@mail.ru', 2022, 
 (SELECT owner_id FROM Owners WHERE last_name = 'Волков' AND first_name = 'Александр'), 
 'Тверская', '100', 3500.00, 
 (SELECT locality_id FROM Localities WHERE name = 'Москва')),
('Волков Сочи', 'volkov_sochi@mail.ru', 2023, 
 (SELECT owner_id FROM Owners WHERE last_name = 'Волков' AND first_name = 'Александр'), 
 'Курортный проспект', '200', 2800.00, 
 (SELECT locality_id FROM Localities WHERE name = 'Сочи')),
('Волков СПб', 'volkov_spb@mail.ru', 2024, 
 (SELECT owner_id FROM Owners WHERE last_name = 'Волков' AND first_name = 'Александр'), 
 'Невский проспект', '150', 3200.00, 
 (SELECT locality_id FROM Localities WHERE name = 'Санкт-Петербург'));

-- Комнаты
INSERT INTO Rooms (floor, room_number, hotel_id, view_id, room_type_id) VALUES
(2, '201', (SELECT hotel_id FROM Hotels WHERE name = 'Северная Пальмира'), 
 (SELECT view_id FROM Room_Views WHERE location = 'Город'), 
 (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(3, '301', (SELECT hotel_id FROM Hotels WHERE name = 'Северная Пальмира'), 
 (SELECT view_id FROM Room_Views WHERE location = 'Парк'), 
 (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс')),
(3, '301', (SELECT hotel_id FROM Hotels WHERE name = 'Кузнецкий Мост'), 
 (SELECT view_id FROM Room_Views WHERE location = 'Город'), 
 (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(4, '401', (SELECT hotel_id FROM Hotels WHERE name = 'Кузнецкий Мост'), 
 (SELECT view_id FROM Room_Views WHERE location = 'Город'), 
 (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс')),
(2, '202', (SELECT hotel_id FROM Hotels WHERE name = 'Арбатский'), 
 (SELECT view_id FROM Room_Views WHERE location = 'Парк'), 
 (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(1, '101', (SELECT hotel_id FROM Hotels WHERE name = 'Волков Плаза'), 
 (SELECT view_id FROM Room_Views WHERE location = 'Город'), 
 (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс')),
(2, '201', (SELECT hotel_id FROM Hotels WHERE name = 'Волков Плаза'), 
 (SELECT view_id FROM Room_Views WHERE location = 'Город'), 
 (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(1, '101', (SELECT hotel_id FROM Hotels WHERE name = 'Волков Сочи'), 
 (SELECT view_id FROM Room_Views WHERE location = 'Море'), 
 (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс')),
(2, '201', (SELECT hotel_id FROM Hotels WHERE name = 'Волков Сочи'), 
 (SELECT view_id FROM Room_Views WHERE location = 'Море'), 
 (SELECT room_type_id FROM Room_Types WHERE name = 'Семейный')),
(1, '101', (SELECT hotel_id FROM Hotels WHERE name = 'Волков СПб'), 
 (SELECT view_id FROM Room_Views WHERE location = 'Парк'), 
 (SELECT room_type_id FROM Room_Types WHERE name = 'Стандарт')),
(2, '201', (SELECT hotel_id FROM Hotels WHERE name = 'Волков СПб'), 
 (SELECT view_id FROM Room_Views WHERE location = 'Город'), 
 (SELECT room_type_id FROM Room_Types WHERE name = 'Люкс'));

-- Проживания
INSERT INTO Stay (check_in_date_actual, check_out_date_actual, check_in_date_planned, check_out_date_planned, guest_id, room_id, fine_id, tariff_id) VALUES
('2025-11-01', '2025-11-05', '2025-11-01', '2025-11-05', 
 (SELECT guest_id FROM Guests WHERE last_name = 'Иванов' AND first_name = 'Петр'), 
 (SELECT room_id FROM Rooms WHERE room_number = '201' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')), 
 NULL, 
 (SELECT tariff_id FROM Tariffs WHERE daily_price = 5000.00)),
('2025-11-10', '2025-11-15', '2025-11-10', '2025-11-15', 
 (SELECT guest_id FROM Guests WHERE last_name = 'Иванов' AND first_name = 'Петр'), 
 (SELECT room_id FROM Rooms WHERE room_number = '101' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Горный воздух')), 
 NULL, 
 (SELECT tariff_id FROM Tariffs WHERE daily_price = 5000.00)),
('2025-12-01', '2025-12-05', '2025-12-01', '2025-12-05', 
 (SELECT guest_id FROM Guests WHERE last_name = 'Смирнова' AND first_name = 'Анна'), 
 (SELECT room_id FROM Rooms WHERE room_number = '301' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Нева')), 
 NULL, 
 (SELECT tariff_id FROM Tariffs WHERE daily_price = 3500.00)),
('2025-12-10', '2025-12-15', '2025-12-10', '2025-12-15', 
 (SELECT guest_id FROM Guests WHERE last_name = 'Смирнова' AND first_name = 'Анна'), 
 (SELECT room_id FROM Rooms WHERE room_number = '201' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Северная Пальмира')), 
 NULL, 
 (SELECT tariff_id FROM Tariffs WHERE daily_price = 4000.00)),
('2025-11-20', '2025-11-25', '2025-11-20', '2025-11-25', 
 (SELECT guest_id FROM Guests WHERE last_name = 'Кузнецов' AND first_name = 'Дмитрий'), 
 (SELECT room_id FROM Rooms WHERE room_number = '301' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Кузнецкий Мост')), 
 NULL, 
 (SELECT tariff_id FROM Tariffs WHERE daily_price = 3500.00)),
('2025-12-05', '2025-12-10', '2025-12-05', '2025-12-10', 
 (SELECT guest_id FROM Guests WHERE last_name = 'Кузнецов' AND first_name = 'Дмитрий'), 
 (SELECT room_id FROM Rooms WHERE room_number = '202' AND hotel_id = (SELECT hotel_id FROM Hotels WHERE name = 'Арбатский')), 
 NULL, 
 (SELECT tariff_id FROM Tariffs WHERE daily_price = 3000.00)),
('2025-12-20', '2025-12-25', '2025-12-20', '2025-12-25',
 (SELECT guest_id FROM Guests WHERE last_name = 'Попов'),
 (SELECT room_id FROM Rooms WHERE room_number = '402' AND hotel_id = 
     (SELECT hotel_id FROM Hotels WHERE name = 'Морская звезда')),
 NULL,
 (SELECT tariff_id FROM Tariffs WHERE daily_price = 4500.00));