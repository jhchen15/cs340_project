/*
Schema DDL by Humza Hussain and James Chen
Group 59 - Valleyview Athletics Management System
Project Step 2 Draft
*/

SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;

-- Schools Table
DROP TABLE IF EXISTS Schools;

CREATE TABLE Schools (
	schoolID INT(11) AUTO_INCREMENT NOT NULL,
	name VARCHAR(120) NOT NULL,
	address VARCHAR(120),
	phone VARCHAR(20),
	PRIMARY KEY (schoolID),
	CONSTRAINT distinct_name UNIQUE (name)
);

-- Teams Table
DROP TABLE IF EXISTS Teams;

CREATE TABLE Teams (
	teamID INT(11) AUTO_INCREMENT NOT NULL,
	schoolID INT(11) NOT NULL,
	teamName VARCHAR(120) NOT NULL,
	sportType ENUM('football', 'volleyball', 'basketball', 'soccer', 'baseball', 'tennis') NOT NULL,
	varsityJv ENUM('varsity', 'jv') NOT NULL,
	seasonName ENUM('fall', 'winter', 'spring') NOT NULL,
	academicYear YEAR,
	PRIMARY KEY (teamID),
	FOREIGN KEY (schoolID) REFERENCES Schools(schoolID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT valid_season_sports CHECK (
        (seasonName = 'fall' AND sportType IN ('football', 'volleyball')) OR
        (seasonName = 'winter' AND sportType IN ('basketball', 'soccer')) OR
        (seasonName = 'spring' AND sportType IN ('baseball', 'tennis'))
    ),
    CONSTRAINT unique_teams UNIQUE (schoolID, teamName, sportType, varsityJv, seasonName, academicYear)
);

-- Facilities Table
DROP TABLE IF EXISTS Facilities;

CREATE TABLE Facilities (
	facilityID INT(11) AUTO_INCREMENT NOT NULL,
	schoolID INT(11) NOT NULL,
	facilityName VARCHAR(120),
	capacity INT,
	PRIMARY KEY (facilityID),
	FOREIGN KEY (schoolID) REFERENCES Schools(schoolID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Athletes Table
DROP TABLE IF EXISTS Athletes;

CREATE TABLE Athletes (
	athleteID INT(11) AUTO_INCREMENT NOT NULL,
	schoolID INT(11) NOT NULL,
	firstName VARCHAR(120) NOT NULL,
	lastName VARCHAR(120) NOT NULL,
    gradeLevel INT(11) NOT NULL,
    isEligible BOOLEAN DEFAULT 1,
    isActive BOOLEAN DEFAULT 1,
    emergencyContact VARCHAR(20),
	PRIMARY KEY (athleteID),
	FOREIGN KEY (schoolid) REFERENCES Schools(schoolid) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- Players Table
DROP TABLE IF EXISTS Players;

CREATE TABLE Players (
	playerID INT(11) AUTO_INCREMENT NOT NULL,
	teamID INT(11) NOT NULL,
	athleteID INT(11) NOT NULL,
	PRIMARY KEY (playerID),
	FOREIGN KEY (teamID) REFERENCES Teams(teamID) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (athleteID) REFERENCES Athletes(athleteID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT unique_players UNIQUE (playerID, teamID)
);


-- Games Table
DROP TABLE IF EXISTS Games;

CREATE TABLE Games (
	gameID INT(11) AUTO_INCREMENT NOT NULL,
	homeTeamID INT(11),
	awayTeamID INT(11),
	facilityID INT(11),
	gameDate DATE,
	gameTime TIME,
	gameType ENUM('preseason', 'regular season', 'playoff', 'tournament', 'exhibition'),
	status ENUM('scheduled', 'in progress', 'completed', 'cancelled', 'postponed', 'forfeited'),
	PRIMARY KEY (gameID),
	FOREIGN KEY (homeTeamID) REFERENCES Teams(teamID) ON DELETE RESTRICT,
	FOREIGN KEY (awayTeamID) REFERENCES Teams(teamID) ON DELETE RESTRICT,
	FOREIGN KEY (facilityID) REFERENCES Facilities(facilityID) ON DELETE RESTRICT,
	CONSTRAINT unique_teams CHECK (homeTeamID != awayTeamID),
	CONSTRAINT facility_in_use UNIQUE (facilityID, gameDate) 
);

INSERT INTO Schools (name, address, phone) VALUES
('Lincoln High School', '123 Education Blvd, Springfield, IL', '555-123-4567'),
('Jefferson High School', '456 Scholar Way, Springfield, IL', '555-123-4568'),
('Washington High School', '789 Academic Ave, Springfield, IL', '555-123-4569'),
('Roosevelt High School', '321 Learning Lane, Springfield, IL', '555-123-4570');

INSERT INTO Teams (schoolID, teamName, sportType, varsityJv, seasonName, academicYear) VALUES
(
    (SELECT schoolID FROM Schools WHERE name='Lincoln High School'),
    'Lincoln Lions',
    'football',
    'varsity',
    'fall',
    2024
),
(
    (SELECT schoolID FROM Schools WHERE name='Lincoln High School'),
    'Lincoln Lions',
    'volleyball',
    'varsity',
    'fall',
    2024
),
(
    (SELECT schoolID FROM Schools WHERE name='Jefferson High School'),
    'Jefferson Jaguars',
    'basketball',
    'varsity',
    'winter',
    2024
),
(
    (SELECT schoolID FROM Schools WHERE name='Jefferson High School'),
    'Jefferson Jaguars',
    'soccer',
    'jv',
    'winter',
    2024
),
(
    (SELECT schoolID FROM Schools WHERE name='Washington High School'),
    'Washington Wildcats',
    'baseball',
    'varsity',
    'spring',
    2024
),
(
    (SELECT schoolID FROM Schools WHERE name='Washington High School'),
    'Washington Wildcats',
    'tennis',
    'varsity',
    'spring',
    2024
),
(
    (SELECT schoolID FROM Schools WHERE name='Roosevelt High School'),
    'Roosevelt Ravens',
    'basketball',
    'jv',
    'winter',
    2024
);

INSERT INTO Facilities (schoolID, facilityName, capacity) VALUES
(
    (SELECT schoolID FROM Schools WHERE name='Lincoln High School'),
    'Lincoln Stadium',
    2500
),
(
    (SELECT schoolID FROM Schools WHERE name='Lincoln High School'),
    'Lincoln Gymnasium',
    1200
),
(
    (SELECT schoolID FROM Schools WHERE name='Jefferson High School'),
    'Jefferson Field House',
    1800
),
(
    (SELECT schoolID FROM Schools WHERE name='Washington High School'),
    'Washington Baseball Field',
    1500
),
(
    (SELECT schoolID FROM Schools WHERE name='Washington High School'),
    'Washington Tennis Courts',
    300
),
(
    (SELECT schoolID FROM Schools WHERE name='Roosevelt High School'),
    'Roosevelt Arena',
    2000
);

INSERT INTO Athletes (schoolID, firstName, lastName, gradeLevel, isEligible, isActive, emergencyContact) VALUES
(
    (SELECT schoolID FROM Schools WHERE name='Lincoln High School'),
    'John',
    'Smith',
    11,
    1,
    1,
    '555-111-2222'
),
(
    (SELECT schoolID FROM Schools WHERE name='Lincoln High School'),
    'Michael',
    'Johnson',
    12,
    1,
    1,
    '555-111-2223'
),
(
    (SELECT schoolID FROM Schools WHERE name='Jefferson High School'),
    'David',
    'Brown',
    12,
    1,
    1,
    '555-222-3333'
),
(
    (SELECT schoolID FROM Schools WHERE name='Jefferson High School'),
    'Christopher',
    'Williams',
    10,
    1,
    1,
    '555-222-3334'
),
(
    (SELECT schoolID FROM Schools WHERE name='Washington High School'),
    'James',
    'Wilson',
    11,
    1,
    1,
    '555-333-4444'
),
(
    (SELECT schoolID FROM Schools WHERE name='Washington High School'),
    'Robert',
    'Davis',
    9,
    1,
    1,
    '555-333-4445'
),
(
    (SELECT schoolID FROM Schools WHERE name='Roosevelt High School'),
    'Daniel',
    'Miller',
    12,
    1,
    1,
    '555-444-5555'
),
(
    (SELECT schoolID FROM Schools WHERE name='Roosevelt High School'),
    'Matthew',
    'Taylor',
    11,
    1,
    1,
    '555-444-5556'
);

INSERT INTO Players (teamID, athleteID) VALUES
(
    (SELECT teamID FROM Teams WHERE teamName='Lincoln Lions' AND sportType='football' AND varsityJv='varsity'),
    (SELECT athleteID FROM Athletes WHERE firstName='John' AND lastName='Smith')
),
(
    (SELECT teamID FROM Teams WHERE teamName='Lincoln Lions' AND sportType='volleyball' AND varsityJv='varsity'),
    (SELECT athleteID FROM Athletes WHERE firstName='Michael' AND lastName='Johnson')
),
(
    (SELECT teamID FROM Teams WHERE teamName='Jefferson Jaguars' AND sportType='basketball' AND varsityJv='varsity'),
    (SELECT athleteID FROM Athletes WHERE firstName='David' AND lastName='Brown')
),
(
    (SELECT teamID FROM Teams WHERE teamName='Jefferson Jaguars' AND sportType='soccer' AND varsityJv='jv'),
    (SELECT athleteID FROM Athletes WHERE firstName='Christopher' AND lastName='Williams')
),
(
    (SELECT teamID FROM Teams WHERE teamName='Washington Wildcats' AND sportType='baseball' AND varsityJv='varsity'),
    (SELECT athleteID FROM Athletes WHERE firstName='James' AND lastName='Wilson')
),
(
    (SELECT teamID FROM Teams WHERE teamName='Washington Wildcats' AND sportType='tennis' AND varsityJv='varsity'),
    (SELECT athleteID FROM Athletes WHERE firstName='Robert' AND lastName='Davis')
),
(
    (SELECT teamID FROM Teams WHERE teamName='Roosevelt Ravens' AND sportType='basketball' AND varsityJv='jv'),
    (SELECT athleteID FROM Athletes WHERE firstName='Daniel' AND lastName='Miller')
),
(
    (SELECT teamID FROM Teams WHERE teamName='Roosevelt Ravens' AND sportType='basketball' AND varsityJv='jv'),
    (SELECT athleteID FROM Athletes WHERE firstName='Matthew' AND lastName='Taylor')
);

INSERT INTO Games (homeTeamID, awayTeamID, facilityID, gameDate, gameTime, gameType, status) VALUES
(
    (SELECT teamID FROM Teams WHERE teamName='Lincoln Lions' AND sportType='football' AND varsityJv='varsity'),
    (SELECT teamID FROM Teams WHERE teamName='Jefferson Jaguars' AND sportType='basketball' AND varsityJv='varsity'),
    (SELECT facilityID FROM Facilities WHERE facilityName='Lincoln Stadium'),
    '2024-09-15',
    '19:00:00',
    'regular season',
    'scheduled'
),
(
    (SELECT teamID FROM Teams WHERE teamName='Lincoln Lions' AND sportType='volleyball' AND varsityJv='varsity'),
    (SELECT teamID FROM Teams WHERE teamName='Washington Wildcats' AND sportType='baseball' AND varsityJv='varsity'),
    (SELECT facilityID FROM Facilities WHERE facilityName='Lincoln Gymnasium'),
    '2024-10-20',
    '17:30:00',
    'tournament',
    'scheduled'
),
(
    (SELECT teamID FROM Teams WHERE teamName='Jefferson Jaguars' AND sportType='soccer' AND varsityJv='jv'),
    (SELECT teamID FROM Teams WHERE teamName='Roosevelt Ravens' AND sportType='basketball' AND varsityJv='jv'),
    (SELECT facilityID FROM Facilities WHERE facilityName='Jefferson Field House'),
    '2024-11-10',
    '16:00:00',
    'exhibition',
    'scheduled'
),
(
    (SELECT teamID FROM Teams WHERE teamName='Washington Wildcats' AND sportType='tennis' AND varsityJv='varsity'),
    (SELECT teamID FROM Teams WHERE teamName='Lincoln Lions' AND sportType='volleyball' AND varsityJv='varsity'),
    (SELECT facilityID FROM Facilities WHERE facilityName='Washington Tennis Courts'),
    '2024-04-12',
    '15:00:00',
    'preseason',
    'completed'
),
(
    (SELECT teamID FROM Teams WHERE teamName='Roosevelt Ravens' AND sportType='basketball' AND varsityJv='jv'),
    (SELECT teamID FROM Teams WHERE teamName='Jefferson Jaguars' AND sportType='soccer' AND varsityJv='jv'),
    (SELECT facilityID FROM Facilities WHERE facilityName='Roosevelt Arena'),
    '2024-12-05',
    '18:00:00',
    'regular season',
    'scheduled'
);

SET FOREIGN_KEY_CHECKS = 1;
COMMIT;
