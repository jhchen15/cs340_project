/*
Citation for PL/SQL:
Date: 11/18/2025
Copied from: Implementing CUD opertations in your app
Source URL: https://canvas.oregonstate.edu/courses/2017561/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=25645149
*/

-- #############################
-- DELETE Athlete
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteAthlete;

DELIMITER //
CREATE PROCEDURE sp_DeleteAthlete(IN p_athleteID INT)
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

    START TRANSACTION;
        -- First delete from Players table (child table)
        DELETE FROM Players WHERE athleteID = p_athleteID;
        
        -- Then delete from Athletes table
        DELETE FROM Athletes WHERE athleteID = p_athleteID;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Athletes for athleteID: ', p_athleteID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- #############################
-- DELETE Team
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteTeam;

DELIMITER //
CREATE PROCEDURE sp_DeleteTeam(IN p_teamID INT)
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

    START TRANSACTION;
        -- First delete from Players table (child table)
        DELETE FROM Players WHERE teamID = p_teamID;
        
        -- Then delete from Games table where this team is either home or away team
        DELETE FROM Games WHERE homeTeamID = p_teamID OR awayTeamID = p_teamID;
        
        -- Then delete from Teams table
        DELETE FROM Teams WHERE teamID = p_teamID;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Teams for teamID: ', p_teamID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;