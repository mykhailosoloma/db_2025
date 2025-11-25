
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,        -- Автоматичний ідентифікатор
    email VARCHAR(150) NOT NULL UNIQUE, -- Пошта має бути унікальною
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL, -- Зберігаємо хеш пароля
    role VARCHAR(20) NOT NULL CHECK (role IN ('STUDENT', 'INSTRUCTOR', 'ADMIN')), -- Обмеження допустимих ролей
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Дата реєстрації (автоматично)
);

-- 2.2. Таблиця COURSES (Курси)
-- Курси створюються інструкторами.
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    -- Зв'язок з таблицею users. Якщо видалити інструктора, видаляться і його курси (CASCADE)
    instructor_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2.3. Таблиця MODULES (Модулі)
-- Логічні частини курсу.
CREATE TABLE modules (
    module_id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    order_index INTEGER NOT NULL CHECK (order_index >= 0) -- Порядковий номер не може бути від'ємним
);

-- 2.4. Таблиця LESSONS (Уроки)
CREATE TABLE lessons (
    lesson_id SERIAL PRIMARY KEY,
    module_id INTEGER NOT NULL REFERENCES modules(module_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    -- Тип контенту обмежений трьома варіантами
    content_type VARCHAR(20) NOT NULL CHECK (content_type IN ('VIDEO', 'TEXT', 'QUIZ')),
    content_data TEXT, -- Посилання на відео або текст уроку
    order_index INTEGER NOT NULL CHECK (order_index >= 0)
);

-- 2.5. Таблиця ENROLLMENTS (Зарахування)
-- Проміжна таблиця для зв'язку "Багато-до-багатьох" (Студенти <-> Курси).
CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Унікальна пара: студент не може записатися на той самий курс двічі
    CONSTRAINT unique_enrollment UNIQUE (user_id, course_id)
);

-- 2.6. Таблиця PROGRESS (Прогрес)
-- Фіксує факт завершення конкретного уроку студентом.
CREATE TABLE progress (
    progress_id SERIAL PRIMARY KEY,
    enrollment_id INTEGER NOT NULL REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    lesson_id INTEGER NOT NULL REFERENCES lessons(lesson_id) ON DELETE CASCADE,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Один урок не можна "завершити" двічі в рамках одного навчання
    CONSTRAINT unique_lesson_progress UNIQUE (enrollment_id, lesson_id)
);

-- 2.7. Таблиця REVIEWS (Відгуки)
-- Оцінки курсів від студентів.
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE SET NULL, -- Якщо юзера видалено, відгук залишається (автор стає NULL)
    course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5), -- Рейтинг тільки від 1 до 5
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Один користувач може залишити лише один відгук на конкретний курс
    CONSTRAINT unique_review_per_course UNIQUE (user_id, course_id)
);

-- 2.8. Таблиця CERTIFICATES (Сертифікати)
-- Видаються після завершення курсу.
CREATE TABLE certificates (
    certificate_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    issue_date DATE DEFAULT CURRENT_DATE,
    certificate_url VARCHAR(255) NOT NULL UNIQUE -- URL сертифіката має бути унікальним
);

-- 3. НАПОВНЕННЯ ДАНИМИ (DML)

-- Вставка Користувачів
INSERT INTO users (email, first_name, last_name, password_hash, role) VALUES
('admin@edu.com', 'Ivan', 'Adminov', 'hash123', 'ADMIN'),
('teacher1@edu.com', 'Petro', 'Vychytel', 'hash456', 'INSTRUCTOR'),
('teacher2@edu.com', 'Olena', 'Nauka', 'hash789', 'INSTRUCTOR'),
('student1@edu.com', 'Andriy', 'Studentko', 'hash000', 'STUDENT'),
('student2@edu.com', 'Maria', 'Uchen', 'hash111', 'STUDENT'),
('student3@edu.com', 'Oleh', 'Novachok', 'hash222', 'STUDENT');

-- Вставка Курсів
INSERT INTO courses (instructor_id, title, description, category) VALUES
(2, 'Intro to PostgreSQL', 'Learn basics of SQL and DB design', 'Databases'),
(2, 'Advanced Docker', 'Containerization for professionals', 'DevOps'),
(3, 'UX/UI Design Principles', 'How to make user friendly interfaces', 'Design');

-- Вставка Модулів
INSERT INTO modules (course_id, title, order_index) VALUES
(1, 'Basics of SQL', 1),
(1, 'Database Design', 2),
(2, 'Docker Compose', 1),
(3, 'Color Theory', 1);

-- Вставка Уроків
INSERT INTO lessons (module_id, title, content_type, content_data, order_index) VALUES
(1, 'What is a Table?', 'VIDEO', 'http://video.url/1', 1),
(1, 'SELECT Statement', 'TEXT', 'SELECT * FROM...', 2),
(3, 'Writing compose.yaml', 'TEXT', 'version: "3.8"...', 1),
(4, 'RGB vs CMYK', 'VIDEO', 'http://video.url/2', 1);

-- Вставка Зарахувань
INSERT INTO enrollments (user_id, course_id) VALUES
(4, 1), 
(4, 3), 
(5, 1), 
(6, 2); 

-- Вставка Прогресу
INSERT INTO progress (enrollment_id, lesson_id) VALUES
(1, 1),
(1, 2),
(3, 1);

-- Вставка Відгуків
INSERT INTO reviews (user_id, course_id, rating, comment) VALUES
(4, 1, 5, 'Чудовий курс, все зрозуміло!'),
(5, 1, 4, 'Добре, але мало прикладів.'),
(6, 2, 5, 'Docker це сила!');

-- Вставка Сертифікатів
INSERT INTO certificates (user_id, course_id, certificate_url) VALUES
(4, 1, 'https://edu.com/cert/uuid-1234-5678');