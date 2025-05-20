-- University Student MIS Database Schema (DDL)

CREATE DATABASE university_mis;
 
USE university_mis;

CREATE TABLE classroom (
    building VARCHAR(15),
    room_number VARCHAR(7),
    capacity INT,
    PRIMARY KEY (building, room_number)
);

CREATE TABLE department (
    dept_name VARCHAR(20),
    building VARCHAR(15),
    budget DECIMAL(12,2) CHECK (budget > 0),
    PRIMARY KEY (dept_name)
);

CREATE TABLE course (
    course_id VARCHAR(10),
    title VARCHAR(100),
    dept_name VARCHAR(20),
    credits INT,
    PRIMARY KEY (course_id),
    FOREIGN KEY (dept_name) REFERENCES department(dept_name)
);

CREATE TABLE instructor (
    ID INT AUTO_INCREMENT,
    name VARCHAR(50),
    dept_name VARCHAR(20),
    salary DECIMAL(8,2),
    PRIMARY KEY (ID),
    FOREIGN KEY (dept_name) REFERENCES department(dept_name)
);

CREATE TABLE section (
    course_id VARCHAR(10),
    sec_id VARCHAR(10),
    semester VARCHAR(6),
    year INT,
    building VARCHAR(15),
    room_number VARCHAR(7),
    time_slot_id VARCHAR(10),
    PRIMARY KEY (course_id, sec_id, semester, year),
    FOREIGN KEY (course_id) REFERENCES course(course_id),
    FOREIGN KEY (building, room_number) REFERENCES classroom(building, room_number)
);

CREATE TABLE teaches (
    ID INT,
    course_id VARCHAR(10),
    sec_id VARCHAR(10),
    semester VARCHAR(6),
    year INT,
    PRIMARY KEY (ID, course_id, sec_id, semester, year),
    FOREIGN KEY (ID) REFERENCES instructor(ID),
    FOREIGN KEY (course_id, sec_id, semester, year) REFERENCES section(course_id, sec_id, semester, year)
);

CREATE TABLE student (
    ID INT AUTO_INCREMENT,
    name VARCHAR(50),
    dept_name VARCHAR(20),
    tot_cred INT,
    PRIMARY KEY (ID),
    FOREIGN KEY (dept_name) REFERENCES department(dept_name)
);

CREATE TABLE takes (
    ID INT,
    course_id VARCHAR(10),
    sec_id VARCHAR(10),
    semester VARCHAR(6),
    year INT,
    grade CHAR(2),
    PRIMARY KEY (ID, course_id, sec_id, semester, year),
    FOREIGN KEY (ID) REFERENCES student(ID),
    FOREIGN KEY (course_id, sec_id, semester, year) REFERENCES section(course_id, sec_id, semester, year)
);

CREATE TABLE advisor (
    s_ID INT,
    i_ID INT,
    PRIMARY KEY (s_ID),
    FOREIGN KEY (s_ID) REFERENCES student(ID),
    FOREIGN KEY (i_ID) REFERENCES instructor(ID)
);

CREATE TABLE time_slot (
    time_slot_id VARCHAR(10),
    day VARCHAR(10),
    start_time TIME,
    end_time TIME,
    PRIMARY KEY (time_slot_id, day, start_time)
);

CREATE TABLE prereq (
    course_id VARCHAR(10),
    prereq_id VARCHAR(10),
    PRIMARY KEY (course_id, prereq_id),
    FOREIGN KEY (course_id) REFERENCES course(course_id),
    FOREIGN KEY (prereq_id) REFERENCES course(course_id)
);

-- Sample CRUD Queries

-- Insert Data into Student Table
INSERT INTO student (name, dept_name, tot_cred) VALUES ('Alice Johnson', 'Computer Science', 30);

-- Retrieve all Students
SELECT * FROM student;

-- Update Student's Total Credits
UPDATE student SET tot_cred = 40 WHERE ID = 1;

-- Delete a Student
DELETE FROM student WHERE ID = 1;


CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

ALTER TABLE users ADD COLUMN role VARCHAR(50) NOT NULL DEFAULT 'user';

DESC users;

SELECT * FROM users;




USE university_mis;
SELECT * FROM users;

