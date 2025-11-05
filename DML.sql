
/****************
  Schools Table
*****************/
-- Read only: school details are considered static
SELECT schoolID AS 'ID',
       name AS 'Name',
       address AS 'Address',
       phone AS 'Phone'
FROM Schools;


/****************
  Players Table
*****************/

-- Create: new player based on athlete and team
INSERT INTO Players (teamID, athleteID)
VALUES (@teamIdInput, @athleteIdInput);

-- Read: retrieves identifying athlete details for each player, and associated team information
SELECT p.playerID,
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
INSERT INTO Games
VALUES (@homeTeamIdInput, @awayTeamIdInput, @facilityIdInput, @gameDateInput, @gameTimeInput, @gameTypeInput, @statusInput);

-- Read: Retrieves the list of games and relevant details to display
-- including team names, location details, times, type and status
SELECT g.gameID,
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
SET homeTeamID = @homeTeamIdInput,
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