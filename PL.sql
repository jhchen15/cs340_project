/*
Citation for PL/SQL:
Date: 11/18/2025
Adapted from: CS340 Module 8 Exploration: Implementing CUD Operations In Your App
Source URL: https://canvas.oregonstate.edu/courses/2017561/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=25645149
*/

/****************
  Athletes Table
*****************/

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
   DECLARE playerID INT(11);

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
# DELIMITER ;

/****************
  Games Table
*****************/

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