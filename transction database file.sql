-- Create Database
CREATE DATABASE IF NOT EXISTS TransactionDB;
USE TransactionDB;

-- User Credentials Table
CREATE TABLE IF NOT EXISTS user_credentials (
    mobile VARCHAR(15) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) UNIQUE,
    city VARCHAR(30),
    state VARCHAR(30),
    country VARCHAR(30),
    password VARCHAR(100) NOT NULL,
    cash_balance DECIMAL(10,2) DEFAULT 0.0,
    online_balance DECIMAL(10,2) DEFAULT 0.0
) ENGINE=InnoDB;

-- User Files Table
CREATE TABLE IF NOT EXISTS user_files (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mobile VARCHAR(15) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mobile) REFERENCES user_credentials(mobile) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Transaction History Table (Updated)
CREATE TABLE IF NOT EXISTS transaction_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mobile VARCHAR(15) NOT NULL,
    file_id INT NOT NULL,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    type ENUM('IN', 'OUT'),
    amount DECIMAL(10,2),
    mode ENUM('Cash', 'Online'),
    description VARCHAR(255),
    is_spending BOOLEAN,
    FOREIGN KEY (mobile) REFERENCES user_credentials(mobile) ON DELETE CASCADE,
    FOREIGN KEY (file_id) REFERENCES user_files(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Add Indexes for better performance
CREATE INDEX idx_file_id ON transaction_history(file_id);
CREATE INDEX idx_mobile ON user_files(mobile);