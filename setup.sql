-- Assignment 1: The Class Bookshelf
-- Run this inside the empty database "books" (pgAdmin -> Query Tool).
-- Sample data is written for "today" = 2026-11-13.

-- ---------- STRUCTURE ----------

CREATE TABLE books (
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title          TEXT    NOT NULL,
    author         TEXT    NOT NULL,
    published_year INTEGER NOT NULL
);

CREATE TABLE students (
    id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT    NOT NULL
);

-- One row = one borrowing of one book by one student.
-- returned_on stays NULL while the book is still out.
CREATE TABLE loans (
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    book_id     INTEGER NOT NULL REFERENCES books(id),
    student_id  INTEGER NOT NULL REFERENCES students(id),
    taken_on    DATE    NOT NULL DEFAULT CURRENT_DATE,
    returned_on DATE,
    CONSTRAINT returned_after_taken
        CHECK (returned_on IS NULL OR returned_on >= taken_on)
);

-- There is only one copy of each book, so a book can have at most
-- one loan that is not returned yet.
CREATE UNIQUE INDEX one_open_loan_per_book
    ON loans (book_id)
    WHERE returned_on IS NULL;

-- ---------- DATA ----------

INSERT INTO books (title, author, published_year) VALUES
    ('Nineteen Eighty-Four', 'George Orwell',            1949),  -- id 1
    ('The Hobbit',           'J.R.R. Tolkien',           1937),  -- id 2
    ('Dune',                 'Frank Herbert',            1965),  -- id 3
    ('Under the Yoke',       'Ivan Vazov',               1894),  -- id 4
    ('Tobacco',              'Dimitar Dimov',            1951),  -- id 5
    ('Fahrenheit 451',       'Ray Bradbury',             1953),  -- id 6
    ('The Little Prince',    'Antoine de Saint-Exupery', 1943);  -- id 7

INSERT INTO students (name) VALUES
    ('Ivan Petrov'),        -- id 1
    ('Maria Georgieva'),    -- id 2
    ('Georgi Kolev'),       -- id 3
    ('Elena Todorova'),     -- id 4
    ('Nikolay Stoyanov');   -- id 5

INSERT INTO loans (book_id, student_id, taken_on, returned_on) VALUES
    -- returned loans
    (2, 1, '2026-09-20', '2026-10-01'),  -- The Hobbit, Ivan: returned
    (2, 2, '2026-10-05', '2026-10-12'),  -- The Hobbit, Maria: same book, different student, later
    (3, 3, '2026-10-01', '2026-10-28'),  -- Dune, Georgi: kept 27 days but RETURNED (must not appear as overdue)
    (4, 4, '2026-10-10', '2026-10-20'),  -- Under the Yoke, Elena: returned
    -- loans still out
    (1, 1, '2026-10-20', NULL),          -- 1984, Ivan: 24 days -> overdue
    (5, 2, '2026-10-30', NULL),          -- Tobacco, Maria: exactly 14 days -> NOT "more than 14"
    (6, 3, '2026-10-25', NULL),          -- Fahrenheit 451, Georgi: 19 days -> overdue
    (3, 5, '2026-11-10', NULL),          -- Dune, Nikolay: 3 days (Dune borrowed by 2 students)
    (7, 1, '2026-11-05', NULL);          -- Little Prince, Ivan: 8 days (Ivan has 2 books out at once)