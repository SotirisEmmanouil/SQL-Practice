/* The tables needed for the queries and instructions */

CREATE TABLE school (
scID varchar (32),
name varchar (64) DEFAULT '',
city varchar (16) DEFAULT '',
PRIMARY KEY (scID));

CREATE TABLE wizard (
magID varchar (16),
wizName varchar (48) default '',
dateBorn date DEFAULT sysdate, 
PRIMARY KEY (magID));

CREATE TABLE attend (
who varchar (16),
what varchar (32) NOT NULL,
when char (4) NOT NULL,
PRIMARY KEY (who),
FOREIGN KEY (who) REFERENCES wizard,
FOREIGN KEY (what) REFERENCES school);

CREATE TABLE competition ( 
compID varchar (28),
year char (4) NOT NULL,
host varchar (32) NOT NULL, 
PRIMARY KEY (compID),
FOREIGN KEY (host) REFERENCES school);

CREATE TABLE permit (
eventID varchar (28), 
permID varchar (20),
player varchar (16) NOT NULL,
PRIMARY KEY (eventID, permID),
FOREIGN KEY (eventID) REFERENCES competition, 
FOREIGN KEY (player) REFERENCES wizard);

CREATE TABLE representation ( 
schoolID varchar (32),
gameID varchar (28), 
permitID varchar (20), 
PRIMARY KEY (schoolID, gameID),
FOREIGN KEY (schoolID) REFERENCES school,
FOREIGN KEY (gameID, permitID) REFERENCES permit);

CREATE TABLE standing (
gameID varchar (28),
permitID varchar (20),
position number (*,O) NOT NULL CHECK (position=> 1),
PRIMARY KEY (gameID, permitID),
FOREIGN KEY (gameID, permitID) REFERENCES permit);

CREATE TABLE problem (
pID varchar (32),
title varchar (96) NOT NULL,
text varchar (1860) NOT NULL,
author varchar (16) NOT NULL,
difficultyLevel number (*,0) CHECK (1 <= difficultyLevel AND difficultyLevel =< 100),
PRIMARY KEY (pID),
FOREIGN KEY (author) REFERENCES wizard);

CREATE TABLE selectedProblem (
problemID varchar (32), 
competitionID varchar (28) NOT NULL,
selector varchar (16) NOT NULL, 
testData varchar (2048) DEFAULT '',
gradingAdvice varchar (1972) DEFAULT '', 
PRIMARY KEY (problemID, competitionID),
FOREIGN KEY (problemID) REFERENCES problem,
FOREIGN KEY (competitionID) REFERENCES competition,
FOREIGN KEY (selector) REFERENCES wizard);

CREATE TABLE grader (
graderId varchar (16), 
firstRec varchar (16), 
secondRec varchar (16),
PRIMARY KEY (graderId),
FOREIGN KEY (graderID) REFERENCES wizard,
FOREIGN KEY (firstRec) REFERENCES wizard,
FOREIGN KEY (secondRec) REFERENCES wizard,
CONSTRAINT notSelf CHECK (graderID != firstRec AND graderID != secondRec), 
CONSTRAINT twoRecs CHECK (firstRec != secondRec));

CREATE TABLE approvedGrader (
grID varchar (16),
prID varchar (32),
cpID varchar (28), 
PRIMARY KEY (grID, prID, cpID), 
FOREIGN KEY (grID) REFERENCES grader, 
FOREIGN KEY (prID, cpID) REFERENCES selectedProblem);

CREATE TABLE gradedSolution (
eventID varchar (28),
permitID varchar (20),
problemID varchar (32),
graderID varchar (16),
grade number (*, 0) check (0 <= grade AND grade <= 100), 
PRIMARY KEY (eventID, permitID, problemID),
FOREIGN KEY (eventID, permitID) REFERENCES permit,
FOREIGN KEY (problemID, eventID) REFERENCES selectedProblem,
FOREIGN KEY (graderID, problemID, eventID) REFERENCES approvedGrader);

CREATE TABLE graderPay (
problemID varchar (32),
unitPay number (*,0) CHECK (unitPay => 0), 
PRIMARY KEY (problemID),
FOREIGN KEY (problemID) REFERENCES problem);

/* Find problem ID, title, and author's name of those problems that have never been selected for a competition */

SELECT p.pID, p.title, w.wizName
FROM problem p, wizard w
WHERE p.author = w.magID AND
p.pID NOT IN (SELECT problemID FROM selectedProblem);

/* How many competitions have there been? */
 
SELECT COUNT (*) FROM competition;
 
/* How many schools have been selected to host a competition? */

SELECT COUNT (DISTINCT host) FROM competition;

/* Set those competitions scheduled to happen in the year 2048 to be postponed for the year 2049 */

UPDATE competition 
SET year = '2049'
WHERE year = '2048';

/* Increase the difficulty level by 2 of those problems whose difficulty level is equal to 1 */

UPDATE problem 
SET difficultyLevel = difficultyLevel + 2 
WHERE difficultyLevel = 1;

/* Withdraw from selection all problems selected by wizard whose name is Antonin Dolohov */

DELETE * FROM selectedProblem 
WHERE selector IN (SELECT magID FROM wizard WHERE wizName = 'Antonin Dolohov';

/* Find identifiers and names of those wizards who have attended school, but have never received a permission to compete  */
 
 SELECT w.magID, w.wizName
 FROM wizard w, attend a
 WHERE w.magID = a.who AND 
 w.magID NOT IN (SELECT player FROM competition);

/* Find problem ID, title, and author name of those problems that have been selected for competition in (at least) two different years */
 
  SELECT p.pID, p.title, w.wizName
  FROM problem p, wizard w, selectedProblem s, competition c, competition c2, selectedProblem s2
  WHERE p.author = w.wizName AND
  p.pID = s.problemID AND
  s.competitionID = c.compID AND
  p.pID = s2.problemID AND
  s2.competitionID = c2.compID AND
  c.year != c2.year;               

 /* A new school has been created with school ID = 3498558 ,name = School1 , and located in city New York */
   
 INSERT INTO school (scID, name, city) VALUES 
 (3498558, School1, New York);             

 /* The administration requests that wizards also submit their social security numbers for identification purposes */
                   
 ALTER TABLE wizard 
 ADD (ssn varchar (9));                 
