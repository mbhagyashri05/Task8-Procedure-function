CREATE DATABASE PetSpa;
USE PetSpa;

CREATE TABLE Owner (
    owner_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20)
);
INSERT INTO Owner(owner_id, first_name,last_name, phone) 
Values(1,'Bob','Matthew',88),
(2,'Simmy','Samson',4865),
(3,'Emma','Strt',9999);
ALTER TABLE Owner MODIFY phone VARCHAR(20) DEFAULT NULL;
INSERT INTO Owner (owner_id, first_name, last_name)
VALUES (4, 'John', 'Doe');
INSERT INTO Owner(owner_id, first_name,last_name, phone) 
Values(5,'Tom','Maww',913456),(6,'Alex','Bud',9122224);

UPDATE Owner SET phone = '1234567890' WHERE owner_id = '1';
SELECT * FROM Owner WHERE first_name = 'Emma';

DELETE FROM Owner
WHERE owner_id = 4;
SELECT * FROM Owner;
SELECT first_name, phone FROM Owner;
SELECT * FROM Owner
WHERE last_name = 'Strt';
SELECT * FROM Owner WHERE first_name LIKE 'S%';
SELECT owner_id, COUNT(*) AS number_of_pets FROM Pet GROUP BY owner_id;
SELECT Owner.owner_id,Owner.first_name,Owner.last_name,Pet.name AS pet_name, Pet.species AS pet_species 
FROM Owner LEFT JOIN Pet ON Owner.owner_id = Pet.owner_id;
SELECT Pet.pet_id,Pet.name AS pet_name,Owner.first_name AS owner_first_name
FROM Owner RIGHT JOIN Pet ON Pet.owner_id = Owner.owner_id;

SELECT Owner.owner_id,Owner.first_name,Owner.last_name,Pet.name AS pet_name, Pet.species AS pet_species
FROM Owner LEFT JOIN Pet ON Owner.owner_id = Pet.owner_id
UNION
SELECT Owner.owner_id,Owner.first_name,Owner.last_name,Pet.name AS pet_name, Pet.species AS pet_species
FROM Pet
LEFT JOIN Owner ON Pet.owner_id = Owner.owner_id;
SELECT first_name, last_name
FROM Owner WHERE owner_id IN (SELECT DISTINCT pet.owner_id
    FROM Appointment INNER JOIN Pet ON Appointment.pet_id = Pet.pet_id);
    
SELECT o.first_name, o.last_name FROM Owner o
WHERE o.owner_id IN (
    SELECT p.owner_id
    FROM Pet p
    JOIN Appointment a ON p.pet_id = a.pet_id
    JOIN Payment pay ON pay.appointment_id = a.appointment_id
    GROUP BY p.owner_id
    HAVING SUM(pay.amount) > 40);
CREATE VIEW view_owner_pet_details AS
SELECT 
    o.owner_id,
    o.first_name AS owner_first_name,
    o.last_name AS owner_last_name,
    p.name AS pet_name,
    p.species,
    p.breed
FROM Owner o JOIN Pet p ON o.owner_id = p.owner_id;
SELECT * FROM view_owner_pet_details WHERE species = 'Dog';
CREATE VIEW view_active_owners AS SELECT DISTINCT o.owner_id, o.first_name, o.last_name
FROM Owner o JOIN Pet p ON o.owner_id = p.owner_id JOIN Appointment a ON p.pet_id = a.pet_id;
SELECT * FROM view_active_owners WHERE last_name LIKE 'S%';

DELIMITER $$

CREATE PROCEDURE GetOwnerPetInfo(IN owner_fname VARCHAR(50))
BEGIN

    SELECT 
        o.owner_id,
        o.first_name AS owner_first_name,
        o.last_name AS owner_last_name,
        p.name AS pet_name,
        p.species,
        p.breed
    FROM Owner o
    JOIN Pet p ON o.owner_id = p.owner_id
    WHERE o.first_name = owner_fname;

END$$

DELIMITER ;
CALL GetOwnerPetInfo('Emma');
CALL GetOwnerPetInfo('Tom');
DELIMITER $$

CREATE PROCEDURE GetOwnerPetInfoAdvanced(IN owner_fname VARCHAR(50))
BEGIN
    DECLARE pet_count INT;

    SELECT COUNT(*) INTO pet_count
    FROM Owner o
    JOIN Pet p ON o.owner_id = p.owner_id
    WHERE o.first_name = owner_fname;

    IF pet_count > 0 THEN
        SELECT 
            o.owner_id,
            o.first_name,
            o.last_name,
            p.name AS pet_name,
            p.species,
            p.breed
        FROM Owner o
        JOIN Pet p ON o.owner_id = p.owner_id
        WHERE o.first_name = owner_fname;
    ELSE
        SELECT CONCAT('No pets found for owner: ', owner_fname) AS message;
    END IF;
END$$

DELIMITER ;

CREATE TABLE Pet (
    pet_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    species VARCHAR(30),
    breed VARCHAR(50),
    owner_id INT,
    FOREIGN KEY (owner_id) REFERENCES Owner(owner_id)
);
INSERT INTO Pet(pet_id,name,species, breed,owner_id) 
Values(23,'Tuffy','Dog','Labrador',2),
	  (12,'Almond','Dog','Labrador',3),
	  (11,'Maxy','Cat','Persian',1);
INSERT INTO Pet(pet_id,name,species, breed,owner_id) 
Values(1,'Tom','Dog','German Shephard',5),
	  (2,'Ally','Dog','Poodle',6);
INSERT INTO Pet(pet_id,name,species, breed,owner_id) 
Values(3,'Ted','Dog','German Shephard',5),
	  (4,'Olle','Cat','Persian',6);
SELECT * FROM Pet WHERE species = 'Dog';
SELECT * FROM Pet ORDER BY name ASC;
SELECT owner_id, COUNT(*) AS per_count FROM Pet GROUP BY owner_id HAVING COUNT(*) > 1;
SELECT Pet.name AS pet_name, Pet.species,Owner.first_name AS owner_first_name,Owner.last_name AS owner_last_name 
FROM Pet 
INNER JOIN Owner ON Pet.owner_id = Owner.owner_id;  
SELECT name, species FROM Pet WHERE (
    SELECT COUNT(*) FROM Appointment WHERE Appointment.pet_id = Pet.pet_id) > 1;
SELECT name, species FROM Pet p
WHERE NOT EXISTS ( SELECT 1 FROM Appointment a WHERE a.pet_id = p.pet_id);

CREATE TABLE Employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    role VARCHAR(50)
);
INSERT INTO Employee(employee_id,first_name,role) 
Values (1,'Jack','Stylist'),
(2,'Sam','Grommer');
INSERT INTO Employee(employee_id,first_name,role) VALUES(3,'JIM','TRAINER'),(4,'ROCKY','PLAYER');
INSERT INTO Employee(employee_id,first_name,role) VALUES(5,'WOX','CLEANER');

UPDATE Employee SET role = 'Cashier' WHERE employee_id = 5;
SELECT * FROM Employee WHERE role = 'Stylist' OR role = 'TRAINER';
SELECT * FROM Employee ORDER BY role DESC;
SELECT first_name, role
FROM Employee e WHERE EXISTS (
    SELECT 1 FROM Appointment a
    WHERE a.employee_id = e.employee_id);
    
SELECT e.first_name, e.role
FROM Employee e WHERE e.employee_id = (
    SELECT a.employee_id
    FROM Appointment a
    WHERE a.appointment_id = (
        SELECT appointment_id
        FROM Payment
        GROUP BY appointment_id
        ORDER BY SUM(amount) DESC
        LIMIT 1
    )
);
CREATE VIEW view_top_earning_employee AS
SELECT 
    e.first_name AS employee_name,
    e.role,
    pay_total.total_paid
FROM Employee e
JOIN (
    SELECT a.employee_id, SUM(p.amount) AS total_paid
    FROM Appointment a
    JOIN Payment p ON a.appointment_id = p.appointment_id
    GROUP BY a.employee_id
    ORDER BY total_paid DESC
    LIMIT 1
) AS pay_total ON e.employee_id = pay_total.employee_id;
SELECT * FROM view_top_earning_employee;

CREATE TABLE Service (
    service_id INT PRIMARY KEY AUTO_INCREMENT,
    service_name VARCHAR(100),
    price DECIMAL(8,2)
);
INSERT INTO Service(service_id,service_name,price) 
Values (1,'Bath',20),(2,'Hair Cut',10),(3,'Day Boarding',50),(4,'Styling',30);
UPDATE Service SET price = price + 5 where service_id = '1'; 
SELECT * FROM Service WHERE price BETWEEN 15 AND 40;
SELECT * FROM Service WHERE service_name LIKE '%Cut%';
SELECT service_name, AVG(price) AS average_price FROM Service GROUP BY service_name;
SELECT service_name FROM Service
WHERE price = ( SELECT MAX(price) FROM Service);

CREATE TABLE Appointment (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    pet_id INT,
    employee_id INT,
    appointment_date DATETIME,
    FOREIGN KEY (pet_id) REFERENCES Pet(pet_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
);
INSERT INTO Appointment (appointment_id, pet_id, employee_id, appointment_date) VALUES
(1, 11, 1, '2025-09-20 10:00:00'),
(2, 12, 2, '2025-09-21 14:30:00'),
(3, 23, 2, '2025-09-22 09:00:00');
ALTER TABLE Appointment MODIFY employee_id INT DEFAULT NULL;
INSERT INTO Appointment (appointment_id, pet_id, appointment_date) VALUES
(4, 11,'2025-09-20 10:00:00');
SELECT * FROM Appointment WHERE appointment_date > '2025-09-20';
SELECT * FROM Appointment WHERE pet_id = 11 AND employee_id IS NOT NULL;
SELECT employee_id, COUNT(*) AS total_appointments FROM Appointment WHERE employee_id IS NOT NULL GROUP BY employee_id;
SELECT COUNT(*) AS total_appointments FROM Appointment;
SELECT Appointment.appointment_id,Pet.name AS pet_name,Employee.first_name AS employee_name,Appointment.appointment_date
FROM Appointment
LEFT JOIN Pet ON Appointment.pet_id = Pet.pet_id
LEFT JOIN Employee ON Appointment.employee_id = Employee.employee_id;
SELECT Pet.name AS pet_name,
    (SELECT COUNT(*) FROM Appointment 
     WHERE Appointment.pet_id = Pet.pet_id) AS appointment_count FROM Pet;
     
SELECT * FROM view_appointment_summary WHERE appointment_date > '2025-09-21';



CREATE TABLE Appointment_Service (
    appointment_id INT,
    service_id INT,
    PRIMARY KEY (appointment_id, service_id),
    FOREIGN KEY (appointment_id) REFERENCES Appointment(appointment_id),
    FOREIGN KEY (service_id) REFERENCES Service(service_id)
);
INSERT INTO Appointment_Service(appointment_id,service_id) VALUES(1,2),(2,1),(3,4);
SELECT appointment_id, SUM(amount) AS total_amount_paid FROM Payment GROUP BY appointment_id;
SELECT appointment_id, COUNT(service_id) AS service_count FROM Appointment_Service GROUP BY appointment_id;
SELECT AVG(service_count) AS avg_services_per_appointment FROM (SELECT appointment_id, COUNT(service_id) AS service_count FROM Appointment_Service GROUP BY appointment_id
) AS service_summary;
SELECT Appointment_Service.appointment_id,Service.service_name,Service.price
FROM Appointment_Service
INNER JOIN Service ON Appointment_Service.service_id = Service.service_id;
SELECT AVG(service_count) AS avg_services
FROM (SELECT appointment_id, COUNT(service_id) AS service_count
    FROM Appointment_Service
    GROUP BY appointment_id
    HAVING COUNT(service_id) >= 2
) AS svc_summary;
SELECT Pet.name FROM Appointment_Service JOIN Appointment ON Appointment_Service.appointment_id = Appointment.appointment_id
JOIN Pet ON Appointment.pet_id = Pet.pet_id
WHERE service_id = ( SELECT service_id FROM Service WHERE price = ( SELECT MAX(price) FROM Service));
CREATE VIEW view_appointment_services AS
SELECT 
    aps.appointment_id,
    s.service_name,
    s.price
FROM Appointment_Service aps
JOIN Service s ON aps.service_id = s.service_id;
SELECT * FROM view_appointment_services WHERE price > 25;

CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT,
    amount DECIMAL(8,2),
    payment_date DATETIME,
    FOREIGN KEY (appointment_id) REFERENCES Appointment(appointment_id)
);
INSERT INTO Payment(payment_id,appointment_id,amount,payment_date)VALUES(1,1,10,'2025-09-20 10:00:00'),(2,1,20,'2025-09-21 14:00:00'),(3,3,50,'2025-09-22 09:00:00');
DELETE FROM Payment WHERE payment_id = 2;
SELECT * FROM Payment ORDER BY payment_date DESC LIMIT 2;
SELECT SUM(amount) AS total_revenue FROM Payment;
SELECT DATE(payment_date) AS payment_day, SUM(amount) AS daily_revenue FROM Payment GROUP BY DATE(payment_date) ORDER BY payment_day;
CREATE VIEW view_total_payments AS
SELECT 
    appointment_id,
    SUM(amount) AS total_paid
FROM Payment GROUP BY appointment_id;
SELECT * FROM view_total_payments WHERE total_paid > 30;
DELIMITER $$

CREATE FUNCTION GetAppointmentTotal(appId INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_amt DECIMAL(10,2);

    SELECT IFNULL(SUM(amount), 0) INTO total_amt
    FROM Payment
    WHERE appointment_id = appId;

    RETURN total_amt;
END$$

DELIMITER ;
SELECT GetAppointmentTotal(1) AS total_payment;





