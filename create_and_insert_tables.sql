-- Create tables for library system
CREATE TABLE books (
    book_id NUMBER PRIMARY KEY,
    title VARCHAR2(200) NOT NULL,
    author VARCHAR2(100),
    genre VARCHAR2(50),
    published_year NUMBER,
    total_copies NUMBER DEFAULT 1,
    available_copies NUMBER DEFAULT 1,
    price NUMBER
);

CREATE TABLE members (
    member_id NUMBER PRIMARY KEY,
    member_name VARCHAR2(100) NOT NULL,
    membership_type VARCHAR2(20) CHECK (membership_type IN ('REGULAR', 'PREMIUM', 'STUDENT')),
    join_date DATE,
    max_books_allowed NUMBER DEFAULT 3
);

CREATE TABLE book_loans (
    loan_id NUMBER PRIMARY KEY,
    book_id NUMBER REFERENCES books(book_id),
    member_id NUMBER REFERENCES members(member_id),
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount NUMBER DEFAULT 0
);

-- Insert sample data
INSERT INTO books VALUES (1, 'The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction', 1925, 3, 3, 15.99);
INSERT INTO books VALUES (2, 'To Kill a Mockingbird', 'Harper Lee', 'Fiction', 1960, 2, 2, 12.50);
INSERT INTO books VALUES (3, '1984', 'George Orwell', 'Science Fiction', 1949, 4, 4, 10.75);
INSERT INTO books VALUES (4, 'Pride and Prejudice', 'Jane Austen', 'Romance', 1813, 2, 2, 11.25);
INSERT INTO books VALUES (5, 'The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 1937, 3, 3, 14.99);

INSERT INTO members VALUES (101, 'Alice Johnson', 'PREMIUM', DATE '2023-01-15', 5);
INSERT INTO members VALUES (102, 'Bob Smith', 'REGULAR', DATE '2023-02-20', 3);
INSERT INTO members VALUES (103, 'Carol Davis', 'STUDENT', DATE '2023-03-10', 4);
INSERT INTO members VALUES (104, 'David Wilson', 'REGULAR', DATE '2023-04-05', 3);

COMMIT;