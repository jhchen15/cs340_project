SET FOREIGN_KEY_CHECKS=0;
SET AUTOCOMMIT = 0;

DROP TABLE IF EXISTS Schools;
DROP TABLE IF EXISTS Teams;
DROP TABLE IF EXISTS Facilities;
DROP TABLE IF EXISTS Athletes;
DROP TABLE IF EXISTS Players;
DROP TABLE IF EXISTS Games;

CREATE TABLE Schools (
	schoolID INT(11) AUTO_INCREMENT NOT NULL,
	name VARCHAR(120) NOT NULL,
	address VARCHAR(120),
	phone VARCHAR(20),
	PRIMARY KEY (schoolID)
);

CREATE TABLE Teams (
	teamID INT(11) AUTO_INCREMENT NOT NULL,
	schoolID INT(11) NOT NULL,
	teamName VARCHAR(120) NOT NULL,
	sportType ENUM('football', 'volleyball', 'basketball', 'soccer', 'baseball', 'tennis') NOT NULL,
	varsityJv ENUM('varsity', 'jv') NOT NULL,
	seasonName ENUM('fall', 'winter', 'spring') NOT NULL,
	academicYear YEAR,
	PRIMARY KEY (teamID),
	FOREIGN KEY (schoolID) REFERENCES Schools(schoolID),
    CONSTRAINT valid_season_sports CHECK (
                    (seasonName = 'fall' AND sportType IN ('football', 'volleyball')) OR
                    (seasonName = 'winter' AND sportType IN ('basketball', 'soccer')) OR
                    (seasonName = 'spring' AND sportType IN ('baseball', 'tennis'))
    )
);

CREATE TABLE Facilities (
	facilityID INT(11) AUTO_INCREMENT NOT NULL,
	schoolID INT(11) NOT NULL,
	facilityName VARCHAR(120),
	capacity INT,
	PRIMARY KEY (facilityID),
	FOREIGN KEY (schoolID) REFERENCES Schools(schoolID)
);

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
	FOREIGN KEY (schoolid) REFERENCES Schools(schoolid)
);

CREATE TABLE Players (
	playerID INT(11) AUTO_INCREMENT NOT NULL,
	teamID INT(11) NOT NULL,
	athleteID INT(11) NOT NULL,
	PRIMARY KEY (playerID),
	FOREIGN KEY (teamID) REFERENCES Teams(teamID),
    FOREIGN KEY (athleteID) REFERENCES Athletes(athleteID)
);

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
	FOREIGN KEY (homeTeamID) REFERENCES Teams(teamID),
	FOREIGN KEY (awayTeamID) REFERENCES Teams(teamID),
	CONSTRAINT unique_teams CHECK homeTeamID <> awayTeamID,
	CONSTRAINT facility_in_use UNIQUE (facilityID, gameDate) 
);

SET FOREIGN_KEY_CHECKS=1;
COMMIT;
