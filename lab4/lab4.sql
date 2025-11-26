-- 1. Загальна кількість зареєстрованих студентів
-- Використовує COUNT для підрахунку рядків з фільтром
SELECT COUNT(*) AS total_students
FROM users
WHERE role = 'STUDENT';

-- 2. Середній рейтинг курсів по всій платформі
-- Використовує AVG для обчислення середнього значення стовпця rating
SELECT AVG(rating)::NUMERIC(10,2) AS global_average_rating
FROM reviews;

-- 3. Мінімальна та максимальна оцінка, яку ставили студенти
SELECT MIN(rating) AS min_rating, MAX(rating) AS max_rating
FROM reviews;

-- 4. Кількість курсів у кожній категорії
-- Групує курси за категорією та рахує їх кількість
SELECT category, COUNT(*) AS courses_count
FROM courses
GROUP BY category
ORDER BY courses_count DESC;

-- 5. Середній рейтинг кожного курсу (тільки для курсів з рейтингом > 4.0)
-- Демонстрація GROUP BY + HAVING
SELECT course_id, AVG(rating)::NUMERIC(10,1) AS avg_rating
FROM reviews
GROUP BY course_id
HAVING AVG(rating) > 4.0;

-- 6. Кількість студентів на кожному курсі
SELECT course_id, COUNT(user_id) AS enrolled_students
FROM enrollments
GROUP BY course_id;

-- 7. INNER JOIN: Список студентів та назви курсів, на які вони записані
-- Показує лише тих, хто має записи на курси
SELECT u.first_name, u.last_name, c.title AS course_title
FROM users u
JOIN enrollments e ON u.user_id = e.user_id
JOIN courses c ON e.course_id = c.course_id
ORDER BY u.last_name;

-- 8. LEFT JOIN: Список усіх курсів та кількість відгуків про них
-- LEFT JOIN гарантує, що курси без відгуків теж будуть у списку (з count 0)
SELECT c.title, COUNT(r.review_id) AS reviews_count
FROM courses c
LEFT JOIN reviews r ON c.course_id = r.course_id
GROUP BY c.title;

-- 9. FULL JOIN (або RIGHT JOIN): Перевірка цілісності
-- Демонстрація з'єднання інструкторів та курсів.
SELECT u.last_name AS instructor, c.title AS course
FROM users u
RIGHT JOIN courses c ON u.user_id = c.instructor_id
WHERE u.role = 'INSTRUCTOR';

-- 10. Підзапит у WHERE: Знайти користувачів, які є інструкторами хоча б одного курсу
-- Вибираємо юзерів, чий ID знаходиться у списку instructor_id з таблиці курсів
SELECT first_name, last_name, email
FROM users
WHERE user_id IN (SELECT DISTINCT instructor_id FROM courses);

-- 11. Підзапит у SELECT: Вивести назву курсу та різницю його ціни (припустимо рейтингу) від середнього
-- Порівнюємо рейтинг конкретного відгуку із загальним середнім
SELECT 
    course_id, 
    rating,
    rating - (SELECT AVG(rating) FROM reviews) AS diff_from_avg
FROM reviews;

-- 12. Підзапит з кореляцією (або фільтрація): Курси, на яких немає студентів
-- Знайти курси, ID яких немає в таблиці enrollments
SELECT title
FROM courses
WHERE course_id NOT IN (SELECT DISTINCT course_id FROM enrollments);