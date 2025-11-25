CREATE OR REPLACE PACKAGE library_mgmt AS
    -- Collection types
    TYPE book_table IS TABLE OF books%ROWTYPE;
    TYPE genre_count_assoc IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
    TYPE loan_info_array IS VARRAY(100) OF VARCHAR2(500);
    
    -- Procedures
    PROCEDURE borrow_book(p_book_id IN NUMBER, p_member_id IN NUMBER);
    PROCEDURE return_book(p_loan_id IN NUMBER);
    PROCEDURE display_member_activity(p_member_id IN NUMBER);
    PROCEDURE calculate_fines;
    
    -- Functions
    FUNCTION get_available_books(p_genre IN VARCHAR2 DEFAULT NULL) RETURN book_table;
    FUNCTION calculate_total_fine(p_member_id IN NUMBER) RETURN NUMBER;
    FUNCTION get_popular_genres RETURN genre_count_assoc;
    FUNCTION check_borrowing_eligibility(p_member_id IN NUMBER) RETURN BOOLEAN;
    
    -- Global variables
    g_daily_fine_rate CONSTANT NUMBER := 0.50;
    g_max_loan_days CONSTANT NUMBER := 21;
END library_mgmt;
/





CREATE OR REPLACE PACKAGE BODY library_mgmt AS

    -- Function to get available books with optional genre filter
    FUNCTION get_available_books(p_genre IN VARCHAR2 DEFAULT NULL) RETURN book_table IS
        v_books book_table := book_table();
        v_query VARCHAR2(1000);
        v_counter NUMBER := 1;
    BEGIN
        v_query := 'SELECT * FROM books WHERE available_copies > 0';
        
        IF p_genre IS NOT NULL THEN
            v_query := v_query || ' AND genre = :genre';
        END IF;
        
        v_query := v_query || ' ORDER BY title';
        
        IF p_genre IS NOT NULL THEN
            FOR book_rec IN (SELECT * FROM books 
                           WHERE available_copies > 0 AND genre = p_genre 
                           ORDER BY title) LOOP
                v_books.EXTEND;
                v_books(v_counter) := book_rec;
                v_counter := v_counter + 1;
            END LOOP;
        ELSE
            FOR book_rec IN (SELECT * FROM books 
                           WHERE available_copies > 0 
                           ORDER BY title) LOOP
                v_books.EXTEND;
                v_books(v_counter) := book_rec;
                v_counter := v_counter + 1;
            END LOOP;
        END IF;
        
        RETURN v_books;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error retrieving available books: ' || SQLERRM);
            RETURN book_table();
    END get_available_books;

    -- Function to calculate total fine for a member
    FUNCTION calculate_total_fine(p_member_id IN NUMBER) RETURN NUMBER IS
        v_total_fine NUMBER := 0;
        CURSOR fine_cursor IS
            SELECT loan_id, due_date, return_date, fine_amount
            FROM book_loans
            WHERE member_id = p_member_id 
            AND (return_date IS NULL OR fine_amount > 0);
    BEGIN
        FOR fine_rec IN fine_cursor LOOP
            IF fine_rec.return_date IS NULL AND fine_rec.due_date < SYSDATE THEN
                -- Book not returned and overdue
                v_total_fine := v_total_fine + 
                    (SYSDATE - fine_rec.due_date) * g_daily_fine_rate;
            ELSIF fine_rec.fine_amount > 0 THEN
                -- Already calculated fine
                v_total_fine := v_total_fine + fine_rec.fine_amount;
            END IF;
        END LOOP;
        
        RETURN v_total_fine;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error calculating fines: ' || SQLERRM);
            RETURN -1;
    END calculate_total_fine;

    -- Function to get popular genres using associative array
    FUNCTION get_popular_genres RETURN genre_count_assoc IS
        v_genres genre_count_assoc;
    BEGIN
        FOR genre_rec IN (SELECT genre, COUNT(*) as book_count
                         FROM books 
                         GROUP BY genre 
                         ORDER BY book_count DESC) LOOP
            v_genres(genre_rec.genre) := genre_rec.book_count;
        END LOOP;
        
        RETURN v_genres;
    END get_popular_genres;

    -- Function to check if member can borrow more books
    FUNCTION check_borrowing_eligibility(p_member_id IN NUMBER) RETURN BOOLEAN IS
        v_current_loans NUMBER;
        v_max_allowed NUMBER;
        v_total_fine NUMBER;
    BEGIN
        -- Check current loans
        SELECT COUNT(*) INTO v_current_loans
        FROM book_loans 
        WHERE member_id = p_member_id AND return_date IS NULL;
        
        -- Get max books allowed
        SELECT max_books_allowed INTO v_max_allowed
        FROM members WHERE member_id = p_member_id;
        
        -- Check fines
        v_total_fine := calculate_total_fine(p_member_id);
        
        IF v_current_loans >= v_max_allowed THEN
            DBMS_OUTPUT.PUT_LINE('Member has reached maximum borrowing limit');
            RETURN FALSE;
        ELSIF v_total_fine > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Member has outstanding fines: $' || v_total_fine);
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Member not found');
            RETURN FALSE;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error checking eligibility: ' || SQLERRM);
            RETURN FALSE;
    END check_borrowing_eligibility;

    -- Procedure to borrow a book with GOTO for error handling
    PROCEDURE borrow_book(p_book_id IN NUMBER, p_member_id IN NUMBER) IS
        v_available_copies NUMBER;
        v_book_title VARCHAR2(200);
        v_member_name VARCHAR2(100);
        v_loan_id NUMBER;
    BEGIN
        -- Validate book availability
        SELECT available_copies, title INTO v_available_copies, v_book_title
        FROM books WHERE book_id = p_book_id;
        
        IF v_available_copies <= 0 THEN
            DBMS_OUTPUT.PUT_LINE('Book is not available for borrowing');
            GOTO error_exit;
        END IF;
        
        -- Get member name
        SELECT member_name INTO v_member_name 
        FROM members WHERE member_id = p_member_id;
        
        -- Check borrowing eligibility
        IF NOT check_borrowing_eligibility(p_member_id) THEN
            GOTO error_exit;
        END IF;
        
        -- Generate loan ID
        SELECT NVL(MAX(loan_id), 0) + 1 INTO v_loan_id FROM book_loans;
        
        -- Create loan record
        INSERT INTO book_loans (loan_id, book_id, member_id, loan_date, due_date)
        VALUES (v_loan_id, p_book_id, p_member_id, SYSDATE, SYSDATE + g_max_loan_days);
        
        -- Update available copies
        UPDATE books SET available_copies = available_copies - 1
        WHERE book_id = p_book_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Book borrowed successfully!');
        DBMS_OUTPUT.PUT_LINE('Book: ' || v_book_title);
        DBMS_OUTPUT.PUT_LINE('Borrower: ' || v_member_name);
        DBMS_OUTPUT.PUT_LINE('Due Date: ' || TO_CHAR(SYSDATE + g_max_loan_days, 'DD-MON-YYYY'));
        GOTO success_exit;
        
        <<error_exit>>
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Book borrowing failed');
        RETURN;
        
        <<success_exit>>
        NULL;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Book or Member not found');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error borrowing book: ' || SQLERRM);
            ROLLBACK;
    END borrow_book;

    -- Procedure to return a book
    PROCEDURE return_book(p_loan_id IN NUMBER) IS
        v_loan_rec book_loans%ROWTYPE;
        v_fine_amount NUMBER := 0;
        CURSOR loan_cursor IS
            SELECT * FROM book_loans WHERE loan_id = p_loan_id;
    BEGIN
        OPEN loan_cursor;
        FETCH loan_cursor INTO v_loan_rec;
        
        IF loan_cursor%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('Loan record not found');
            CLOSE loan_cursor;
            RETURN;
        END IF;
        
        CLOSE loan_cursor;
        
        -- Calculate fine if overdue
        IF v_loan_rec.due_date < SYSDATE THEN
            v_fine_amount := (SYSDATE - v_loan_rec.due_date) * g_daily_fine_rate;
            DBMS_OUTPUT.PUT_LINE('Overdue fine: $' || ROUND(v_fine_amount, 2));
        END IF;
        
        -- Update loan record
        UPDATE book_loans 
        SET return_date = SYSDATE,
            fine_amount = v_fine_amount
        WHERE loan_id = p_loan_id;
        
        -- Update available copies
        UPDATE books SET available_copies = available_copies + 1
        WHERE book_id = v_loan_rec.book_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Book returned successfully!');
        IF v_fine_amount > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Please pay fine: $' || ROUND(v_fine_amount, 2));
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error returning book: ' || SQLERRM);
            ROLLBACK;
    END return_book;

    -- Procedure to display member activity using cursor
    PROCEDURE display_member_activity(p_member_id IN NUMBER) IS
        CURSOR member_activity_cursor IS
            SELECT bl.loan_id, b.title, bl.loan_date, bl.due_date, 
                   bl.return_date, bl.fine_amount,
                   CASE 
                       WHEN bl.return_date IS NULL AND bl.due_date < SYSDATE THEN 'OVERDUE'
                       WHEN bl.return_date IS NULL THEN 'BORROWED'
                       ELSE 'RETURNED'
                   END as status
            FROM book_loans bl
            JOIN books b ON bl.book_id = b.book_id
            WHERE bl.member_id = p_member_id
            ORDER BY bl.loan_date DESC;
            
        v_loan_info loan_info_array := loan_info_array();
        v_counter NUMBER := 1;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== Member Activity Report ===');
        
        FOR activity_rec IN member_activity_cursor LOOP
            v_loan_info.EXTEND;
            v_loan_info(v_counter) := 
                'Loan ID: ' || activity_rec.loan_id ||
                ' | Book: ' || activity_rec.title ||
                ' | Status: ' || activity_rec.status ||
                ' | Loan Date: ' || TO_CHAR(activity_rec.loan_date, 'DD-MON-YY') ||
                ' | Due Date: ' || TO_CHAR(activity_rec.due_date, 'DD-MON-YY') ||
                CASE WHEN activity_rec.fine_amount > 0 THEN 
                    ' | Fine: $' || activity_rec.fine_amount 
                ELSE '' END;
            
            v_counter := v_counter + 1;
        END LOOP;
        
        -- Display activity using collection
        IF v_loan_info.COUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No borrowing activity found');
        ELSE
            FOR i IN 1..v_loan_info.COUNT LOOP
                DBMS_OUTPUT.PUT_LINE(v_loan_info(i));
            END LOOP;
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error displaying activity: ' || SQLERRM);
    END display_member_activity;

    -- Procedure to calculate fines for all overdue books
    PROCEDURE calculate_fines IS
        v_updated_count NUMBER := 0;
    BEGIN
        UPDATE book_loans 
        SET fine_amount = (SYSDATE - due_date) * g_daily_fine_rate
        WHERE return_date IS NULL 
        AND due_date < SYSDATE
        AND fine_amount = 0;
        
        v_updated_count := SQL%ROWCOUNT;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Fines calculated for ' || v_updated_count || ' overdue books');
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error calculating fines: ' || SQLERRM);
            ROLLBACK;
    END calculate_fines;

END library_mgmt;
/