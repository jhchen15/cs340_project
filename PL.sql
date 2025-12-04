/*
Citation for PL/SQL:
Date: 11/18/2025
Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
Source URL: https://canvas.oregonstate.edu/courses/2017561/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=25645149
*/

/****************
  Athletes Table
*****************/

-- CREATE procedure for Athletes
-- Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
-- Date Accessed: 11/18/2025

DROP PROCEDURE IF EXISTS sp_CreateAthlete;

DELIMITER //
CREATE PROCEDURE sp_CreateAthlete(
    IN a_schoolID INT(11),
    IN a_firstName VARCHAR(120),
    IN a_lastName VARCHAR(120),
    IN a_gradeLevel INT(11),
    IN a_isEligible BOOLEAN,
    IN a_isActive BOOLEAN,
    IN a_emergencyContact VARCHAR(20),
    OUT athleteID INT(11)
)
BEGIN
    DECLARE error_message VARCHAR(255);

    -- Exit handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Create athlete
    START TRANSACTION;
        INSERT INTO Athletes(schoolID, firstName, lastName, gradeLevel, isEligible, isActive, emergencyContact)
        VALUES(a_schoolID, a_firstName, a_lastName, a_gradeLevel, a_isEligible, a_isActive, a_emergencyContact);

        -- Raise error if create fails
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('Athlete was not created: ', a_firstName, ' ', a_lastName);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        SET athleteID = LAST_INSERT_ID();
    COMMIT;
END //
DELIMITER ;

-- UPDATE procedure for Athletes
-- Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
-- Date Accessed: 11/18/2025

DROP PROCEDURE IF EXISTS sp_UpdateAthlete;

DELIMITER //
CREATE PROCEDURE sp_UpdateAthlete(
    IN a_id INT(11),
    IN a_schoolID INT(11),
    IN a_firstName VARCHAR(120),
    IN a_lastName VARCHAR(120),
    IN a_gradeLevel INT(11),
    IN a_isEligible BOOLEAN,
    IN a_isActive BOOLEAN,
    IN a_emergencyContact VARCHAR(20)
)
BEGIN
    DECLARE error_message VARCHAR(255);

    -- Exit handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Update athlete
    START TRANSACTION;
        UPDATE Athletes
        SET
            schoolID = a_schoolID,
            firstName = a_firstName,
            lastName = a_lastName,
            gradeLevel = a_gradeLevel,
            isEligible = a_isEligible,
            isActive = a_isActive,
            emergencyContact = a_emergencyContact
        WHERE athleteID = a_id;

        -- Raise error if update fails
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching athlete found for id: ', a_id);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    COMMIT;
END //
DELIMITER ;

-- DELETE procedure
-- Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
-- Date Accessed: 11/18/2025

DROP PROCEDURE IF EXISTS sp_DeleteAthlete;

DELIMITER //
CREATE PROCEDURE sp_DeleteAthlete(IN a_ID INT)
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propagate the custom error message to the caller
        RESIGNAL;
    END;

    -- Delete athlete
    START TRANSACTION;
        DELETE FROM Athletes WHERE athleteID = a_ID;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Athletes for athleteID: ', a_ID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

/****************
  Teams Table
*****************/

-- CREATE procedure for Teams
-- Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
-- Date Accessed: 11/18/2025

DROP PROCEDURE IF EXISTS sp_CreateTeam;

DELIMITER //
CREATE PROCEDURE sp_CreateTeam(
    IN t_schoolID INT(11),
    IN t_teamName VARCHAR(120),
    IN t_sportType ENUM ('football', 'volleyball', 'basketball', 'soccer', 'baseball', 'tennis'),
    IN t_varsityJv ENUM ('varsity', 'jv'),
    IN t_seasonName ENUM ('fall', 'winter', 'spring'),
    IN t_academicYear YEAR,
    OUT teamID INT(11)
)
BEGIN
    DECLARE error_message VARCHAR(255);
    DECLARE valid_seasons VARCHAR(255);

    -- Exit handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Validate sport-season combination
    CASE t_sportType
        WHEN 'football' THEN SET valid_seasons = 'fall';
        WHEN 'volleyball' THEN SET valid_seasons = 'fall';
        WHEN 'basketball' THEN SET valid_seasons = 'winter';
        WHEN 'soccer' THEN SET valid_seasons = 'winter';
        WHEN 'baseball' THEN SET valid_seasons = 'spring';
        WHEN 'tennis' THEN SET valid_seasons = 'spring';
        ELSE SET valid_seasons = '';
    END CASE;

    IF valid_seasons != t_seasonName THEN
        -- Custom error message with season information
        SET error_message = CONCAT('Invalid season for ', t_sportType, 
                                   '. ', t_sportType, ' teams must be in ', 
                                   valid_seasons, ' season.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;

    -- Create team
    START TRANSACTION;
        INSERT INTO Teams(schoolID, teamName, sportType, varsityJv, seasonName, academicYear)
        VALUES(t_schoolID, t_teamName, t_sportType, t_varsityJv, t_seasonName, t_academicYear);

        -- Raise error if create fails
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('Team was not created: ', t_teamName);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        SET teamID = LAST_INSERT_ID();
    COMMIT;
END //
DELIMITER ;

-- UPDATE procedure for Teams
-- Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
-- Date Accessed: 11/18/2025

DROP PROCEDURE IF EXISTS sp_UpdateTeam;

DELIMITER //
CREATE PROCEDURE sp_UpdateTeam(
    IN t_id INT(11),
    IN t_schoolID INT(11),
    IN t_teamName VARCHAR(120),
    IN t_sportType ENUM ('football', 'volleyball', 'basketball', 'soccer', 'baseball', 'tennis'),
    IN t_varsityJv ENUM ('varsity', 'jv'),
    IN t_seasonName ENUM ('fall', 'winter', 'spring'),
    IN t_academicYear YEAR
)
BEGIN
    DECLARE error_message VARCHAR(255);
    DECLARE valid_seasons VARCHAR(255);

    -- Exit handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Validate sport-season combination
    CASE t_sportType
        WHEN 'football' THEN SET valid_seasons = 'fall';
        WHEN 'volleyball' THEN SET valid_seasons = 'fall';
        WHEN 'basketball' THEN SET valid_seasons = 'winter';
        WHEN 'soccer' THEN SET valid_seasons = 'winter';
        WHEN 'baseball' THEN SET valid_seasons = 'spring';
        WHEN 'tennis' THEN SET valid_seasons = 'spring';
        ELSE SET valid_seasons = '';
    END CASE;

    IF valid_seasons != t_seasonName THEN
        -- Custom error message with season information
        SET error_message = CONCAT('Invalid season for ', t_sportType, 
                                   '. ', t_sportType, ' teams must be in ', 
                                   valid_seasons, ' season.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;

    -- Update team
    START TRANSACTION;
        UPDATE Teams
        SET
            schoolID = t_schoolID,
            teamName = t_teamName,
            sportType = t_sportType,
            varsityJv = t_varsityJv,
            seasonName = t_seasonName,
            academicYear = t_academicYear
        WHERE teamID = t_id;

        -- Raise error if update fails
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching team found for id: ', t_id);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    COMMIT;
END //
DELIMITER ;

-- DELETE procedure
-- Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
-- Date Accessed: 11/18/2025

DROP PROCEDURE IF EXISTS sp_DeleteTeam;

DELIMITER //
CREATE PROCEDURE sp_DeleteTeam(IN t_ID INT)
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propagate the custom error message to the caller
        RESIGNAL;
    END;

    -- Delete team
    START TRANSACTION;
        DELETE FROM Teams WHERE teamID = t_ID;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Teams for teamID: ', t_ID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

/****************
  Players Table
*****************/

-- DELETE procedure
-- Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
-- Date Accessed: 11/18/2025

DROP PROCEDURE IF EXISTS sp_DeletePlayer;

DELIMITER //
CREATE PROCEDURE sp_DeletePlayer(
    IN p_ID INT(11)
)
BEGIN
    DECLARE error_message VARCHAR(255);

    -- Exit handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Delete player
    START TRANSACTION;
        DELETE FROM Players WHERE playerID = p_ID;

        -- Raise error if delete fails
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching player found for id: ', p_ID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;
END //
DELIMITER ;

-- CREATE procedure
-- Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
-- Date Accessed: 11/18/2025

DROP PROCEDURE IF EXISTS sp_CreatePlayer;

DELIMITER //
CREATE PROCEDURE sp_CreatePlayer(
    IN athleteID INT(11),
    IN teamID INT(11),
    OUT playerID INT(11)
)
BEGIN
   DECLARE error_message VARCHAR(255);

    -- Exit handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Create player
    START TRANSACTION;
        INSERT INTO Players(athleteID, teamID)
        VALUES(athleteID, teamID);

        -- Raise error if create fails
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('Player was not created for athleteID: ', athleteID, ' teamID: ', teamID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        SET playerID = LAST_INSERT_ID();
    COMMIT;
END //
DELIMITER ;

/****************
  Games Table
*****************/

-- CREATE procedure
-- Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
-- Date Accessed: 11/18/2025
DROP PROCEDURE IF EXISTS sp_CreateGame;

DELIMITER //
CREATE PROCEDURE sp_CreateGame(
    IN homeTeamID INT(11),
    IN awayTeamID INT(11),
    IN facilityID INT(11),
    IN gameDate DATE,
    IN gameTime TIME,
    IN gameType ENUM ('preseason', 'regular season', 'playoff', 'tournament', 'exhibition'),
    IN status ENUM ('scheduled', 'in progress', 'completed', 'cancelled', 'postponed', 'forfeited'),
    OUT gameID INT(11)
)
BEGIN
    DECLARE error_message VARCHAR(255);

    -- Exit handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Create game
    START TRANSACTION;
        INSERT INTO Games(homeTeamID, awayTeamID, facilityID, gameDate, gameTime, gameType, status)
        VALUES (homeTeamID, awayTeamID, facilityID, gameDate, gameTime, gameType, status);

        -- Raise error if create fails
        IF ROW_COUNT() = 0 THEN
            SET error_message = 'Game was not created';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        SET gameID = LAST_INSERT_ID();
    COMMIT;
END //

DELIMITER ;

-- DELETE procedure
-- Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
-- Date Accessed: 11/18/2025

DROP PROCEDURE IF EXISTS sp_DeleteGame;

DELIMITER //
CREATE PROCEDURE sp_DeleteGame(
    IN g_ID INT(11)
)
BEGIN
    DECLARE error_message VARCHAR(255);

    -- Exit handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    -- Delete game
    START TRANSACTION;
        DELETE FROM Games WHERE gameID = g_id;

        -- Raise error if delete fails
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching game found for id: ', g_ID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;
END //
DELIMITER ;

-- UPDATE procedure
-- Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
-- Date Accessed: 11/18/2025

DROP PROCEDURE IF EXISTS sp_UpdateGame;

DELIMITER //
CREATE PROCEDURE sp_UpdateGame(
    IN g_id INT(11),
    IN g_facility INT(11),
    IN g_date DATE,
    IN g_time TIME,
    IN g_type ENUM ('preseason', 'regular season', 'playoff', 'tournament', 'exhibition'),
    IN g_status ENUM ('scheduled', 'in progress', 'completed', 'cancelled', 'postponed', 'forfeited')
)
BEGIN
    DECLARE error_message VARCHAR(255);

    -- Exit handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    -- Update transaction
    START TRANSACTION;
        UPDATE Games
        SET
            facilityID = g_facility,
            gameDate = g_date,
            gameTime = g_time,
            gameType = g_type,
            status = g_status
        WHERE gameID = g_id;

        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('Error updating game ID: ', g_id);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    COMMIT;
END;

DELIMITER ;