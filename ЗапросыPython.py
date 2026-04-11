"""
Скрипт для работы с базой данных сети отелей
Подключение к PostgreSQL и выполнение аналитических запросов
"""

import sys

try:
    import psycopg2
    from psycopg2 import extras
    print("psycopg2 загружен")
except ImportError:
    print("Библиотека psycopg2 не установлена!")
    print("Выполните в терминале: pip install psycopg2-binary")
    sys.exit(1)

try:
    import pandas as pd
    print("pandas загружен")
except ImportError:
    print("Библиотека pandas не установлена!")
    print("Выполните в терминале: pip install pandas")
    sys.exit(1)

from datetime import datetime, date

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'postgres',
    'user': 'postgres',
    'password': '5362'
}


def get_connection():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("Успешное подключение к базе данных")
        return conn
    except psycopg2.Error as e:
        print(f"Ошибка подключения: {e}")
        return None


def execute_query(conn, query, params=None, fetch=True):
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            if params:
                cur.execute(query, params)
            else:
                cur.execute(query)

            if fetch:
                return cur.fetchall()
            else:
                conn.commit()
                return None
    except psycopg2.Error as e:
        print(f"Ошибка выполнения запроса: {e}")
        conn.rollback()
        return None


def print_results(results, title="Результаты запроса", max_rows=20):
    if not results:
        print("Нет данных")
        return

    print(f"\n{title}")
    print("-" * 80)

    df = pd.DataFrame(results)
    if len(df) > max_rows:
        print(df.head(max_rows))
        print(f"... и ещё {len(df) - max_rows} строк")
    else:
        print(df)
    print("-" * 80)
    print(f"Всего строк: {len(results)}\n")


def get_all_hotels(conn):
    query = """
        SELECT 
            h.name AS отель,
            o.last_name || ' ' || o.first_name AS владелец,
            l.name AS населенный_пункт,
            r.name AS регион,
            h.email,
            h.opening_year AS год_открытия,
            h.area AS площадь_квм
        FROM Hotels h
        JOIN Owners o ON h.owner_id = o.owner_id
        JOIN Localities l ON h.locality_id = l.locality_id
        JOIN Regions r ON l.region_id = r.region_id
        ORDER BY h.name;
    """
    return execute_query(conn, query)


def get_all_room_types(conn):
    query = """
        SELECT 
            name AS тип_номера,
            class AS класс,
            number_of_places AS количество_мест,
            description AS описание
        FROM Room_Types
        ORDER BY number_of_places DESC;
    """
    return execute_query(conn, query)


def get_current_tariffs(conn):
    query = """
        SELECT 
            rt.name AS тип_номера,
            t.daily_price AS цена_за_сутки,
            t.description AS описание,
            t.start_date AS дата_начала
        FROM Tariffs t
        JOIN Room_Types rt ON t.room_type_id = rt.room_type_id
        WHERE t.start_date <= CURRENT_DATE
        ORDER BY t.daily_price DESC;
    """
    return execute_query(conn, query)


def get_rooms_by_hotel(conn):
    query = """
        SELECT 
            h.name AS отель,
            r.floor AS этаж,
            r.room_number AS номер,
            rt.name AS тип,
            rv.location AS вид_из_окна
        FROM Rooms r
        JOIN Hotels h ON r.hotel_id = h.hotel_id
        JOIN Room_Types rt ON r.room_type_id = rt.room_type_id
        JOIN Room_Views rv ON r.view_id = rv.view_id
        ORDER BY h.name, r.floor, r.room_number;
    """
    return execute_query(conn, query)


def get_employees_with_rooms(conn):
    query = """
        SELECT 
            e.last_name || ' ' || e.first_name AS сотрудник,
            e.work_type AS тип_работы,
            e.salary AS оклад,
            STRING_AGG(DISTINCT r.room_number, ', ') AS закрепленные_номера,
            STRING_AGG(DISTINCT h.name, ', ') AS отели
        FROM Employees e
        JOIN Employee_Room er ON e.employee_id = er.employee_id
        JOIN Rooms r ON er.room_id = r.room_id
        JOIN Hotels h ON r.hotel_id = h.hotel_id
        GROUP BY e.employee_id, e.last_name, e.first_name, e.work_type, e.salary
        ORDER BY e.salary DESC;
    """
    return execute_query(conn, query)


def get_guests_info(conn):
    query = """
        SELECT 
            last_name || ' ' || first_name || COALESCE(' ' || middle_name, '') AS ФИО,
            passport_data AS паспорт,
            birth_date AS дата_рождения,
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) AS возраст
        FROM Guests
        ORDER BY last_name, first_name;
    """
    return execute_query(conn, query)


def get_hotel_occupancy(conn):
    query = """
        SELECT 
            h.name AS отель,
            COUNT(s.stay_id) AS количество_проживаний,
            COUNT(DISTINCT s.guest_id) AS уникальных_гостей,
            ROUND(AVG((s.check_out_date_actual - s.check_in_date_actual)), 1) AS средняя_длительность
        FROM Hotels h
        JOIN Rooms r ON h.hotel_id = r.hotel_id
        JOIN Stay s ON r.room_id = s.room_id
        GROUP BY h.hotel_id, h.name
        ORDER BY количество_проживаний DESC;
    """
    return execute_query(conn, query)


def get_top_guests(conn):
    query = """
        SELECT 
            g.last_name || ' ' || g.first_name AS гость,
            COUNT(s.stay_id) AS количество_проживаний,
            SUM((s.check_out_date_actual - s.check_in_date_actual)) AS всего_дней
        FROM Guests g
        JOIN Stay s ON g.guest_id = s.guest_id
        GROUP BY g.guest_id, g.last_name, g.first_name
        ORDER BY количество_проживаний DESC
        LIMIT 10;
    """
    return execute_query(conn, query)


def get_fines_statistics(conn):
    query = """
        SELECT 
            ft.name AS тип_штрафа,
            COUNT(f.fine_id) AS количество,
            SUM(f.amount) AS общая_сумма,
            ROUND(AVG(f.amount), 2) AS средний_штраф,
            MIN(f.fine_date) AS первый_штраф,
            MAX(f.fine_date) AS последний_штраф
        FROM Fines f
        JOIN Fine_Types ft ON f.fine_type_id = ft.fine_type_id
        GROUP BY ft.fine_type_id, ft.name
        ORDER BY общая_сумма DESC;
    """
    return execute_query(conn, query)


def get_services_popularity(conn):
    query = """
        SELECT 
            st.name AS услуга,
            SUM(sib.quantity) AS количество_заказов,
            SUM(sib.cost * sib.quantity) AS общая_выручка,
            COUNT(DISTINCT sib.service_bill_id) AS количество_счетов
        FROM Service_Types st
        JOIN Service_In_Bill sib ON st.service_type_id = sib.service_type_id
        GROUP BY st.service_type_id, st.name
        ORDER BY общая_выручка DESC;
    """
    return execute_query(conn, query)


def get_monthly_revenue(conn):
    query = """
        SELECT 
            TO_CHAR(sb.bill_date, 'YYYY-MM') AS месяц,
            COUNT(DISTINCT sb.stay_id) AS проживаний_с_услугами,
            SUM(sb.amount) AS выручка_от_услуг,
            ROUND(AVG(sb.amount), 2) AS средний_счет
        FROM Service_Bill sb
        GROUP BY TO_CHAR(sb.bill_date, 'YYYY-MM')
        ORDER BY месяц DESC;
    """
    return execute_query(conn, query)


def get_rooms_by_type_distribution(conn):
    query = """
        SELECT 
            rt.name AS тип_номера,
            COUNT(r.room_id) AS количество_номеров,
            SUM(rt.number_of_places) AS всего_мест,
            STRING_AGG(DISTINCT h.name, ', ') AS примеры_отелей
        FROM Room_Types rt
        LEFT JOIN Rooms r ON rt.room_type_id = r.room_type_id
        LEFT JOIN Hotels h ON r.hotel_id = h.hotel_id
        GROUP BY rt.room_type_id, rt.name
        ORDER BY количество_номеров DESC;
    """
    return execute_query(conn, query)


def get_owners_portfolio(conn):
    query = """
        SELECT 
            o.last_name || ' ' || o.first_name AS владелец,
            COUNT(h.hotel_id) AS количество_отелей,
            COALESCE(SUM(h.area), 0) AS общая_площадь,
            STRING_AGG(h.name, ', ') AS список_отелей
        FROM Owners o
        LEFT JOIN Hotels h ON o.owner_id = h.owner_id
        GROUP BY o.owner_id, o.last_name, o.first_name
        ORDER BY количество_отелей DESC;
    """
    return execute_query(conn, query)


def get_current_guests(conn):
    query = """
        SELECT 
            g.last_name || ' ' || g.first_name AS гость,
            h.name AS отель,
            r.room_number AS номер,
            s.check_in_date_actual AS заехал,
            s.check_out_date_planned AS планируемый_выезд,
            (CURRENT_DATE - s.check_in_date_actual) AS дней_прожито
        FROM Stay s
        JOIN Guests g ON s.guest_id = g.guest_id
        JOIN Rooms r ON s.room_id = r.room_id
        JOIN Hotels h ON r.hotel_id = h.hotel_id
        WHERE s.check_in_date_actual <= CURRENT_DATE 
          AND s.check_out_date_actual >= CURRENT_DATE
        ORDER BY s.check_out_date_planned;
    """
    return execute_query(conn, query)


def get_free_rooms_by_date(conn, check_in_date, check_out_date):
    query = """
        SELECT 
            h.name AS отель,
            r.room_number AS номер,
            rt.name AS тип,
            r.floor AS этаж,
            t.daily_price AS цена_за_сутки
        FROM Rooms r
        JOIN Hotels h ON r.hotel_id = h.hotel_id
        JOIN Room_Types rt ON r.room_type_id = rt.room_type_id
        JOIN Tariffs t ON rt.room_type_id = t.room_type_id
        WHERE t.start_date <= %s
        AND r.room_id NOT IN (
            SELECT s.room_id
            FROM Stay s
            WHERE s.check_in_date_actual < %s 
              AND s.check_out_date_actual > %s
        )
        ORDER BY t.daily_price;
    """
    params = (check_in_date, check_out_date, check_in_date)
    return execute_query(conn, query, params)


def get_guest_history(conn, guest_last_name, guest_first_name):
    query = """
        SELECT 
            g.last_name || ' ' || g.first_name AS гость,
            h.name AS отель,
            r.room_number AS номер,
            s.check_in_date_actual AS заезд,
            s.check_out_date_actual AS выезд,
            (s.check_out_date_actual - s.check_in_date_actual) AS дней,
            ft.name AS штраф,
            t.daily_price AS тариф
        FROM Stay s
        JOIN Guests g ON s.guest_id = g.guest_id
        JOIN Rooms r ON s.room_id = r.room_id
        JOIN Hotels h ON r.hotel_id = h.hotel_id
        JOIN Tariffs t ON s.tariff_id = t.tariff_id
        LEFT JOIN Fines f ON s.fine_id = f.fine_id
        LEFT JOIN Fine_Types ft ON f.fine_type_id = ft.fine_type_id
        WHERE g.last_name ILIKE %s AND g.first_name ILIKE %s
        ORDER BY s.check_in_date_actual DESC;
    """
    params = (f"%{guest_last_name}%", f"%{guest_first_name}%")
    return execute_query(conn, query, params)


def get_hotel_revenue(conn, hotel_name):
    query = """
        SELECT 
            h.name AS отель,
            COUNT(DISTINCT s.stay_id) AS всего_проживаний,
            COUNT(DISTINCT s.guest_id) AS уникальных_гостей,
            COALESCE(SUM(t.daily_price * (s.check_out_date_actual - s.check_in_date_actual)), 0) AS доход_от_проживания,
            COALESCE(SUM(sb.amount), 0) AS доход_от_услуг,
            COALESCE(SUM(f.amount), 0) AS доход_от_штрафов,
            COALESCE(SUM(t.daily_price * (s.check_out_date_actual - s.check_in_date_actual)), 0) 
                + COALESCE(SUM(sb.amount), 0) 
                + COALESCE(SUM(f.amount), 0) AS общий_доход
        FROM Hotels h
        JOIN Rooms r ON h.hotel_id = r.hotel_id
        JOIN Stay s ON r.room_id = s.room_id
        JOIN Tariffs t ON s.tariff_id = t.tariff_id
        LEFT JOIN Service_Bill sb ON s.stay_id = sb.stay_id
        LEFT JOIN Fines f ON s.fine_id = f.fine_id
        WHERE h.name ILIKE %s
        GROUP BY h.hotel_id, h.name;
    """
    params = (f"%{hotel_name}%",)
    return execute_query(conn, query, params)


def get_services_by_guest(conn, guest_id):
    query = """
        SELECT 
            g.last_name || ' ' || g.first_name AS гость,
            st.name AS услуга,
            sib.quantity AS количество,
            sib.cost AS цена,
            sib.cost * sib.quantity AS сумма,
            sb.bill_date AS дата_счета
        FROM Service_In_Bill sib
        JOIN Service_Bill sb ON sib.service_bill_id = sb.service_bill_id
        JOIN Stay s ON sb.stay_id = s.stay_id
        JOIN Guests g ON s.guest_id = g.guest_id
        JOIN Service_Types st ON sib.service_type_id = st.service_type_id
        WHERE g.guest_id = %s
        ORDER BY sb.bill_date DESC;
    """
    return execute_query(conn, query, (guest_id,))


def get_full_guest_report(conn):
    query = """
        SELECT 
            g.last_name || ' ' || g.first_name AS гость,
            COUNT(s.stay_id) AS проживаний,
            COALESCE(SUM(t.daily_price * (s.check_out_date_actual - s.check_in_date_actual)), 0) AS расходы_на_номера,
            COALESCE(SUM(sb.amount), 0) AS расходы_на_услуги,
            COALESCE(SUM(f.amount), 0) AS штрафы,
            COALESCE(SUM(t.daily_price * (s.check_out_date_actual - s.check_in_date_actual)), 0) 
                + COALESCE(SUM(sb.amount), 0)
                + COALESCE(SUM(f.amount), 0) AS итого,
            STRING_AGG(DISTINCT h.name, ', ') AS посещенные_отели
        FROM Guests g
        LEFT JOIN Stay s ON g.guest_id = s.guest_id
        LEFT JOIN Rooms r ON s.room_id = r.room_id
        LEFT JOIN Hotels h ON r.hotel_id = h.hotel_id
        LEFT JOIN Tariffs t ON s.tariff_id = t.tariff_id
        LEFT JOIN Service_Bill sb ON s.stay_id = sb.stay_id
        LEFT JOIN Fines f ON s.fine_id = f.fine_id
        GROUP BY g.guest_id, g.last_name, g.first_name
        ORDER BY итого DESC;
    """
    return execute_query(conn, query)


def get_seasonal_analysis(conn):
    query = """
        SELECT 
            EXTRACT(MONTH FROM s.check_in_date_actual) AS месяц,
            CASE EXTRACT(MONTH FROM s.check_in_date_actual)
                WHEN 1 THEN 'Январь'
                WHEN 2 THEN 'Февраль'
                WHEN 3 THEN 'Март'
                WHEN 4 THEN 'Апрель'
                WHEN 5 THEN 'Май'
                WHEN 6 THEN 'Июнь'
                WHEN 7 THEN 'Июль'
                WHEN 8 THEN 'Август'
                WHEN 9 THEN 'Сентябрь'
                WHEN 10 THEN 'Октябрь'
                WHEN 11 THEN 'Ноябрь'
                WHEN 12 THEN 'Декабрь'
            END AS название_месяца,
            COUNT(s.stay_id) AS количество_проживаний,
            COUNT(DISTINCT s.guest_id) AS уникальных_гостей,
            ROUND(AVG(t.daily_price), 2) AS средняя_цена_номера
        FROM Stay s
        JOIN Tariffs t ON s.tariff_id = t.tariff_id
        GROUP BY EXTRACT(MONTH FROM s.check_in_date_actual)
        ORDER BY месяц;
    """
    return execute_query(conn, query)


def export_to_csv(conn, query, filename, params=None):
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            if params:
                cur.execute(query, params)
            else:
                cur.execute(query)

            rows = cur.fetchall()
            if rows:
                df = pd.DataFrame(rows)
                df.to_csv(filename, index=False, encoding='utf-8-sig')
                print(f"Данные экспортированы в {filename}")
                return True
            else:
                print("Нет данных для экспорта")
                return False
    except Exception as e:
        print(f"Ошибка экспорта: {e}")
        return False


def export_all_reports(conn):
    reports = [
        (get_all_hotels, "hotels.csv"),
        (get_all_room_types, "room_types.csv"),
        (get_current_tariffs, "tariffs.csv"),
        (get_rooms_by_hotel, "rooms.csv"),
        (get_employees_with_rooms, "employees.csv"),
        (get_hotel_occupancy, "hotel_occupancy.csv"),
        (get_fines_statistics, "fines_statistics.csv"),
        (get_services_popularity, "services_popularity.csv"),
        (get_monthly_revenue, "monthly_revenue.csv"),
        (get_owners_portfolio, "owners_portfolio.csv"),
        (get_full_guest_report, "guest_report.csv"),
        (get_seasonal_analysis, "seasonal_analysis.csv"),
    ]

    for report_func, filename in reports:
        data = report_func(conn)
        if data and isinstance(data, list) and len(data) > 0:
            df = pd.DataFrame(data)
            df.to_csv(filename, index=False, encoding='utf-8-sig')
            print(f"{filename} сохранён ({len(data)} строк)")
        else:
            print(f"{filename} — нет данных")


def main():
    conn = get_connection()
    if not conn:
        return

    print("\n" + "="*80)
    print("АНАЛИЗ БАЗЫ ДАННЫХ СЕТИ ОТЕЛЕЙ")
    print("="*80)

    print_results(get_all_hotels(conn), "1. СПИСОК ВСЕХ ОТЕЛЕЙ")
    print_results(get_all_room_types(conn), "2. ТИПЫ НОМЕРОВ")
    print_results(get_current_tariffs(conn), "3. АКТУАЛЬНЫЕ ТАРИФЫ")
    print_results(get_rooms_by_hotel(conn), "4. НОМЕРА ПО ОТЕЛЯМ")
    print_results(get_employees_with_rooms(conn), "5. СОТРУДНИКИ И ИХ НОМЕРА")
    print_results(get_guests_info(conn), "6. ИНФОРМАЦИЯ О ГОСТЯХ")

    print_results(get_hotel_occupancy(conn), "7. ЗАГРУЗКА ОТЕЛЕЙ")
    print_results(get_top_guests(conn), "8. ТОП ГОСТЕЙ")
    print_results(get_fines_statistics(conn), "9. СТАТИСТИКА ШТРАФОВ")
    print_results(get_services_popularity(conn), "10. ПОПУЛЯРНОСТЬ УСЛУГ")
    print_results(get_monthly_revenue(conn), "11. ЕЖЕМЕСЯЧНАЯ ВЫРУЧКА")
    print_results(get_rooms_by_type_distribution(conn), "12. РАСПРЕДЕЛЕНИЕ НОМЕРОВ")
    print_results(get_owners_portfolio(conn), "13. ПОРТФЕЛЬ ВЛАДЕЛЬЦЕВ")
    print_results(get_current_guests(conn), "14. ГОСТИ ПРЯМО СЕЙЧАС")

    print("\n" + "="*80)
    print("ЗАПРОСЫ С ПАРАМЕТРАМИ (ПРИМЕРЫ)")
    print("="*80)

    free_rooms = get_free_rooms_by_date(conn, '2026-01-10', '2026-01-15')
    print_results(free_rooms, "15. СВОБОДНЫЕ НОМЕРА НА 10-15.01.2026")

    guest_history = get_guest_history(conn, 'Иванов', 'Алексей')
    print_results(guest_history, "16. ИСТОРИЯ ГОСТЯ: ИВАНОВ АЛЕКСЕЙ")

    revenue = get_hotel_revenue(conn, 'Морская звезда')
    print_results(revenue, "17. ФИНАНСЫ ОТЕЛЯ 'МОРСКАЯ ЗВЕЗДА'")

    print_results(get_full_guest_report(conn), "19. ПОЛНЫЙ ОТЧЁТ ПО ГОСТЯМ")
    print_results(get_seasonal_analysis(conn), "20. СЕЗОННЫЙ АНАЛИЗ")

    print("\n" + "="*80)
    print("ЭКСПОРТ ОТЧЁТОВ В CSV")
    print("="*80)
    export_all_reports(conn)

    conn.close()
    print("\nСоединение с БД закрыто")


if __name__ == "__main__":
    main()