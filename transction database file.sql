CREATE DATABASE TransactionDB;
USE TransactionDB;

-- Users Table
CREATE TABLE user_credentials (
    mobile VARCHAR(15) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) UNIQUE,
    city VARCHAR(30),
    state VARCHAR(30),
    country VARCHAR(30),
    password VARCHAR(100) NOT NULL,
    cash_balance DECIMAL(10,2) DEFAULT 0.0,
    online_balance DECIMAL(10,2) DEFAULT 0.0
);
select* from user_credentials;
-- Transactions Table
CREATE TABLE transaction_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mobile VARCHAR(15),
    transaction_date DATETIME,
    type ENUM('IN', 'OUT'),
    amount DECIMAL(10,2),
    mode ENUM('Cash', 'Online'),
    description VARCHAR(255),
    is_spending BOOLEAN,
    FOREIGN KEY (mobile) REFERENCES user_credentials(mobile)
);

select* from transaction_history;