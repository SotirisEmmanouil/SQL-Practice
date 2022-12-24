CREATE TABLE school (
scID varchar(32),
name varchar(64) default '',
city varchar (16) default '',
primary key (scID));

CREATE TABLE wizard (
magID varchar (16),
wizName varchar (48) default '',
dateBorn date default sysdate, 
primary key (magID));

CREATE TABLE attend (
who varchar (16),
what varchar (32) not null,
when char (4) not null,
primary key (who),
foreign key (who) references wizard,
foreign key (what) references school);

CREATE TABLE competition ( 
compID varchar (28),
year char (4) not null,
host varchar (32) not null, 
primary key (compID),
foreign key (host) references school);

CREATE TABLE permit (
eventID varchar (28), 
permID varchar (20),
player varchar (16) not null,
primary key (eventID, permID),
foreign key (eventID) references competition, 
foreign key (player) references wizard);

CREATE TABLE representation ( 
schoolID varchar (32),
gameID varchar (28), 
permitID varchar (20), primary key (schoolID, gameID),
foreign key (schoolID) references school,
foreign key (gameID, permitID) references permit);

CREATE TABLE standing (
gameID varchar (28),
permitID varchar (20),
position number (*,O) not null check (position=> 1),
primary key (gameID, permitID),
foreign key (gameID, permitID) references permit);

CREATE TABLE problem (
pID varchar (32),
title varchar (96) not null,
text varchar (1860) not null,
author varchar (16) not null,
difficultyLevel number (*,0) check (1 <= difficultyLevel and difficultyLevel =< 100),
primary key (pID),
foreign key (author) references wizard);

CREATE TABLE selectedProblem (
problemID varchar (32), 
competitionID varchar (28) not null,
selector varchar (16) not null, 
testData varchar (2048) default '',
gradingAdvice varchar (1972) default '', 
primary key (problemID, competitionID),
foreign key (problemID) references problem,
foreign key (competitionID) references competition,
foreign key (selector) references wizard);

CREATE TABLE grader (
graderId varchar(16), 
firstRec varchar (16), 
secondRec varchar (16),
primary key (graderId),
foreign key (graderID) references wizard,
foreign key (firstRec) references wizard,
foreign key (secondRec) references wizard,
constraint notSelf check (graderID != firstRec and graderID != secondRec), 
constraint twoRecs check (firstRec != secondRec));

CREATE TABLE approvedGrader (
grID varchar (16),
prID varchar (32),
cpID varchar (28), 
primary key (grID, prID, cpID), 
foreign key (grID) references grader, 
foreign key (prID, cpID) references selectedProblem);

CREATE TABLE gradedSolution (
eventID varchar (28),
permitID varchar (20),
problemID varchar (32),
graderID varchar (16),
grade number (*, 0) check (0 <= grade and grade <= 100), 
PRIMARY KEY (eventID, permitID, problemID),
FOREIGN KEY (eventID, permitID) references permit,
FOREIGN KEY (problemID, eventID) references selectedProblem,
FOREIGN KEY (graderID, problemID, eventID) references approvedGrader);

CREATE TABLE graderPay (
problemID varchar (32),
unitPay number (*,0) check (unitPay => 0), primary key (problemID),
foreign key (problemID) references problem);

/* Find problem ID, title, and author's name of those problems that have never been selected for a competition */

SELECT p.pID, p.title, w.WizName
FROM problem p, wizard w
WHERE p.author = w.magID AND
p.pID NOT IN (SELECT problemID FROM selectedProblem);

/* How many competitions have there been? */
 
SELECT COUNT (*) FROM competition;
 
/* How many schools have been selected to host a competition? */

SELECT COUNT (DISTINCT host) FROM competition;

/* Those competitions scheduled to happen in the year 2048 are postponed for year 2049. */

UPDATE competition 
SET year = '2049'
WHERE year = '2048';

