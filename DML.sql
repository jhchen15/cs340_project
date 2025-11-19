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
  Players Page
*****************/

-- Create: new player based on athlete and team
INSERT INTO Players (teamID, athleteID)
VALUES (@teamIdInput, @athleteIdInput);

-- Read Players: retrieves full list of players with associated athlete and team information
SELECT 
  p.playerID as id,
  a.firstName as first_name,
  a.lastName as last_name,
  s.name AS school,
  t.sportType as sport,
  t.varsityJv as 'varsity_/_JV',
  t.academicYear as academic_year,
  IF(a.isEligible, '✓', '✗') AS eligible,
  IF(a.isActive, '✓', '✗') AS active
FROM Players AS p
JOIN Athletes AS a ON p.athleteID = a.athleteID
JOIN Teams AS t ON p.teamID = t.teamID
JOIN Schools AS s ON s.schoolID = a.schoolID;

-- Read Athletes: retrieves athlete details for Player creation
SELECT
  a.athleteID,
  a.firstName,
  a.lastName,
  s.schoolID,
  s.name AS schoolName
FROM Athletes as a
JOIN Schools as s ON s.schoolID = a.schoolID;

-- Read Teams: retrieves team details for Athlete assignment to create a Player
SELECT DISTINCT
  t.teamID,
  s.name as schoolName,
  t.sportType,
  t.varsityJv,
  t.academicYear
FROM Teams as t JOIN Schools as s ON t.schoolID = s.schoolID
ORDER BY t.teamID;

-- Read Roster: filtered version of Players list by team
SELECT
  p.playerID as id,
  a.firstName as first_name,
  a.lastName as last_name,
  s.name AS school,
  t.sportType as sport,
  t.varsityJv as 'varsity_/_JV',
  t.academicYear as academic_year,
  IF(a.isEligible, '✓', '✗') AS eligible,
  IF(a.isActive, '✓', '✗') AS active
FROM Players AS p
JOIN Athletes AS a ON p.athleteID = a.athleteID
JOIN Teams AS t ON p.teamID = t.teamID
JOIN Schools AS s ON s.schoolID = a.schoolID
WHERE a.athleteID = @athleteIdInput;

-- Update: An athlete can be assigned to a different team, but a player cannot be changed to a different athlete
UPDATE Players
SET teamID = @teamIdInput
WHERE playerID = @playerIdInput;

-- Update Player / Team dropdown select: Filters teams in Player creation dropdown to Athlete's school
SELECT
  teamID,
  teamName,
  sportType,
  varsityJv,
  academicYear
FROM Schools as s
JOIN Teams as t ON s.schoolID = t.schoolID
JOIN Athletes as a ON a.schoolID = s.schoolID
WHERE a.athleteID = @teamIDInput;

-- Delete
DELETE FROM Players
WHERE playerID = @playerIdInput;


/****************
  Games Page
*****************/

-- Create
INSERT INTO Games (homeTeamID, awayTeamID, facilityID, gameDate, gameTime, gameType, status)
VALUES (@homeTeamIdInput, @awayTeamIdInput, @facilityIdInput, @gameDateInput, @gameTimeInput, @gameTypeInput, @statusInput);

-- Read: Retrieves the list of games and relevant details to display
-- including team names, location details, times, type and status
SELECT
  g.gameID AS id,
  ht.teamName AS home_team,
  at.teamName AS away_team,
  s.name AS facility_location,
  f.facilityName AS facility_name,
  g.gameDate AS game_date,
  g.gameTime as game_time,
  g.gameType as game_type,
  g.status
FROM Games AS g JOIN Teams AS ht ON g.homeTeamID = ht.teamID
JOIN Teams AS at ON g.awayTeamID = at.teamID
JOIN Facilities AS f ON g.facilityID = f.facilityID
JOIN Schools AS s ON s.schoolID = f.schoolID;

-- Read team list for create game dropdowns
SELECT
  teamID,
  schoolID,
  teamName,
  sportType,
  varsityJv,
  seasonName,
  academicYear
FROM Teams;

-- Read facility list for create game dropdowns
SELECT
  facilityID,
  schoolID,
  facilityName,
  capacity
FROM Facilities;

-- Read list of distinct sports based on teams created
SELECT DISTINCT
  sportType
FROM Teams;

-- Read list of teams based on sport selected
SELECT
  t.teamID,
  s.name AS 'schoolName',
  t.varsityJv,
  t.academicYear
FROM Teams as t JOIN Schools as s ON t.schoolID = s.schoolID
WHERE t.sportType = @sportTypeInput;

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
