SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== LIBRARY MANAGEMENT SYSTEM DEMO ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test available books function
    DBMS_OUTPUT.PUT_LINE('--- Available Fiction Books ---');
    DECLARE
        available_books library_mgmt.book_table;
    BEGIN
        available_books := library_mgmt.get_available_books('Fiction');
        FOR i IN 1..available_books.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(available_books(i).title || ' by ' || 
                               available_books(i).author);
        END LOOP;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test borrowing functionality
    DBMS_OUTPUT.PUT_LINE('--- Borrowing Books ---');
    library_mgmt.borrow_book(1, 101); -- Successful borrow
    DBMS_OUTPUT.PUT_LINE('');
    library_mgmt.borrow_book(1, 102); -- Another successful borrow
    DBMS_OUTPUT.PUT_LINE('');
    library_mgmt.borrow_book(1, 103); -- Should fail (no copies left)
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Display member activity
    DBMS_OUTPUT.PUT_LINE('--- Member Activity ---');
    library_mgmt.display_member_activity(101);
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test popular genres function
    DBMS_OUTPUT.PUT_LINE('--- Popular Genres ---');
    DECLARE
        genres library_mgmt.genre_count_assoc;
        genre_name VARCHAR2(50);
    BEGIN
        genres := library_mgmt.get_popular_genres();
        genre_name := genres.FIRST;
        
        WHILE genre_name IS NOT NULL LOOP
            DBMS_OUTPUT.PUT_LINE(genre_name || ': ' || genres(genre_name) || ' books');
            genre_name := genres.NEXT(genre_name);
        END LOOP;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test fine calculation
    DBMS_OUTPUT.PUT_LINE('--- Fine Calculation ---');
    DBMS_OUTPUT.PUT_LINE('Total fine for member 101: $' || 
                        library_mgmt.calculate_total_fine(101));
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Simulate overdue and return
    DBMS_OUTPUT.PUT_LINE('--- Returning Book with Fine ---');
    -- Update due date to simulate overdue
    UPDATE book_loans SET due_date = SYSDATE - 5 WHERE loan_id = 1;
    COMMIT;
    
    library_mgmt.return_book(1);
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- Error Handling Examples ---');
    library_mgmt.borrow_book(999, 101); -- Non-existent book
    library_mgmt.borrow_book(2, 999);   -- Non-existent member
    
END;
/