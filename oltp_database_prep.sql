
CREATE TABLE department (
    department_id    SERIAL PRIMARY KEY  ,
    department_name   VARCHAR(50) NOT NULL,
    department_code  VARCHAR(50) NOT NULL,
    department_code_desc VARCHAR(255) ,
    create_dtm  TIMESTAMP NOT NULL DEFAULT current_timestamp,
    updated_dtm    TIMESTAMP 
);

CREATE TABLE course (
    course_id  SERIAL PRIMARY KEY,
    course_name  VARCHAR(50) NOT NULL,
    course_code  VARCHAR(50) NOT NULL,
    course_code_desc VARCHAR(255) ,
    course_period INTEGER NOT NULL,
    department_id INTEGER REFERENCES department (department_id ),
    create_dtm  TIMESTAMP NOT NULL  DEFAULT current_timestamp,
    updated_dtm    TIMESTAMP
);

CREATE TABLE unit (
    unit_id  SERIAL PRIMARY KEY  ,
    unit_name    VARCHAR(50) NOT NULL,
    unit_code  VARCHAR(50) NOT NULL,
    unit_code_desc VARCHAR(255) NOT NULL,
    create_dtm  TIMESTAMP NOT NULL,
    updated_dtm    TIMESTAMP DEFAULT current_timestamp
);

CREATE TABLE ethinicity (
    ethinicity_id  SERIAL PRIMARY KEY  ,
    ethinicity_name      INTEGER NOT NULL,
    ethinicity_code  VARCHAR(50) NOT NULL,
    ethinicity_code_desc VARCHAR(255) NOT NULL,
    create_dtm  TIMESTAMP NOT NULL,
    updated_dtm    TIMESTAMP DEFAULT current_timestamp
);

CREATE TABLE country (
    country_id  SERIAL PRIMARY KEY  ,
    country_name      INTEGER NOT NULL,
    country_code  VARCHAR(50) NOT NULL,
    country_code_desc VARCHAR(255) NOT NULL,
    create_dtm  TIMESTAMP NOT NULL,
    updated_dtm    TIMESTAMP DEFAULT current_timestamp
);

CREATE TABLE person (
    person_id SERIAL PRIMARY KEY ,
    first_name      VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    email  VARCHAR(50) NOT NULL,
    phone_number  VARCHAR(50) NOT NULL,
    country_id  INTEGER NOT NULL REFERENCES country (country_id),
    create_dtm  TIMESTAMP NOT NULL,
    updated_dtm    TIMESTAMP DEFAULT current_timestamp
);

CREATE TABLE lecturer (
    lecturer_id    SERIAL PRIMARY KEY ,
    lecturer_name VARCHAR(100) NOT NULL,
    hire_date   TIMESTAMP NOT NULL,
    termination_date TIMESTAMP NOT NULL,
    person_id INTEGER NOT NULL REFERENCES person(person_id),
    create_dtm  TIMESTAMP NOT NULL,
    updated_dtm    TIMESTAMP DEFAULT current_timestamp
);  

CREATE TABLE student (
    student_id   SERIAL PRIMARY KEY,
    student_registration_number  VARCHAR(20) NOT NULL UNIQUE,
    person_id INTEGER NOT NULL REFERENCES person(person_id),
    country_id   INTEGER NOT NULL REFERENCES country(country_id),
    create_dtm  TIMESTAMP NOT NULL,
    updated_dtm    TIMESTAMP DEFAULT current_timestamp 
    
);

CREATE TABLE student_course_enrollment (
    course_enrollment_id  SERIAL PRIMARY KEY ,
    course_id   INTEGER NOT NULL REFERENCES course(course_id),
    student_id  INTEGER NOT NULL REFERENCES student(student_id),
    start_date  date not null, 
    completion_date  date not null, 
    actual_completion_date  date , 
    create_dtm  TIMESTAMP NOT NULL,
    updated_dtm    TIMESTAMP DEFAULT current_timestamp 
) ;


{# insert statements #}

INSERT INTO department (department_name, department_code, department_code_desc, create_dtm, updated_dtm)
VALUES
    ('Mathematics', 'MATH101', 'Mathematics Department', NOW() - INTERVAL '7 days', NULL),
    ('History', 'HIST102', 'History Department', NOW() - INTERVAL '6 days', NULL),
    ('Science', 'SCI103', 'Science Department', NOW() - INTERVAL '5 days', NULL),
    ('English', 'ENG104', 'English Department', NOW() - INTERVAL '4 days', NULL),
    ('Art', 'ART105', 'Art Department', NOW() - INTERVAL '3 days', NULL),
    ('Music', 'MUS106', 'Music Department', NOW() - INTERVAL '2 days', NULL),
    ('Physical Education', 'PE107', 'Physical Education Department', NOW() - INTERVAL '1 day', NULL),
    ('Computer Science', 'CS108', 'Computer Science Department', NOW() - INTERVAL '1 day', NULL),
    ('Foreign Languages', 'FL109', 'Foreign Languages Department', NOW() - INTERVAL '1 day', NULL),
    ('Social Sciences', 'SS110', 'Social Sciences Department', NOW(), NULL);
	
	
INSERT INTO course (course_name, course_code, course_code_desc, course_period, department_id, create_dtm)
VALUES
    ('Calculus I', 'CALC101', 'Introduction to Calculus', 3, 1, NOW() - INTERVAL '5 days'),
    ('World History', 'HIST201', 'Global History Overview', 4, 2, NOW() - INTERVAL '10 days'),
    ('Biology 101', 'BIO101', 'Fundamentals of Biology', 4, 3, NOW() - INTERVAL '7 days'),
    ('English Composition', 'ENG102', 'Writing and Composition', 3, 4, NOW() - INTERVAL '8 days'),
    ('Art Appreciation', 'ART105', 'Exploring Art Styles', 2, 5, NOW() - INTERVAL '6 days');
	



INSERT INTO unit (unit_name, unit_code, unit_code_desc, create_dtm)
VALUES
    ('Unit 1', 'UNIT101', 'Introduction to Course Material', NOW() - INTERVAL '3 days'),
    ('Unit 2', 'UNIT102', 'Key Concepts and Principles', NOW() - INTERVAL '5 days'),
    ('Unit 3', 'UNIT103', 'Practical Applications', NOW() - INTERVAL '2 days'),
    ('Unit 4', 'UNIT104', 'Advanced Topics', NOW() - INTERVAL '4 days'),
    ('Unit 1', 'UNIT105', 'Foundations of the Subject', NOW() - INTERVAL '1 day'),
    ('Unit 2', 'UNIT106', 'Historical Perspectives', NOW() - INTERVAL '6 days'),
    ('Unit 3', 'UNIT107', 'Exploratory Studies', NOW() - INTERVAL '7 days'),
    ('Unit 4', 'UNIT108', 'Research and Analysis', NOW() - INTERVAL '8 days'),
    ('Unit 1', 'UNIT109', 'Critical Thinking', NOW() - INTERVAL '9 days'),
    ('Unit 2', 'UNIT110', 'Practical Exercises', NOW() - INTERVAL '10 days');	

drop table course cascade

INSERT INTO course (course_name, course_code, course_code_desc, course_period, department_id, create_dtm)
VALUES
    ('Electrical Engineering', 'EE101', 'Introduction to Electrical Engineering', 4, 1, NOW() - INTERVAL '10 days'),
    ('Computer Science', 'CS102', 'Computer Science Fundamentals', 4, 2, NOW() - INTERVAL '5 days'),
    ('Mechanical Engineering', 'ME103', 'Introduction to Mechanical Engineering', 4, 3, NOW() - INTERVAL '8 days'),
    ('Civil Engineering', 'CE104', 'Civil Engineering Principles', 4, 4, NOW() - INTERVAL '7 days');


INSERT INTO country (country_name, country_code, country_code_desc, create_dtm)
VALUES
    ('Kenya', 'KEN', 'Republic of Kenya', NOW() - INTERVAL '3 days'),
    ('Nigeria', 'NGA', 'Federal Republic of Nigeria', NOW() - INTERVAL '5 days'),
    ('South Africa', 'ZAF', 'Republic of South Africa', NOW() - INTERVAL '2 days'),
    ('Ghana', 'GHA', 'Republic of Ghana', NOW() - INTERVAL '4 days');


INSERT INTO person (first_name, last_name, email, phone_number, country_id, create_dtm)
VALUES
    ('John', 'Doe', 'johndoe@email.com', '+1234567890', 1, NOW() - INTERVAL '10 days'),
    ('Jane', 'Smith', 'janesmith@email.com', '+9876543210', 2, NOW() - INTERVAL '5 days'),
    ('Michael', 'Johnson', 'michaeljohnson@email.com', '+1122334455', 3, NOW() - INTERVAL '8 days'),
    ('Emily', 'Wilson', 'emilywilson@email.com', '+8877665544', 4, NOW() - INTERVAL '7 days'),
    ('David', 'Brown', 'davidbrown@email.com', '+9988776655', 1, NOW() - INTERVAL '6 days'),
    ('Sophia', 'Lee', 'sophialee@email.com', '+1122334455', 2, NOW() - INTERVAL '5 days'),
    ('Matthew', 'Garcia', 'matthewgarcia@email.com', '+4455667788', 3, NOW() - INTERVAL '9 days'),
    ('Olivia', 'Martinez', 'oliviamartinez@email.com', '+7788990011', 4, NOW() - INTERVAL '4 days'),
    ('William', 'Rodriguez', 'williamrodriguez@email.com', '+9988776655', 1, NOW() - INTERVAL '3 days'),
    ('Ava', 'Lopez', 'avalopez@email.com', '+1122334455', 2, NOW() - INTERVAL '5 days'),
    ('Joseph', 'Harris', 'josephharris@email.com', '+5566778899', 3, NOW() - INTERVAL '8 days'),
    ('Mia', 'Allen', 'miaallen@email.com', '+9988776655', 4, NOW() - INTERVAL '2 days'),
    ('James', 'Hall', 'jameshall@email.com', '+1234567890', 1, NOW() - INTERVAL '6 days'),
    ('Sofia', 'Davis', 'sofiadavis@email.com', '+1122334455', 2, NOW() - INTERVAL '7 days'),
    ('Benjamin', 'Smith', 'benjaminsmith@email.com', '+9988776655', 3, NOW() - INTERVAL '4 days'),
    ('Charlotte', 'Lee', 'charlottee@email.com', '+4455667788', 4, NOW() - INTERVAL '5 days'),
    ('Daniel', 'Gonzalez', 'danielgonzalez@email.com', '+1122334455', 1, NOW() - INTERVAL '3 days'),
    ('Oliver', 'Clark', 'oliverclark@email.com', '+9988776655', 2, NOW() - INTERVAL '8 days'),
    ('Elizabeth', 'Turner', 'elizabethturner@email.com', '+7788990011', 3, NOW() - INTERVAL '6 days'),
    ('Alexander', 'Brown', 'alexanderbrown@email.com', '+9988776655', 4, NOW() - INTERVAL '5 days'),
    ('Isabella', 'Davis', 'isabelladavis@email.com', '+5566778899', 1, NOW() - INTERVAL '7 days'),
    ('Elijah', 'Martinez', 'elijahmartinez@email.com', '+9988776655', 2, NOW() - INTERVAL '4 days'),
    ('Emma', 'Garcia', 'emmagarcia@email.com', '+4455667788', 3, NOW() - INTERVAL '6 days'),
    ('William', 'Hernandez', 'williamhernandez@email.com', '+9988776655', 4, NOW() - INTERVAL '3 days');
	
	
INSERT INTO lecturer (lecturer_name, hire_date, termination_date, person_id, create_dtm)
VALUES
    ('Dr. Smith', NOW() - INTERVAL '5 years', NOW() + INTERVAL '1 year', 1, NOW() - INTERVAL '10 days'),
    ('Prof. Johnson', NOW() - INTERVAL '4 years', NOW() + INTERVAL '1 year', 2, NOW() - INTERVAL '8 days'),
    ('Dr. Williams', NOW() - INTERVAL '3 years', NOW() + INTERVAL '1 year', 3, NOW() - INTERVAL '7 days'),
    ('Prof. Davis', NOW() - INTERVAL '2 years', NOW() + INTERVAL '1 year', 4, NOW() - INTERVAL '6 days'),
    ('Dr. Wilson', NOW() - INTERVAL '1 year', NOW() + INTERVAL '1 year', 5, NOW() - INTERVAL '5 days');

INSERT INTO student (student_registration_number, person_id, country_id, create_dtm)
VALUES
    ('STUD006', 6, 1, NOW() - INTERVAL '10 days'),
    ('STUD007', 7, 2, NOW() - INTERVAL '8 days'),
    ('STUD008', 8, 3, NOW() - INTERVAL '7 days'),
    ('STUD009', 9, 4, NOW() - INTERVAL '6 days'),
    ('STUD010', 10, 1, NOW() - INTERVAL '5 days'),
    ('STUD011', 11, 2, NOW() - INTERVAL '10 days'),
    ('STUD012', 12, 3, NOW() - INTERVAL '8 days'),
    ('STUD013', 13, 4, NOW() - INTERVAL '7 days'),
    ('STUD014', 14, 1, NOW() - INTERVAL '6 days'),
    ('STUD015', 15, 2, NOW() - INTERVAL '5 days'),
    ('STUD016', 16, 3, NOW() - INTERVAL '10 days'),
    ('STUD017', 17, 4, NOW() - INTERVAL '8 days'),
    ('STUD018', 18, 1, NOW() - INTERVAL '7 days'),
    ('STUD019', 19, 2, NOW() - INTERVAL '6 days'),
    ('STUD020', 20, 3, NOW() - INTERVAL '5 days'),
    ('STUD021', 21, 4, NOW() - INTERVAL '10 days'),
    ('STUD022', 22, 1, NOW() - INTERVAL '8 days'),
    ('STUD023', 23, 2, NOW() - INTERVAL '7 days'),
    ('STUD024', 24, 3, NOW() - INTERVAL '6 days');

INSERT INTO student_course_enrollment (course_id, student_id, start_date, completion_date, actual_completion_date, create_dtm)
VALUES
    (1, 6, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '10 days'),
    (2, 7, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '8 days'),
    (3, 8, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '7 days'),
    (4, 9, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '6 days'),
    (1, 10, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '5 days'),
    (2, 11, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '10 days'),
    (3, 12, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '8 days'),
    (4, 13, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '7 days'),
    (1, 14, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '6 days'),
    (2, 15, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '5 days'),
    (3, 16, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '10 days'),
    (4, 17, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '8 days'),
    (1, 18, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '7 days'),
    (2, 19, '2022-09-01', '2022-12-15', '2022-12-15', NOW() - INTERVAL '6 days');
    

