-- Question 1: Which books are out right now and who has them?
-- Returns one row per book that has not been returned yet:
-- title, student name, and the date it was taken.
-- "Not returned" means returned_on IS NULL (= NULL would never match).
SELECT b.title,
       s.name     AS student,
       l.taken_on AS date_taken
FROM loans l
JOIN books    b ON b.id = l.book_id
JOIN students s ON s.id = l.student_id
WHERE l.returned_on IS NULL
ORDER BY l.taken_on;


-- Question 2: Who has kept a book for more than 14 days, and which book is it?
-- Returns the student, the book, the date taken and how many days it has
-- been out, only for books that are STILL not returned and were taken
-- MORE than 14 days ago (exactly 14 days does not count).
-- The result depends on today's date (CURRENT_DATE), so it changes over time.
SELECT s.name                       AS student,
       b.title,
       l.taken_on                   AS date_taken,
       CURRENT_DATE - l.taken_on    AS days_kept
FROM loans l
JOIN books    b ON b.id = l.book_id
JOIN students s ON s.id = l.student_id
WHERE l.returned_on IS NULL
  AND CURRENT_DATE - l.taken_on > 14
ORDER BY days_kept DESC;
