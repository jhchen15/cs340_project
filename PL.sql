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