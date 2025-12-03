-- 1.1. Таблиця РОЛЕЙ (Нормалізація users)
CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- 1.2. Таблиця КАТЕГОРІЙ (Нормалізація courses)
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- 1.3. Таблиця ТИПІВ КОНТЕНТУ (Нормалізація lessons)
CREATE TABLE content_types (
    content_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

-- 2.1. Таблиця USERS (Змінено: role -> role_id)
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(150) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id INTEGER NOT NULL REFERENCES roles(role_id) ON DELETE RESTRICT, -- FK на roles
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2.2. Таблиця COURSES (Змінено: category -> category_id)
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    instructor_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE SET NULL, -- FK на categories
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2.3. Таблиця MODULES (Без змін)
CREATE TABLE modules (
    module_id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    order_index INTEGER NOT NULL CHECK (order_index >= 0)
);

-- 2.4. Таблиця LESSONS (Змінено: content_type -> content_type_id)
CREATE TABLE lessons (
    lesson_id SERIAL PRIMARY KEY,
    module_id INTEGER NOT NULL REFERENCES modules(module_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    content_type_id INTEGER NOT NULL REFERENCES content_types(content_type_id), -- FK
    content_data TEXT,
    order_index INTEGER NOT NULL CHECK (order_index >= 0)
);

-- 2.5. Таблиця ENROLLMENTS (Без змін)
CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_enrollment UNIQUE (user_id, course_id)
);

-- 2.6. Таблиця PROGRESS (Без змін)
CREATE TABLE progress (
    progress_id SERIAL PRIMARY KEY,
    enrollment_id INTEGER NOT NULL REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    lesson_id INTEGER NOT NULL REFERENCES lessons(lesson_id) ON DELETE CASCADE,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_lesson_progress UNIQUE (enrollment_id, lesson_id)
);

-- 2.7. Таблиця REVIEWS (Без змін)
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE SET NULL,
    course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_review_per_course UNIQUE (user_id, course_id)
);

-- 2.8. Таблиця CERTIFICATES (Без змін)
CREATE TABLE certificates (
    certificate_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    issue_date DATE DEFAULT CURRENT_DATE,
    certificate_url VARCHAR(255) NOT NULL UNIQUE
);

INSERT INTO roles (role_name) VALUES ('ADMIN'), ('INSTRUCTOR'), ('STUDENT');
INSERT INTO categories (category_name) VALUES ('Databases'), ('DevOps'), ('Design');
INSERT INTO content_types (type_name) VALUES ('VIDEO'), ('TEXT'), ('QUIZ');

INSERT INTO users (email, first_name, last_name, password_hash, role_id) VALUES
('admin@edu.com', 'Ivan', 'Adminov', 'hash123', 1),
('teacher1@edu.com', 'Petro', 'Vychytel', 'hash456', 2),
('teacher2@edu.com', 'Olena', 'Nauka', 'hash789', 2),
('student1@edu.com', 'Andriy', 'Studentko', 'hash000', 3),
('student2@edu.com', 'Maria', 'Uchen', 'hash111', 3),
('student3@edu.com', 'Oleh', 'Novachok', 'hash222', 3);

INSERT INTO courses (instructor_id, title, description, category_id) VALUES
(2, 'Intro to PostgreSQL', 'Learn basics of SQL', 1),
(2, 'Advanced Docker', 'Containerization', 2),
(3, 'UX/UI Design Principles', 'Interfaces', 3);

INSERT INTO modules (course_id, title, order_index) VALUES
(1, 'Basics of SQL', 1),
(1, 'Database Design', 2),
(2, 'Docker Compose', 1),
(3, 'Color Theory', 1);

INSERT INTO lessons (module_id, title, content_type_id, content_data, order_index) VALUES
(1, 'What is a Table?', 1, 'http://video.url/1', 1),
(1, 'SELECT Statement', 2, 'SELECT * FROM...', 2),
(3, 'Writing compose.yaml', 2, 'version: "3.8"...', 1),
(4, 'RGB vs CMYK', 1, 'http://video.url/2', 1);

INSERT INTO enrollments (user_id, course_id) VALUES (4, 1), (4, 3), (5, 1), (6, 2);
INSERT INTO reviews (user_id, course_id, rating, comment) VALUES (4, 1, 5, 'Cool!');