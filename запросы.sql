






-----------1------------
--Все виды услуг, отсортированные по названию
SELECT * FROM Service_Types ORDER BY name;

-----------2------------
--Клиенты, рожденные зимой, с обратной сортировкой по фамилии
SELECT last_name, first_name, middle_name 
FROM Guests 
WHERE EXTRACT(MONTH FROM birth_date) IN (12, 1, 2) 
ORDER BY last_name DESC; 

-----------3------------
--Годы выписки штрафов без повторов
SELECT DISTINCT EXTRACT(YEAR FROM fine_date) as year 
FROM Fines 
ORDER BY year;

-----------4------------
--Все клиенты с сортировкой
SELECT * FROM Guests 
ORDER BY last_name ASC, first_name DESC, middle_name DESC;

-----------5------------
-- Выбрать фамилию, имя и первую букву отчества обслуживающего персонала. 
--В результат включить только людей с
--двойной фамилией или с фамилией, заканчивающейся на буквы
--«А» или «Я». Результат отсортировать следующим образом: в
--первую очередь данные о персонале с четным id. Без отчества
SELECT 
    last_name || ' ' || first_name || ' ' || 
    CASE 
        WHEN middle_name IS NOT NULL THEN LEFT(middle_name, 1) || '.' 
        ELSE '' 
    END AS full_name
FROM Employees
WHERE 
    (last_name LIKE '%-%' OR last_name LIKE '%а' OR last_name LIKE '%я')
ORDER BY 
    employee_id % 2 = 0 DESC,
    last_name,
    first_name;


-----------6------------
-- Названия услуг с ID 1, 3, 4, 5, 8, 22
SELECT name 
FROM Service_Types 
WHERE service_type_id IN (1, 3, 4, 5, 8, 22);
-----------7------------
-- Все данные о проживаниях, запланированных на текущий месяц
SELECT * FROM Stay 
WHERE EXTRACT(MONTH FROM check_in_date_planned) = EXTRACT(MONTH FROM CURRENT_DATE)
   AND EXTRACT(YEAR FROM check_in_date_planned) = EXTRACT(YEAR FROM CURRENT_DATE);
-----------8------------
-- Фамилия и инициалы владельцев отелей в возрасте от 22 до 35 лет изменено с between 
SELECT 
    last_name || ' ' || LEFT(first_name, 1) || '.' || 
    CASE 
        WHEN middle_name IS NOT NULL AND middle_name != '' 
        THEN LEFT(middle_name, 1) || '.' 
        ELSE '' 
    END as initials
FROM Owners
WHERE birth_date BETWEEN CURRENT_DATE - INTERVAL '35 years' 
                    AND CURRENT_DATE - INTERVAL '22 years';
------------9------------
-- Названия должностей с разрешенными символами и без запрещенных
SELECT role_name
FROM Employee_Roles
WHERE (role_name LIKE '%?%' 
    OR role_name LIKE '%.%'
    OR role_name LIKE '%\_%' ESCAPE '\'
    OR role_name LIKE '%-%'
    OR role_name LIKE '%\%%' ESCAPE '\'
    OR role_name LIKE '%:%')
  AND role_name NOT LIKE '%;%'
  AND role_name NOT LIKE '%$%'
  AND role_name NOT LIKE '%*%';
-----------10-----------
-- Населенные пункты, для которых не указан тип изменено с NULL
SELECT name FROM Localities WHERE type_id IS NULL;
-----------11-----------
-- Выбрать общее количество отелей
SELECT COUNT(*) AS total_hotels
FROM Hotels;
-----------12-----------
--Выбрать название населенного пункта и название типа
--населенного пункта. Результат отсортировать по типу в порядке
--обратном лексикографическому и по названию в порядке обратном лексикографическому. 
SELECT 
    l.name AS locality_name,
    t.name AS type_name
FROM Localities l
JOIN Type t ON l.type_id = t.type_id
ORDER BY t.name DESC, l.name DESC;
-----------13-----------
-- Выбрать фамилию и инициалы владельца отеля, полный
--адрес отеля (название области, название населенного пункта и его
--типа, название улицы, номер дома) в одном столбце, этаж, номер
--комнаты, количество мест, текущую цену. Результат отсортировать по названию области в порядке обратном лексикографическому, по населенному пункту в лексикографическом порядке, по
--улице в порядке обратном лексикографическому, по номеру дома:
--в первую очередь нечетные номера, затем четные. 
SELECT 
    o.last_name || ' ' || LEFT(o.first_name, 1) || '.' || LEFT(o.middle_name, 1) || '.' AS owner_initials,
    r.name || ', ' || l.name || ' (' || t.name || '), ' || h.street || ', ' || h.building_number AS full_address,
    rm.floor,
    rm.room_number,
    rt.number_of_places,
    tf.daily_price AS current_price
FROM Owners o
JOIN Hotels h ON o.owner_id = h.owner_id
JOIN Localities l ON h.locality_id = l.locality_id
JOIN Regions r ON l.region_id = r.region_id
JOIN Type t ON l.type_id = t.type_id
JOIN Rooms rm ON h.hotel_id = rm.hotel_id
JOIN Room_Types rt ON rm.room_type_id = rt.room_type_id
JOIN Tariffs tf ON rm.room_type_id = tf.room_type_id
WHERE tf.start_date = (
    SELECT MAX(start_date) 
    FROM Tariffs tf2 
    WHERE tf2.room_type_id = tf.room_type_id
)
ORDER BY 
    r.name DESC,
    l.name ASC,
    h.street DESC,
    CASE 
        WHEN CAST(SUBSTRING(h.building_number FROM '^[0-9]+') AS INTEGER) % 2 = 1 THEN 1
        ELSE 2
    END,
    h.building_number;
-----------14-----------
--Выбрать самую высокую и самую низкую цены номеров
--в конкретном отеле (значение подставьте сами). 
SELECT 
    MAX(t.daily_price) AS highest_price,
    MIN(t.daily_price) AS lowest_price
FROM Hotels h
JOIN Rooms r ON h.hotel_id = r.hotel_id
JOIN Tariffs t ON r.room_type_id = t.room_type_id
WHERE h.name = 'Морская звезда'
  AND t.start_date = (
    SELECT MAX(start_date) 
    FROM Tariffs t2 
    WHERE t2.room_type_id = t.room_type_id
  );

-----------15-----------
-- Выбрать среднюю заработную плату обслуживающего
--персонала отелей владельца Иванова Ивана Ивановича. 
SELECT ROUND(AVG(e.salary), 2) AS average_salary
FROM Employees e
JOIN Employee_Room er ON e.employee_id = er.employee_id
JOIN Rooms r ON er.room_id = r.room_id
JOIN Hotels h ON r.hotel_id = h.hotel_id
JOIN Owners o ON h.owner_id = o.owner_id
WHERE o.last_name = 'Иванов' 
  AND o.first_name = 'Иван' 
  AND o.middle_name = 'Иванович';
-----------16------------
--Выбрать id и фамилии, имена, отчества всех клиентов,
--проживающих в отеле на данный момент или забронировавших
--номера; если у клиента есть забронированный номер, то в третьем
--столбце результирующей таблицы вывести сообщение «бронь». 
SELECT 
    g.guest_id,
    g.last_name || ' ' || g.first_name || 
    CASE 
        WHEN g.middle_name IS NOT NULL THEN ' ' || g.middle_name 
        ELSE '' 
    END AS full_name,
    CASE 
        WHEN s.check_in_date_planned > CURRENT_DATE THEN 'бронь'
        ELSE ''
    END AS status
FROM Guests g
JOIN Stay s ON g.guest_id = s.guest_id
WHERE 
    (CURRENT_DATE BETWEEN s.check_in_date_actual AND s.check_out_date_actual)
    OR s.check_in_date_planned > CURRENT_DATE 
ORDER BY 
    s.check_in_date_planned > CURRENT_DATE DESC,
    g.last_name,
    g.first_name;

-----------17-----------
--Выбрать название населенного пункта и количество отелей в этом пункте.
--Результат отсортировать по количеству. 
SELECT 
    l.name AS locality_name,
    COUNT(h.hotel_id) AS hotels_count
FROM Localities l
LEFT JOIN Hotels h ON l.locality_id = h.locality_id
GROUP BY l.locality_id, l.name
ORDER BY hotels_count;

-----------18------------
--Выбрать год, месяц текущего года и количество клиентов, проживавших в отелях. 
SELECT 
    EXTRACT(YEAR FROM check_out_date_actual) AS year,
    EXTRACT(MONTH FROM check_out_date_actual) AS month,
    COUNT(DISTINCT guest_id) AS guest_count
FROM Stay
WHERE (check_out_date_actual < CURRENT_DATE) 
AND (EXTRACT(YEAR FROM check_in_date_actual) = EXTRACT(YEAR FROM CURRENT_DATE))
GROUP BY 
    EXTRACT(YEAR FROM check_out_date_actual),
    EXTRACT(MONTH FROM check_out_date_actual)
ORDER BY year, month;

-----------19-----------
--Выбрать для каждого отеля год и количество клиентов,
--проживавших в этом году. Результат отсортировать по названию
--отеля и году. 
SELECT 
    h.name AS hotel_name,
    EXTRACT(YEAR FROM s.check_in_date_actual) AS year,
    COUNT(DISTINCT s.guest_id) AS guests_count
FROM Hotels h
JOIN Rooms r ON h.hotel_id = r.hotel_id
JOIN Stay s ON r.room_id = s.room_id
GROUP BY 
    h.hotel_id, 
    h.name,
    EXTRACT(YEAR FROM s.check_in_date_actual)
ORDER BY 
    h.name,
    year;

-----------20-----------
--Выбрать для каждого типа номера, количество номеров и
--общее количество мест. В результат включить только номера 
--отелей конкретного населенного пункта (значение подставьте сами). 
SELECT 
    rt.name AS room_type_name,
    COUNT(r.room_id) AS rooms_count,
    COUNT(r.room_id) * rt.number_of_places AS total_places
FROM Room_Types rt
JOIN Rooms r ON rt.room_type_id = r.room_type_id
JOIN Hotels h ON r.hotel_id = h.hotel_id
JOIN Localities l ON h.locality_id = l.locality_id
WHERE l.name = 'Сочи'
GROUP BY 
    rt.room_type_id, 
    rt.name,
    rt.number_of_places  
ORDER BY rt.name;



-----------21------------
--Выбрать все данные владельцев, которые имеют два и
--более отеля. Результат отсортировать по количеству. Убрать IN и SELECT  в ORDER BY
SELECT o.*
FROM Owners o
WHERE o.owner_id IN (
    SELECT h.owner_id
    FROM Hotels h
    GROUP BY h.owner_id
    HAVING COUNT(h.hotel_id) >= 2
)
ORDER BY (
    SELECT COUNT(h.hotel_id)
    FROM Hotels h
    WHERE h.owner_id = o.owner_id
) DESC;
-----------21------------!
--Выбрать все данные владельцев, которые имеют два и
--более отеля. Результат отсортировать по количеству. Убрать IN и SELECT  в ORDER BY, убрать подзапрос
SELECT 
    o.*,
    COUNT(h.hotel_id) AS hotel_count
FROM Owners o
JOIN Hotels h ON o.owner_id = h.owner_id
GROUP BY o.owner_id, o.last_name, o.first_name, o.middle_name, o.passport_data, o.birth_date
HAVING COUNT(h.hotel_id) >= 2
ORDER BY COUNT(h.hotel_id) DESC;
-----------22------------
--Выбрать клиентов отелей, принадлежащих Иванову Ивану Ивановичу. 
--В результирующей таблице должно быть два
--столбца: фамилия, имя, отчество клиента и общая сумма, которую
--он заплатил за проживание. В результат включить только тех клиентов 
--отелей, которые останавливались как минимум два раза. Результат отсортировать 
--по фамилии, имени, отчеству в лексикографическом порядке. 
WITH OwnerHotels AS (
    SELECT hotel_id 
    FROM Hotels 
    WHERE owner_id = (
        SELECT owner_id 
        FROM Owners 
        WHERE last_name = 'Иванов' AND first_name = 'Иван' AND middle_name = 'Иванович'
    )
),
FrequentGuests AS (
    SELECT 
        s.guest_id,
        COUNT(*) as stay_count
    FROM Stay s
    JOIN Rooms r ON s.room_id = r.room_id
    JOIN OwnerHotels oh ON r.hotel_id = oh.hotel_id
    GROUP BY s.guest_id
    HAVING COUNT(*) >= 2
)
SELECT 
    g.last_name || ' ' || g.first_name || 
    CASE WHEN g.middle_name IS NOT NULL THEN ' ' || g.middle_name ELSE '' END AS full_name,
    SUM(
        (s.check_out_date_actual - s.check_in_date_actual) * t.daily_price +
        CASE WHEN sb.amount IS NULL THEN 0 ELSE sb.amount END +
        CASE WHEN f.amount IS NULL THEN 0 ELSE f.amount END
    ) AS total_paid
FROM Guests g
JOIN FrequentGuests fg ON g.guest_id = fg.guest_id
JOIN Stay s ON g.guest_id = s.guest_id
JOIN Rooms r ON s.room_id = r.room_id
JOIN OwnerHotels oh ON r.hotel_id = oh.hotel_id
JOIN Tariffs t ON s.tariff_id = t.tariff_id
LEFT JOIN Service_Bill sb ON s.stay_id = sb.stay_id
LEFT JOIN Fines f ON s.fine_id = f.fine_id
GROUP BY g.guest_id, g.last_name, g.first_name, g.middle_name
ORDER BY g.last_name, g.first_name, g.middle_name;
-----------23------------
--Выбрать фамилии, имена, отчества клиентов, которые
--проживали в отелях несколько раз за последний год, но каждый
--раз останавливались в одном и том же отеле. Проверить чтобы только в олном отеле в HAVING
SELECT DISTINCT 
    g.last_name || ' ' || g.first_name || 
    CASE WHEN g.middle_name IS NOT NULL THEN ' ' || g.middle_name ELSE '' END AS full_name
FROM Guests g
JOIN Stay s ON g.guest_id = s.guest_id
JOIN Rooms r ON s.room_id = r.room_id
WHERE s.check_in_date_actual >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY g.guest_id, g.last_name, g.first_name, g.middle_name, r.hotel_id
HAVING COUNT(*) >= 2
ORDER BY full_name;

-----------24------------
--Выбрать фамилию и инициалы клиента, общую сумму,
--которую клиент заплатил за проживание, общую сумму за услуги
--и, если у клиента были штрафы, то общую сумму штрафов. В последнем 
--столбце указать общую сумму, которую он заплатил отелям. Результат отсортировать по фамилии. 
SELECT 
    g.last_name || ' ' || LEFT(g.first_name, 1) || '.' ||
    CASE WHEN g.middle_name IS NOT NULL THEN LEFT(g.middle_name, 1) || '.' ELSE '' END AS client_initials,
    SUM((s.check_out_date_actual - s.check_in_date_actual) * t.daily_price) AS total_accommodation,
    CASE WHEN SUM(sb.amount) IS NULL THEN 0 ELSE SUM(sb.amount) END AS total_services,
    CASE WHEN SUM(f.amount) IS NULL THEN 0 ELSE SUM(f.amount) END AS total_fines,
    SUM((s.check_out_date_actual - s.check_in_date_actual) * t.daily_price) + 
    CASE WHEN SUM(sb.amount) IS NULL THEN 0 ELSE SUM(sb.amount) END + 
    CASE WHEN SUM(f.amount) IS NULL THEN 0 ELSE SUM(f.amount) END AS total_paid
FROM Guests g
JOIN Stay s ON g.guest_id = s.guest_id
JOIN Tariffs t ON s.tariff_id = t.tariff_id
LEFT JOIN Service_Bill sb ON s.stay_id = sb.stay_id
LEFT JOIN Fines f ON s.fine_id = f.fine_id
GROUP BY g.guest_id, g.last_name, g.first_name, g.middle_name
ORDER BY g.last_name;
-----------25------------
--Выбрать фамилию и инициалы клиента, общую сумму,
--которую клиент заплатил за проживание, общую сумму за услуги
--и, если у клиента были штрафы, то общую сумму штрафов. В последнем 
--столбце указать общую сумму, которую он заплатил отелям. В результат 
--включить клиентов, которые останавливались в
--отелях несколько раз и как минимум в двух. Результат отсортировать по фамилии.
SELECT 
    g.last_name || ' ' || LEFT(g.first_name, 1) || '.' ||
    CASE WHEN g.middle_name IS NOT NULL THEN LEFT(g.middle_name, 1) || '.' ELSE '' END AS client_initials,
    SUM((s.check_out_date_actual - s.check_in_date_actual) * t.daily_price) AS total_accommodation,
    CASE WHEN SUM(sb.amount) IS NULL THEN 0 ELSE SUM(sb.amount) END AS total_services,
    CASE WHEN SUM(f.amount) IS NULL THEN 0 ELSE SUM(f.amount) END AS total_fines,
    SUM((s.check_out_date_actual - s.check_in_date_actual) * t.daily_price) + 
    CASE WHEN SUM(sb.amount) IS NULL THEN 0 ELSE SUM(sb.amount) END + 
    CASE WHEN SUM(f.amount) IS NULL THEN 0 ELSE SUM(f.amount) END AS total_paid
FROM Guests g
JOIN Stay s ON g.guest_id = s.guest_id
JOIN Tariffs t ON s.tariff_id = t.tariff_id
JOIN Rooms r ON s.room_id = r.room_id
LEFT JOIN Service_Bill sb ON s.stay_id = sb.stay_id
LEFT JOIN Fines f ON s.fine_id = f.fine_id
GROUP BY g.guest_id, g.last_name, g.first_name, g.middle_name
HAVING COUNT(DISTINCT r.hotel_id) >= 2
ORDER BY g.last_name;
-----------26------------
--Выбрать для каждого отеля год и сумму, которую получил отель 
--за проживание клиентов по временам года. В результирующей таблице 
--должно быть шесть столбцов: название отеля,
--год, зима, весна, осень, лето. 
SELECT 
    h.name AS hotel_name,
    EXTRACT(YEAR FROM s.check_in_date_actual) AS year,
    SUM(CASE WHEN EXTRACT(MONTH FROM s.check_in_date_actual) IN (12, 1, 2) 
        THEN (s.check_out_date_actual - s.check_in_date_actual) * t.daily_price ELSE 0 END) AS winter,
    SUM(CASE WHEN EXTRACT(MONTH FROM s.check_in_date_actual) IN (3, 4, 5) 
        THEN (s.check_out_date_actual - s.check_in_date_actual) * t.daily_price ELSE 0 END) AS spring,
    SUM(CASE WHEN EXTRACT(MONTH FROM s.check_in_date_actual) IN (6, 7, 8) 
        THEN (s.check_out_date_actual - s.check_in_date_actual) * t.daily_price ELSE 0 END) AS summer,
    SUM(CASE WHEN EXTRACT(MONTH FROM s.check_in_date_actual) IN (9, 10, 11) 
        THEN (s.check_out_date_actual - s.check_in_date_actual) * t.daily_price ELSE 0 END) AS autumn
FROM Hotels h
JOIN Rooms r ON h.hotel_id = r.hotel_id
JOIN Stay s ON r.room_id = s.room_id
JOIN Tariffs t ON s.tariff_id = t.tariff_id
GROUP BY h.hotel_id, h.name, EXTRACT(YEAR FROM s.check_in_date_actual)
ORDER BY h.name, year;
-----------27------------
--Выбрать всех однофамильцев тезок среди клиентов и
--владельцев.
SELECT 
    g.last_name,
    g.first_name,
    g.middle_name,
    'guest' as person_type,
    g.guest_id as id
FROM Guests g
JOIN Owners o ON g.last_name = o.last_name 
              AND g.first_name = o.first_name 
              AND (g.middle_name = o.middle_name 
                   OR (g.middle_name IS NULL AND o.middle_name IS NULL))

UNION ALL

SELECT 
    o.last_name,
    o.first_name,
    o.middle_name,
    'owner' as person_type,
    o.owner_id as id
FROM Owners o
JOIN Guests g ON o.last_name = g.last_name 
              AND o.first_name = g.first_name 
              AND (o.middle_name = g.middle_name 
                   OR (o.middle_name IS NULL AND g.middle_name IS NULL))
ORDER BY last_name, first_name, middle_name, person_type;
-----------28------------
--Вывести сообщение «Есть отели с одинаковыми названиями», 
--если есть отели с одинаковыми названиями в разных населенных пунктах. 
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM Hotels h1
            JOIN Hotels h2 ON h1.name = h2.name AND h1.locality_id != h2.locality_id
        ) THEN 'Есть отели с одинаковыми названиями'
        ELSE 'Нет отелей с одинаковыми названиями'
    END AS message;
-----------29------------
--Выбрать названия всех населенных пунктов и, 
--если в населенном пункте есть отель, то его название. 
--Учесть, что в БД могут быть населенные пункты без отелей. 
SELECT 
    l.name AS locality_name,
    CASE 
        WHEN h.name IS NULL THEN 'Нет отеля'
        ELSE h.name 
    END AS hotel_name
FROM Localities l
LEFT JOIN Hotels h ON l.locality_id = h.locality_id
ORDER BY l.name, h.name;
-----------30------------
--Выбрать названия всех населенных пунктов и, 
--если в населенном пункте есть отели, то их количество. Учесть, что в БД
--могут быть населенные пункты без отелей.
SELECT 
    l.name AS locality_name,
    CASE 
        WHEN COUNT(h.hotel_id) = 0 THEN 'Нет отеля'
        ELSE CAST(COUNT(h.hotel_id) AS TEXT)
    END AS hotel_count
FROM Localities l
LEFT JOIN Hotels h ON l.locality_id = h.locality_id
GROUP BY l.locality_id, l.name
ORDER BY l.name;

-----------31------------!
--Для каждого населенного пункта выбрать фамилии и
--инициалы всех владельцев. Результат отсортировать по населенному пункту и фамилии. как 32 с Cross join
SELECT 
    l.name AS locality_name,
    o.last_name || ' ' || LEFT(o.first_name, 1) || '.' ||
    CASE WHEN o.middle_name IS NOT NULL THEN LEFT(o.middle_name, 1) || '.' ELSE '' END AS owner_initials
FROM Localities l
CROSS JOIN Owners o
ORDER BY l.name, o.last_name;
-----------32------------
--Для каждого населенного пункта выбрать фамилию и
--инициалы владельцев и, если в соответствующем населенном
--пункте у владельца есть отель, то в третьем столбце 
--результирующей таблицы указать количество отелей. Результат 
--отсортировать по населенному пункту и фамилии. 
SELECT 
    l.name AS locality_name,
    o.last_name || ' ' || LEFT(o.first_name, 1) || '.' ||
    CASE WHEN o.middle_name IS NOT NULL THEN LEFT(o.middle_name, 1) || '.' ELSE '' END AS owner_initials,
    COUNT(h.hotel_id) AS hotel_count
FROM Localities l
CROSS JOIN Owners o
LEFT JOIN Hotels h ON l.locality_id = h.locality_id AND h.owner_id = o.owner_id
GROUP BY l.locality_id, l.name, o.owner_id, o.last_name, o.first_name, o.middle_name
ORDER BY l.name, o.last_name;

-----------33------------!
--Выбрать фамилию, имя, отчество первого клиента. IN убрать, делать с JOIN, 33 как 34
SELECT 
    g.last_name || ' ' || g.first_name || ' ' || 
    CASE 
        WHEN g.middle_name IS NOT NULL THEN g.middle_name 
        ELSE '' 
    END AS full_name
FROM Guests g
JOIN Stay s ON g.guest_id = s.guest_id
WHERE s.check_in_date_actual = (
    SELECT MIN(check_in_date_actual)
    FROM Stay
);
-----------34------------
--Выбрать фамилии, имена, отчества первого и последнего
--клиентов конкретного отеля (значение подставьте сами). 
-- по дате
SELECT 
    g.last_name || ' ' || g.first_name || ' ' || 
    CASE 
        WHEN g.middle_name IS NOT NULL THEN LEFT(g.middle_name, 1) || '.' 
        ELSE '' 
    END AS full_name,
    'Первый клиент' AS client_type
FROM Guests g
JOIN Stay s ON g.guest_id = s.guest_id
JOIN Rooms r ON s.room_id = r.room_id
JOIN Hotels h ON r.hotel_id = h.hotel_id
WHERE h.name = 'Морская звезда'
AND s.check_in_date_actual = (
    SELECT MIN(s2.check_in_date_actual)
    FROM Stay s2
    JOIN Rooms r2 ON s2.room_id = r2.room_id
    JOIN Hotels h2 ON r2.hotel_id = h2.hotel_id
    WHERE h2.name = 'Морская звезда'
)

UNION ALL

SELECT 
    g.last_name || ' ' || g.first_name || ' ' || 
    CASE 
        WHEN g.middle_name IS NOT NULL THEN LEFT(g.middle_name, 1) || '.' 
        ELSE '' 
    END AS full_name,
    'Последний клиент' AS client_type
FROM Guests g
JOIN Stay s ON g.guest_id = s.guest_id
JOIN Rooms r ON s.room_id = r.room_id
JOIN Hotels h ON r.hotel_id = h.hotel_id
WHERE h.name = 'Морская звезда'
AND s.check_out_date_actual = (
    SELECT MAX(s2.check_out_date_actual)
    FROM Stay s2
    JOIN Rooms r2 ON s2.room_id = r2.room_id
    JOIN Hotels h2 ON r2.hotel_id = h2.hotel_id
    WHERE h2.name = 'Морская звезда'
);
--
-----------35------------
--Выбрать название самого большого отеля (отеля, в котором больше всего номеров). 
SELECT h.name AS hotel_name
FROM Hotels h
JOIN Rooms r ON h.hotel_id = r.hotel_id
GROUP BY h.hotel_id, h.name
HAVING COUNT(r.room_id) >= ALL (
    SELECT COUNT(r2.room_id)
    FROM Hotels h2
    JOIN Rooms r2 ON h2.hotel_id = r2.hotel_id
    GROUP BY h2.hotel_id
);

-----------36------------
--Выбрать названия населенных пунктов, в которых нет
--отелей. 

SELECT l.name AS locality_name
FROM Localities l
WHERE NOT EXISTS (
    SELECT *
    FROM Hotels h
    WHERE h.locality_id = l.locality_id
)
ORDER BY l.name;
---------2 СПОСОБА---------
-----------37------------
--Выбрать все данные номеров отелей конкретного населенного пункта 1 зачел
--(значение подставьте сами), в которых проживало
--несколько клиентов, причем ни один из клиентов не пользовался
--дополнительными услугами. 2 С ПОДзапрросом выбрать все номера с несколькими и убрать с доп услугами
SELECT r.*
FROM Rooms r
JOIN Hotels h ON r.hotel_id = h.hotel_id
JOIN Localities l ON h.locality_id = l.locality_id
WHERE l.name = 'Сочи'
AND r.room_id IN (
    SELECT s.room_id
    FROM Stay s
    WHERE NOT EXISTS (
        SELECT 1
        FROM Service_Bill sb
        WHERE sb.stay_id = s.stay_id
    )
    GROUP BY s.room_id
    HAVING COUNT(DISTINCT s.guest_id) >= 2
);

--------------
SELECT DISTINCT r.*
FROM Rooms r
JOIN Hotels h ON r.hotel_id = h.hotel_id
JOIN Localities l ON h.locality_id = l.locality_id
JOIN Stay s ON r.room_id = s.room_id
LEFT JOIN Service_Bill sb ON s.stay_id = sb.stay_id
WHERE l.name = 'Сочи'
  AND sb.service_bill_id IS NULL  -- нет дополнительных услуг
GROUP BY r.room_id
HAVING COUNT(DISTINCT s.guest_id) > 1;  -- несколько клиентов
-----------
SELECT r.*
FROM Rooms r
JOIN Hotels h ON r.hotel_id = h.hotel_id
JOIN Localities l ON h.locality_id = l.locality_id
JOIN Room_Types rt ON r.room_type_id = rt.room_type_id
JOIN Room_Views rv ON r.view_id = rv.view_id

JOIN (
    SELECT 
        s.room_id,
        COUNT(DISTINCT s.guest_id) AS guests_count
    FROM Stay s
    GROUP BY s.room_id
    HAVING COUNT(DISTINCT s.guest_id) > 1
) guest_stats ON r.room_id = guest_stats.room_id
WHERE l.name = 'Сочи'
  
  AND r.room_id NOT IN (
      SELECT DISTINCT s.room_id
      FROM Stay s
      JOIN Service_Bill sb ON s.stay_id = sb.stay_id
  );

-----------38------------
--Выбрать все данные о клиентах, которые останавливались
--как минимум три раза в отелях, при этом каждый раз в разных. 1 избавиться от подзапроса 2 зачел
SELECT g.*
FROM Guests g
WHERE g.guest_id IN (
    SELECT s.guest_id
    FROM Stay s
    JOIN Rooms r ON s.room_id = r.room_id
    GROUP BY s.guest_id
    HAVING COUNT(DISTINCT s.stay_id) >= 3
    AND COUNT(DISTINCT r.hotel_id) = COUNT(s.stay_id)
);
--------
SELECT DISTINCT g.*
FROM Guests g
WHERE EXISTS (
    -- Проверяем, что у гостя минимум 3 проживания
    SELECT 1
    FROM Stay s
    WHERE s.guest_id = g.guest_id
    GROUP BY s.guest_id
    HAVING COUNT(*) >= 3
)
AND EXISTS (
    -- Проверяем, что все проживания в разных отелях
    SELECT 1
    FROM Stay s
    JOIN Rooms r ON s.room_id = r.room_id
    WHERE s.guest_id = g.guest_id
    GROUP BY s.guest_id
    HAVING COUNT(DISTINCT r.hotel_id) = COUNT(s.stay_id)  
);
------------
SELECT g.*
FROM Guests g
JOIN Stay s ON g.guest_id = s.guest_id
JOIN Rooms r ON s.room_id = r.room_id
GROUP BY g.guest_id, g.last_name, g.first_name, g.middle_name, g.passport_data, g.birth_date
HAVING COUNT(DISTINCT s.stay_id) >= 3
   AND COUNT(DISTINCT r.hotel_id) = COUNT(DISTINCT s.stay_id);
-----------39------------ 
--Выбрать клиентов, которые, каждый раз останавливаясь
--в отеле, платят штрафы. 
SELECT g.*
FROM Guests g
JOIN Stay s ON g.guest_id = s.guest_id
GROUP BY g.guest_id, g.last_name, g.first_name, g.middle_name, g.passport_data, g.birth_date
HAVING COUNT(*) = COUNT(s.fine_id);
------------
SELECT DISTINCT g.*
FROM Guests g
JOIN Stay s ON g.guest_id = s.guest_id
LEFT JOIN (
    SELECT DISTINCT guest_id 
    FROM Stay 
    WHERE fine_id IS NULL
) s_without_fines ON g.guest_id = s_without_fines.guest_id
WHERE s_without_fines.guest_id IS NULL;
-----------40------------
--Выбрать название населенного пункта, в котором больше
--всего отелей. 
SELECT 
    l.name AS locality_name,
    COUNT(h.hotel_id) AS hotel_count
FROM Localities l
LEFT JOIN Hotels h ON l.locality_id = h.locality_id
GROUP BY l.locality_id, l.name
HAVING COUNT(h.hotel_id) >= ALL (
    SELECT COUNT(*)
    FROM Hotels
    GROUP BY locality_id
);
-------------
SELECT l.name AS locality_name, COUNT(h.hotel_id) AS hotel_count
FROM Localities l
JOIN Hotels h ON l.locality_id = h.locality_id
GROUP BY l.locality_id, l.name
HAVING COUNT(h.hotel_id) = (
    SELECT MAX(hotel_count)
    FROM (
        SELECT COUNT(h2.hotel_id) AS hotel_count
        FROM Hotels h2
        GROUP BY h2.locality_id
    ) AS counts
);


-------------41-------------
--Выбрать названия населенных пунктов, 
--в которых больше всего отелей и меньше всего отелей.
SELECT 
    l.name AS locality_name,
    COUNT(h.hotel_id) AS hotel_count
FROM Localities l
LEFT JOIN Hotels h ON l.locality_id = h.locality_id
GROUP BY l.locality_id, l.name
HAVING (COUNT(h.hotel_id) >= ALL (
    SELECT COUNT(*)
    FROM Hotels
    GROUP BY locality_id
)
   OR COUNT(h.hotel_id) <= ALL (
    SELECT COUNT(*)
    FROM Hotels
    GROUP BY locality_id
)) AND COUNT(h.hotel_id)>0
ORDER BY hotel_count DESC;
-----------------------------
-- Населенные пункты с максимальным количеством отелей
SELECT 
    l.name AS locality_name,
    COUNT(h.hotel_id) AS hotel_count
FROM Localities l
LEFT JOIN Hotels h ON l.locality_id = h.locality_id
GROUP BY l.locality_id, l.name
HAVING COUNT(h.hotel_id) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM Hotels
        GROUP BY locality_id
    ) AS counts
)

UNION ALL

-- Населенные пункты с минимальным количеством отелей
SELECT 
    l.name AS locality_name,
    COUNT(h.hotel_id) AS hotel_count
FROM Localities l
LEFT JOIN Hotels h ON l.locality_id = h.locality_id
GROUP BY l.locality_id, l.name
HAVING COUNT(h.hotel_id) = (
    SELECT MIN(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM Hotels
        GROUP BY locality_id
    ) AS counts
)
ORDER BY hotel_count DESC;

-------------42------------
--Выбрать фамилии, имена, отчества владельцев, которые
--обладают несколькими отелями, причем все они расположены в
--разных областях.
SELECT 
    o.last_name || ' ' || o.first_name || ' ' || 
    CASE 
        WHEN o.middle_name IS NOT NULL THEN o.middle_name 
        ELSE '' 
    END AS full_name
FROM Owners o
JOIN Hotels h ON o.owner_id = h.owner_id
JOIN Localities l ON h.locality_id = l.locality_id
JOIN Regions r ON l.region_id = r.region_id
GROUP BY o.owner_id
HAVING COUNT(DISTINCT h.hotel_id) > 1 
   AND COUNT(DISTINCT h.hotel_id) = COUNT(DISTINCT r.region_id);
--------------
SELECT 
    o.last_name || ' ' || o.first_name || ' ' || 
    CASE 
        WHEN o.middle_name IS NOT NULL THEN o.middle_name 
        ELSE '' 
    END AS full_name
FROM Owners o
WHERE o.owner_id IN (
    SELECT h.owner_id
    FROM Hotels h
    JOIN Localities l ON h.locality_id = l.locality_id
    GROUP BY h.owner_id
    HAVING COUNT(DISTINCT h.hotel_id) > 1 
       AND COUNT(DISTINCT l.region_id) = COUNT(DISTINCT h.hotel_id) 
);



--------------43--------------------
--Выбрать наименование вида вреда, который клиенты
--отелей причиняют чаще других. 
SELECT 
    ft.name AS fine_name,
    ft.description,
    COUNT(f.fine_id) AS fine_count
FROM Fine_Types ft
JOIN Fines f ON ft.fine_type_id = f.fine_type_id
GROUP BY ft.fine_type_id, ft.name, ft.description
HAVING COUNT(f.fine_id) = (
    SELECT MAX(fine_count)
    FROM (
        SELECT COUNT(*) AS fine_count
        FROM Fines
        GROUP BY fine_type_id
    ) AS counts
);
---------------
WITH fine_stats AS (
    SELECT 
        ft.name AS fine_name,
        ft.description,
        COUNT(f.fine_id) AS fine_count,
        RANK() OVER (ORDER BY COUNT(f.fine_id) DESC) AS rank
    FROM Fine_Types ft
    LEFT JOIN Fines f ON ft.fine_type_id = f.fine_type_id
    GROUP BY ft.fine_type_id, ft.name, ft.description
)
SELECT fine_name, description, fine_count
FROM fine_stats
WHERE rank = 1;

------------44------------
--Выбрать клиентов, которые останавливались 
--как минимум в двух разных отелях одного 
--населенного пункта, принадлежащих одному владельцу – однофамильцу клиента. 2 : 2 отеля через stay

SELECT DISTINCT
    g.guest_id,
     g.last_name || ' ' || g.first_name || ' ' || 
    CASE 
        WHEN g.middle_name IS NOT NULL THEN g.middle_name 
        ELSE '' 
    END AS full_name,
    l.name AS locality_name,
    o.last_name AS owner_last_name
FROM Guests g
JOIN Stay s ON g.guest_id = s.guest_id
JOIN Rooms r ON s.room_id = r.room_id
JOIN Hotels h ON r.hotel_id = h.hotel_id
JOIN Localities l ON h.locality_id = l.locality_id
JOIN Owners o ON h.owner_id = o.owner_id
WHERE o.last_name = g.last_name  -- однофамильцы
GROUP BY g.guest_id, g.last_name, g.first_name, g.middle_name, 
         l.name, o.last_name
HAVING COUNT(DISTINCT h.hotel_id) >= 2;

--------------------------
SELECT 
    g.guest_id,
     g.last_name || ' ' || g.first_name || ' ' || 
    CASE 
        WHEN g.middle_name IS NOT NULL THEN g.middle_name 
        ELSE '' 
    END AS full_name
FROM Guests g
WHERE g.guest_id IN (
    SELECT s.guest_id
    FROM Stay s
    JOIN Rooms r ON s.room_id = r.room_id
    JOIN Hotels h ON r.hotel_id = h.hotel_id
    JOIN Localities l ON h.locality_id = l.locality_id
    JOIN Owners o ON h.owner_id = o.owner_id
    WHERE o.last_name = g.last_name  -- однофамильцы
    GROUP BY s.guest_id, l.locality_id
    HAVING COUNT(DISTINCT h.hotel_id) >= 2
);
-----------------------
SELECT DISTINCT g.*
FROM Guests g
JOIN Stay s1 ON g.guest_id = s1.guest_id
JOIN Stay s2 ON g.guest_id = s2.guest_id AND s1.stay_id != s2.stay_id  
JOIN Rooms r1 ON s1.room_id = r1.room_id
JOIN Rooms r2 ON s2.room_id = r2.room_id
JOIN Hotels h1 ON r1.hotel_id = h1.hotel_id
JOIN Hotels h2 ON r2.hotel_id = h2.hotel_id
JOIN Localities l ON h1.locality_id = l.locality_id 
                  AND h2.locality_id = l.locality_id          
JOIN Owners o ON h1.owner_id = o.owner_id 
              AND h2.owner_id = o.owner_id                    
WHERE o.last_name = g.last_name                                
  AND h1.hotel_id != h2.hotel_id;

-------------45-------------
--Выбрать всех однофамильцев тезок по всей БД.

WITH all_people AS (
    SELECT 
        last_name,
        first_name,
        middle_name,
        birth_date
    FROM Guests
    
    UNION ALL

    SELECT 
        last_name,
        first_name,
        middle_name,
        birth_date
    FROM Employees
    
    UNION ALL

    SELECT 
        last_name,
        first_name,
        middle_name,
        birth_date
    FROM Owners
)
SELECT 
    last_name,
    first_name,
    COUNT(*) AS count
FROM all_people
GROUP BY last_name, first_name
HAVING COUNT(*) > 1
ORDER BY last_name, first_name;

---------------------------------

WITH all_people AS (
    SELECT 
        last_name,
        first_name,
        middle_name
    FROM Guests
    
    UNION ALL
    
    SELECT 
        last_name,
        first_name,
        middle_name
    FROM Employees
    
    UNION ALL
    
    SELECT 
        last_name,
        first_name,
        middle_name
    FROM Owners
),
ranked AS (
    SELECT 
        *,
        COUNT(*) OVER (PARTITION BY last_name, first_name) AS same_name_count
    FROM all_people
)
SELECT DISTINCT
    last_name,
    first_name,
    same_name_count
FROM ranked
WHERE same_name_count > 1
ORDER BY last_name, first_name;

--------------46----------------
--Выбрать общее количество однофамильцев по всей БД. 
WITH all_people AS (
    SELECT last_name FROM Guests
    UNION ALL
    SELECT last_name FROM Employees
    UNION ALL
    SELECT last_name FROM Owners
)
SELECT SUM(cnt) AS total_people_with_duplicates
FROM (
    SELECT last_name, COUNT(*) AS cnt
    FROM all_people
    GROUP BY last_name
    HAVING COUNT(*) > 1
) duplicates;

--------------

WITH all_people AS (
    SELECT last_name FROM Guests
    UNION ALL
    SELECT last_name FROM Employees
    UNION ALL
    SELECT last_name FROM Owners
),
ranked AS (
    SELECT 
        last_name,
        COUNT(*) OVER (PARTITION BY last_name) AS surname_count
    FROM all_people
)
SELECT COUNT(*) AS total_people_with_duplicates
FROM ranked
WHERE surname_count > 1;

---------47-------------
--Выбрать все различные имена по все БД. 
SELECT first_name AS name FROM Guests
UNION
SELECT first_name FROM Employees
UNION
SELECT first_name FROM Owners
ORDER BY name;
------------
WITH all_names AS (
    SELECT first_name FROM Guests
    UNION ALL
    SELECT first_name FROM Employees
    UNION ALL
    SELECT first_name FROM Owners
)
SELECT DISTINCT first_name
FROM all_names
ORDER BY first_name;

------------48----------------
--Выбрать количество различных имен по всей БД.
SELECT COUNT(*) AS unique_names_count
FROM (
    SELECT first_name FROM Guests
    UNION
    SELECT first_name FROM Employees
    UNION
    SELECT first_name FROM Owners
) all_names;
---------------
SELECT COUNT(DISTINCT first_name) AS unique_names_count
FROM (
    SELECT first_name FROM Guests
    UNION ALL
    SELECT first_name FROM Employees
    UNION ALL
    SELECT first_name FROM Owners
) all_names;
---------49----------
--Выбрать геометрическую прогрессию. 
WITH RECURSIVE seq AS (
    SELECT 1 AS val, 0 AS n
    UNION ALL
    SELECT val*2, n+1 FROM seq WHERE n < 10
)
SELECT val FROM seq;
------------50--------------
--Выбрать тройку самых больших отелей (по количеству
--номеров). 
WITH hotel_rooms AS (
    SELECT 
        h.hotel_id,
        h.name AS hotel_name,
        COUNT(r.room_id) AS rooms_count,
        RANK() OVER (ORDER BY COUNT(r.room_id) DESC) AS rank
    FROM Hotels h
    LEFT JOIN Rooms r ON h.hotel_id = r.hotel_id
    GROUP BY h.hotel_id, h.name
)
SELECT 
    hotel_id,
    hotel_name,
    rooms_count
FROM hotel_rooms
WHERE rank <= 3
ORDER BY rooms_count DESC;
-------------

WITH hotel_rooms AS (
    SELECT 
        h.hotel_id,
        h.name AS hotel_name,
        COUNT(r.room_id) AS rooms_count
    FROM Hotels h
    LEFT JOIN Rooms r ON h.hotel_id = r.hotel_id
    GROUP BY h.hotel_id, h.name
)
SELECT 
    hotel_id,
    hotel_name,
    rooms_count
FROM hotel_rooms
WHERE rooms_count >= (
    SELECT MIN(rooms_count)
    FROM (
        SELECT DISTINCT rooms_count
        FROM hotel_rooms
        ORDER BY rooms_count DESC
        LIMIT 3
    ) AS top_3_counts
)
ORDER BY rooms_count DESC;

------------51---------------
--Выбрать год, все месяцы года и количество клиентов,
--проживавших в отелях. Учесть, что в БД может не быть данных о
--проживании клиентов в каком-либо месяце, но в результирующей
--таблице он должен быть (годы брать из БД). 

WITH years AS (
    SELECT DISTINCT EXTRACT(YEAR FROM check_in_date_actual) AS year
    FROM Stay
    WHERE check_in_date_actual IS NOT NULL
),
months AS (
    SELECT 1 AS month UNION ALL
    SELECT 2 UNION ALL
    SELECT 3 UNION ALL
    SELECT 4 UNION ALL
    SELECT 5 UNION ALL
    SELECT 6 UNION ALL
    SELECT 7 UNION ALL
    SELECT 8 UNION ALL
    SELECT 9 UNION ALL
    SELECT 10 UNION ALL
    SELECT 11 UNION ALL
    SELECT 12
),
stay_counts AS (
    SELECT 
        EXTRACT(YEAR FROM check_in_date_actual) AS year,
        EXTRACT(MONTH FROM check_in_date_actual) AS month,
        COUNT(DISTINCT guest_id) AS guests_count
    FROM Stay
    WHERE check_in_date_actual IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM check_in_date_actual), EXTRACT(MONTH FROM check_in_date_actual)
)
SELECT 
    y.year,
    m.month,
    COALESCE(sc.guests_count, 0) AS guests_count
FROM years y
CROSS JOIN months m
LEFT JOIN stay_counts sc ON y.year = sc.year AND m.month = sc.month
ORDER BY y.year, m.month;

-----------------------
WITH RECURSIVE years AS (
    SELECT DISTINCT EXTRACT(YEAR FROM check_in_date_actual) AS year
    FROM Stay
    WHERE check_in_date_actual IS NOT NULL
),
months AS (
    SELECT 1 AS month
    UNION ALL
    SELECT month + 1
    FROM months
    WHERE month < 12
),
stay_counts AS (
    SELECT 
        EXTRACT(YEAR FROM check_in_date_actual) AS year,
        EXTRACT(MONTH FROM check_in_date_actual) AS month,
        COUNT(DISTINCT guest_id) AS guests_count
    FROM Stay
    WHERE check_in_date_actual IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM check_in_date_actual), EXTRACT(MONTH FROM check_in_date_actual)
)
SELECT 
    y.year,
    m.month,
    COALESCE(sc.guests_count, 0) AS guests_count
FROM years y
CROSS JOIN months m
LEFT JOIN stay_counts sc ON y.year = sc.year AND m.month = sc.month
ORDER BY y.year, m.month;







