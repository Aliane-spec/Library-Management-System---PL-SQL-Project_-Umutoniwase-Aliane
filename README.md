# Names: Umutoniwase Aliane
# ID: 27771


# Library Management System - PL/SQL Project

## 📚 Project Overview

A comprehensive Library Management System built entirely in PL/SQL that demonstrates advanced database programming concepts including collections, functions, procedures, error handling, and cursors.

## 🎯 Learning Objectives

This project serves as a practical implementation of key PL/SQL concepts:
- **Collections** (Nested Tables, VARRAYs, Associative Arrays)
- **Functions & Procedures** with parameters and return types
- **Advanced Error Handling** and exception management
- **Cursor Management** for efficient data processing
- **GOTO Statements** for controlled flow (demonstration purposes)
- **Package-based Architecture** for modular code organization

## 🗄️ Database Schema

### Tables Structure

#### 📖 Books Table
```sql
books (
    book_id NUMBER PRIMARY KEY,
    title VARCHAR2(200) NOT NULL,
    author VARCHAR2(100),
    genre VARCHAR2(50),
    published_year NUMBER,
    total_copies NUMBER DEFAULT 1,
    available_copies NUMBER DEFAULT 1,
    price NUMBER
)
```

#### 👥 Members Table
```sql
members (
    member_id NUMBER PRIMARY KEY,
    member_name VARCHAR2(100) NOT NULL,
    membership_type VARCHAR2(20) CHECK (membership_type IN ('REGULAR', 'PREMIUM', 'STUDENT')),
    join_date DATE,
    max_books_allowed NUMBER DEFAULT 3
)
```

#### 📋 Book Loans Table
```sql
book_loans (
    loan_id NUMBER PRIMARY KEY,
    book_id NUMBER REFERENCES books(book_id),
    member_id NUMBER REFERENCES members(member_id),
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount NUMBER DEFAULT 0
)
```

## 🏗️ Package Architecture

### 📦 LIBRARY_MGMT Package Specification

#### Collection Types
- `book_table` - Nested table for book records
- `genre_count_assoc` - Associative array for genre statistics
- `loan_info_array` - VARRAY for loan information

#### Key Functions
- `get_available_books()` - Returns available books with genre filtering
- `calculate_total_fine()` - Computes fines for members
- `get_popular_genres()` - Returns genre popularity statistics
- `check_borrowing_eligibility()` - Validates member borrowing rights

#### Key Procedures
- `borrow_book()` - Handles book borrowing with validation
- `return_book()` - Manages book returns and fine calculation
- `display_member_activity()` - Shows comprehensive member history
- `calculate_fines()` - Updates fines for overdue books

## 🚀 Installation & Setup

### Prerequisites
- Oracle Database 11g or higher
- SQL*Plus or SQL Developer
- Basic PL/SQL execution privileges

### Step-by-Step Setup

1. **Create Tables & Sample Data**
   ```sql
   -- Execute the table creation scripts first
   -- Then run the sample data insertion scripts
   ```

2. **Create Package Specification**
   ```sql
   -- Run the LIBRARY_MGMT package specification
   ```

3. **Create Package Body**
   ```sql
   -- Run the LIBRARY_MGMT package body
   ```

4. **Execute Demonstration Script**
   ```sql
   -- Run the demonstration script to test all features
   ```

## 💡 Key Features Demonstrated

### 1. Collection Types Implementation
- **Nested Tables**: Used for returning multiple book records
- **Associative Arrays**: Efficient genre counting and statistics
- **VARRAY**: Fixed-size arrays for loan information storage

### 2. Function Design Patterns
- **Parameterized Functions**: Flexible genre-based filtering
- **Boolean Return Types**: Eligibility checking functions
- **Collection Return Types**: Returning multiple records efficiently

### 3. Procedure Best Practices
- **Transaction Management**: COMMIT/ROLLBACK in data modification procedures
- **Input Validation**: Comprehensive parameter validation
- **Error Handling**: Structured exception management

### 4. Advanced Error Handling
```sql
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle missing data scenarios
    WHEN OTHERS THEN
        -- General error handling with detailed messages
```

### 5. Cursor Implementation
- **Explicit Cursors**: Fine calculation and member activity
- **Cursor FOR Loops**: Efficient record processing
- **Parameterized Cursors**: Dynamic query execution

### 6. GOTO Usage (Demonstration)
- **Controlled Flow**: Clean error exit points
- **Label Management**: Structured code organization
- **Best Practices**: Limited and justified usage

## 🧪 Testing the System

### Sample Test Scenarios

1. **Book Borrowing Flow**
   ```sql
   -- Test successful borrowing
   BEGIN
       library_mgmt.borrow_book(1, 101);
   END;
   ```

2. **Member Activity Review**
   ```sql
   -- View member borrowing history
   BEGIN
       library_mgmt.display_member_activity(101);
   END;
   ```

3. **Fine Calculation**
   ```sql
   -- Check member fines
   SELECT library_mgmt.calculate_total_fine(101) FROM dual;
   ```

4. **Genre Analysis**
   ```sql
   -- Get popular genres
   DECLARE
       genres library_mgmt.genre_count_assoc;
   BEGIN
       genres := library_mgmt.get_popular_genres();
   END;
   ```

## 📊 Business Logic Highlights

### Borrowing Rules
- **Maximum Books**: Varies by membership type (Regular: 3, Premium: 5, Student: 4)
- **Loan Period**: 21 days for all members
- **Fine System**: $0.50 per day for overdue books
- **Eligibility**: No outstanding fines and within borrowing limit

### Membership Types
- **PREMIUM**: 5 books maximum, priority access
- **REGULAR**: 3 books maximum, standard access
- **STUDENT**: 4 books maximum, extended periods

## 🔧 Customization Options

### Easy Modifications

1. **Fine Rates**
   ```sql
   -- Modify in package specification
   g_daily_fine_rate CONSTANT NUMBER := 1.00; -- Increase to $1.00/day
   ```

2. **Loan Periods**
   ```sql
   g_max_loan_days CONSTANT NUMBER := 30; -- Extend to 30 days
   ```

3. **Membership Limits**
   ```sql
   -- Update in members table defaults
   max_books_allowed NUMBER DEFAULT 5
   ```

## 🐛 Error Handling Scenarios

The system handles various error conditions:
- ✅ Invalid book/member IDs
- ✅ Insufficient available copies
- ✅ Maximum borrowing limit exceeded
- ✅ Outstanding fines blocking borrowing
- ✅ Database constraint violations

## 📈 Performance Features

- **Bulk Operations**: Collection-based processing for multiple records
- **Efficient Cursors**: Proper cursor management and closure
- **Index-Friendly Queries**: Optimized for primary key lookups
- **Transaction Control**: Minimal locking periods

## 🎓 Learning Outcomes

After studying this project, you will understand:

1. **PL/SQL Collections**: When and how to use different collection types
2. **Modular Programming**: Package-based code organization
3. **Database Programming**: Transaction management and SQL integration
4. **Error Handling**: Comprehensive exception management strategies
5. **Code Maintenance**: Best practices for readable, maintainable code

## 📝 Usage Notes

- Designed for educational purposes
- Includes demonstration of GOTO (use sparingly in production)
- Comprehensive error handling for learning
- Modular design for easy extension
- Well-commented code for understanding

## 🤝 Contributing

This is an educational project. Feel free to:
- Extend functionality with new features
- Improve error handling mechanisms
- Add additional validation rules
- Enhance performance optimizations

## 📄 License

Educational Use - Feel free to modify and learn from the code!

---

