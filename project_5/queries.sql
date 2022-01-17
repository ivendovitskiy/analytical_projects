/*
Запрос 1. Изучить таблицу airports и вывести список городов (city), в которых есть аэропорты
*/

SELECT
    DISTINCT city
FROM
    airports

/*
Запрос 2. Изучить таблицу flights и подсчитать количество вылетов (flight_id) из каждого аэропорта вылета (departure_airport).
Результат (cnt_flights) вывести вместе со столбцом departure_airport — сначала departure_airport, потом cnt_flights.
Итоговую таблицу отсортировать в порядке убывания количества вылетов
*/

SELECT
    departure_airport,
    COUNT(flight_id) AS cnt_flights
FROM
    flights
GROUP BY
    departure_airport
ORDER BY
    cnt_flights DESC

/*
Запрос 3. Найти количество рейсов на каждой модели самолёта с вылетом в сентябре 2018 года. Назвать получившийся столбец flights_amount и вывести его
вместе со столбцом model. Столбцы выводите в таком порядке: model, flights_amount
*/

SELECT
    aircrafts.model AS model,
    COUNT(flight_id) AS flights_amount
FROM
    aircrafts
    RIGHT JOIN flights ON aircrafts.aircraft_code=flights.aircraft_code
WHERE
    EXTRACT(month FROM departure_time) = 9
    AND EXTRACT(year FROM departure_time) = 2018
GROUP BY
    model

/*
Запрос 4. Посчитать количество рейсов по всем моделям самолётов Boeing, Airbus и другим ('other') в сентябре.
Типы моделей поместить в столбец type_aircraft, а количество рейсов — во flights_amount. Вывести их на экран
*/

SELECT
    CASE WHEN model LIKE 'Boeing%' THEN
        'Boeing'
    WHEN model LIKE 'Airbus%' THEN
        'Airbus'
    ELSE
        'other'
    END AS type_aircraft,
    COUNT(flight_id) AS flight_amount
FROM
    aircrafts
    INNER JOIN flights ON aircrafts.aircraft_code = flights.aircraft_code
WHERE
    EXTRACT('month' FROM departure_time::date) = 9
GROUP BY
    type_aircraft

/*
Запрос 5. Посчитать среднее количество прибывающих рейсов в день для каждого города за август 2018 года. Назвать получившееся поле average_flights,
вместе с ним вывести столбец city. Вывести столбцы в таком порядке: city, average_flights
*/

SELECT
    city,
    AVG(cnt_flights) AS average_flights
FROM
    (SELECT
        city,
        COUNT(flight_id) as cnt_flights
    FROM
        airports
        LEFT JOIN flights ON airport_code=arrival_airport
    WHERE
        EXTRACT('month' FROM arrival_time) = 8
    GROUP BY
        city,
        EXTRACT('day' FROM arrival_time)) AS Sub
GROUP BY
    city

/*
Запрос 6. Установить фестивали, которые проходили с 23 июля по 30 сентября 2018 года в Москве, и номер недели, в которую они проходили.
Выведите название фестиваля festival_name и номер недели festival_week
*/

SELECT
    festival_name,
    EXTRACT('week' FROM festival_date) AS festival_week
FROM
    festivals
WHERE
    festival_city = 'Москва'
    AND festival_date::date BETWEEN '2018-07-23' AND '2018-09-30'

/*
Запрос 7. Для каждой недели с 23 июля по 30 сентября 2018 года посчитать количество билетов, купленных на рейсы в Москву (номер недели week_number и 
количество билетов ticket_amount). Получить таблицу, в которой будет номер недели; информация о количестве купленных за неделю билетов; номер недели ещё раз,
если в эту неделю проходил фестиваль, и nan, если не проходил; а также название фестиваля festival_name. 
Вывести столбцы в таком порядке: week_number, ticket_amount, festival_week, festival_name
*/

SELECT
    DISTINCT EXTRACT('week' FROM arrival_time) AS week_number,
    COUNT(ticket_flights.ticket_no) AS ticket_amount,
    EXTRACT('week' FROM festival_date) AS festival_week,
    festival_name
FROM
    flights
    INNER JOIN ticket_flights ON flights.flight_id = ticket_flights.flight_id
    INNER JOIN airports ON arrival_airport = airport_code
    LEFT JOIN festivals ON (EXTRACT('week' FROM arrival_time) = EXTRACT('week' FROM festival_date)
    AND city = festival_city)
WHERE
    arrival_time::date BETWEEN '2018-07-23' AND '2018-09-30'
    AND city = 'Москва'
GROUP BY
    week_number,
    festival_week,
    festival_name