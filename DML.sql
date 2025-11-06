-- Group 57
-- Humza Hussain, James Chen
-- This file contains the DML SQL Statements for Valleyview Athletics UI
-- @{attribute}Input indicates the variable that will have data passed from the backend
-- (e.g., @firstNameInput for first name of an athlete)


/****************
  Schools Table
*****************/

-- Read only: school details are considered static
SELECT 
  schoolID,
  name,
  address,
  phone
FROM Schools;

/****************
  Facilities Table
*****************/

-- Read only: facility details are considered static
SELECT 
  Facilities.facilityID, 
  Schools.name as 'school', 
  Facilities.facilityName, 
  Facilities.capacity 
FROM Facilities
LEFT JOIN Schools ON Facilities.schoolID = Schools.schoolID;

/****************
  Athletes Table
*****************/

-- Create: new athlete
INSERT INTO Athletes (firstName, lastName, schoolID, gradeLevel, isEligible, isActive, emergencyContact)
VALUES (@firstNameInput, @lastNameInput, @schoolIdInput, @gradeLevelInput, @isEligibleInput, @isActiveInput, @emergencyContactInput);

-- Read: retrieves identifying athlete details for all athletes
SELECT 
  Athletes.athleteID, 
  Schools.name as 'school', 
  Athletes.firstName, 
  Athletes.lastName, 
  Athletes.gradeLevel, 
  Athletes.isEligible, 
  Athletes.isActive, 
  Athletes.emergencyContact 
FROM Athletes
LEFT JOIN Schools ON Athletes.schoolID = Schools.schoolID;

-- Update: An athlete's details can be modified
UPDATE Athletes
SET 
  firstName = @firstNameInput,
  lastName = @lastNameInput,
  schoolID = @schoolIdInput,
  gradeLevel = @gradeLevelInput,
  isEligible = @isEligibleInput,
  isActive = @isActiveInput,
  emergencyContact = @emergencyContactInput
WHERE athleteID = @athleteIdInput;

-- Delete
DELETE FROM Athletes
WHERE athleteID = @athleteIdInput;

/****************
  Teams Table
*****************/

-- Create: new team
INSERT INTO Teams (teamName, schoolID, sportType, varsityJv, seasonName, academicYear)
VALUES (@teamNameInput, @schoolIdInput, @sportTypeInput, @varsityJvInput, @seasonNameInput, @academicYearInput);

-- Read: retrieves identifying team details for all teams
SELECT 
  Teams.teamID, 
  Schools.name as 'school', 
  Teams.teamName, 
  Teams.sportType, 
  Teams.varsityJv,
  Teams.seasonName, 
  Teams.academicYear 
FROM Teams
LEFT JOIN Schools ON Teams.schoolID = Schools.schoolID;

-- Update: An existing team's details can be modified
UPDATE Teams
SET 
  teamName = @teamNameInput,
  schoolID = @schoolIdInput,
  sportType = @sportTypeInput,
  varsityJv = @varsityJvInput,
  seasonName = @seasonNameInput,
  academicYear = @academicYearInput
WHERE teamID = @teamIdInput;

-- Delete
DELETE FROM Teams
WHERE teamID = @teamIdInput;

/****************
  Players Table
*****************/

-- Create: new player based on athlete and team
INSERT INTO Players (teamID, athleteID)
VALUES (@teamIdInput, @athleteIdInput);

-- Read: retrieves identifying athlete details for each player, and associated team information
SELECT 
  p.playerID,
  a.firstName,
  a.lastName,
  s.name AS schoolName,
  t.sportType,
  t.varsityJv,
  t.academicYear,
  a.isEligible,
  a.isActive
FROM Players AS p
JOIN Athletes AS a ON p.athleteID = a.athleteID
JOIN Teams AS t ON p.teamID = t.teamID
JOIN Schools AS s ON s.schoolID = a.schoolID;

-- Update: An athlete can be assigned to a different team, but a player cannot be changed to a different athlete
UPDATE Players
SET teamID = @teamIdInput
WHERE playerID = @playerIdInput;

-- Delete
DELETE FROM Players
WHERE playerID = @playerIdInput;


/****************
  Games Table
*****************/

-- Create
INSERT INTO Games (homeTeamID, awayTeamID, facilityID, gameDate, gameTime, gameType, status)
VALUES (@homeTeamIdInput, @awayTeamIdInput, @facilityIdInput, @gameDateInput, @gameTimeInput, @gameTypeInput, @statusInput);

-- Read: Retrieves the list of games and relevant details to display
-- including team names, location details, times, type and status
SELECT 
  g.gameID,
  ht.teamName AS homeTeamName,
  at.teamName AS awayTeamName,
  s.name AS facilitySchool,
  f.facilityName,
  g.gameDate,
  g.gameTime,
  g.gameType,
  g.status
FROM Games AS g
JOIN Teams AS ht ON g.homeTeamID = ht.teamID
JOIN Teams AS at ON g.awayTeamID = at.teamID
JOIN Facilities AS f ON g.facilityID = f.facilityID
JOIN Schools AS s ON s.schoolID = f.schoolID;

-- Update
UPDATE Games
SET 
  homeTeamID = @homeTeamIdInput,
  awayTeamID = @awayTeamIdInput,
  facilityID = @facilityIdInput,
  gameDate = @gameDateInput,
  gameTime = @gameTimeInput,
  gameType = @gameTypeInput,
  status = @statusInput
WHERE gameID = @gameIdInput;

-- Delete
DELETE FROM Games
WHERE gameID = @gameIdInput;
