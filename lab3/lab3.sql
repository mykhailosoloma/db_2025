
-- 1.1. Додаємо нового студента
INSERT INTO users (email, first_name, last_name, password_hash, role) 
VALUES ('new_student@example.com', 'Maksym', 'Kovalenko', 'securepass123', 'STUDENT');

-- 1.2. Додаємо ще одного користувача (щоб потім його видалити)
INSERT INTO users (email, first_name, last_name, password_hash, role) 
VALUES ('spam_bot@example.com', 'Bot', 'Spam', '12345', 'STUDENT');

-- 1.3. Записуємо Максима на курс
INSERT INTO enrollments (user_id, course_id)
VALUES ((SELECT user_id FROM users WHERE email = 'new_student@example.com'), 1);

-- Перевірка (Цей SELECT покаже нові рядки для скріншоту)
SELECT user_id, first_name, last_name, email, role 
FROM users 
WHERE role = 'STUDENT';

-- 2.2. Пошук курсів "Docker"
SELECT course_id, title, category 
FROM courses 
WHERE title LIKE '%Docker%';

-- 2.3. Хто записаний на курс ID=1?
SELECT u.last_name, u.email, c.title, e.enrollment_date
FROM enrollments e
JOIN users u ON e.user_id = u.user_id
JOIN courses c ON e.course_id = c.course_id
WHERE c.course_id = 1;

-- 3.1. Змінюємо прізвище та пошту студента Максима
UPDATE users 
SET last_name = 'Kovalenko-New', 
    email = 'maksym.official@example.com'
WHERE email = 'new_student@example.com';

-- Перевірка результату UPDATE (цей рядок покаже зміну)
SELECT * FROM users WHERE last_name = 'Kovalenko-New';

-- 4.1. Видаляємо користувача "Bot Spam"
DELETE FROM users 
WHERE email = 'spam_bot@example.com';

-- Перевірка, що користувач зник (має повернути 0 рядків)
SELECT * FROM users WHERE email = 'spam_bot@example.com';