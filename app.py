# ########################################
# ########## SETUP

from flask import Flask, render_template, request, redirect, jsonify, url_for
import database.db_connector as db

PORT = 3092

app = Flask(__name__)

# ########################################
# ########## ROUTE HANDLERS

# READ ROUTES
@app.route("/", methods=["GET"])
def home():
    try:
        return render_template("home.j2")

    except Exception as e:
        print(f"Error rendering page: {e}")
        return "An error occurred while rendering the page.", 500


@app.route("/schools", methods=["GET"])
def schools():
    try:
        dbConnection = db.connectDB()  # Open our database connection

        # Retrieve list of Schools and associated info
        query = ("SELECT schoolID AS 'Id', name AS 'Name', address AS 'Address', phone AS 'Phone' "
                 "FROM Schools;")
        schools = db.query(dbConnection, query).fetchall()

        # Render schools.j2 file, and send school query results
        return render_template(
            "schools.j2", schools=schools
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/facilities", methods=["GET"])
def facilities():
    try:
        dbConnection = db.connectDB()  # Open our database connection

        # Create and execute our queries
        # In query1, we use a JOIN clause to display the names of the homeworlds,
        #       instead of just ID values
        query1 = "SELECT f.facilityID as 'Id', s.name as 'School', \
            f.facilityName as 'Name', f.capacity as 'Capacity' FROM Facilities f \
            LEFT JOIN Schools s ON f.schoolID = s.schoolID;"
        query2 = "SELECT * FROM Schools;"
        facilities = db.query(dbConnection, query1).fetchall()
        schools = db.query(dbConnection, query2).fetchall()

        # Render the facilities.j2 file, and also send the renderer
        # a couple objects that contains facilities and schools information
        return render_template(
            "facilities.j2", facilities=facilities, schools=schools
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/athletes", methods=["GET"])
def athletes():
    try:
        dbConnection = db.connectDB()  # Open our database connection

        # Create and execute our queries
        # In query1, we use a JOIN clause to display the names of the homeworlds,
        #       instead of just ID values
        query1 = "SELECT a.athleteID as 'Id', s.name as 'School', \
            a.firstName as 'First Name', a.lastName as 'Last Name', a.gradeLevel as 'Grade Level', \
            IF(a.isEligible, '✓', '✗') AS 'Eligible', IF(a.isActive, '✓', '✗') as 'Active', \
            a.emergencyContact as 'Emergency Contact' FROM Athletes a \
            LEFT JOIN Schools s ON a.schoolID = s.schoolID;"
        query2 = "SELECT * FROM Schools;"
        athletes = db.query(dbConnection, query1).fetchall()
        schools = db.query(dbConnection, query2).fetchall()

        headers = ('Id', 'School', 'First Name', 'Last Name', 'Grade Level', 
                   'Eligible', 'Active', 'Emergency Contact')

        # Render the athletes.j2 file, and also send the renderer
        # a couple objects that contains athletes and schools information
        return render_template(
            "athletes.j2", athletes=athletes, schools=schools, headers=headers
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/athletes/create", methods=["POST"])
def create_athlete():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        # Get form data
        schoolID = request.form["create_athlete_school"]
        firstName = request.form["create_athlete_firstName"]
        lastName = request.form["create_athlete_lastName"]
        gradeLevel = request.form["create_athlete_gradeLevel"]
        isEligible = request.form["create_athlete_isEligible"]
        isActive = request.form["create_athlete_isActive"]
        emergencyContact = request.form.get("create_athlete_emergencyContact", "")

        # Call stored procedure to create an athlete
        query = "CALL sp_CreateAthlete(%s, %s, %s, %s, %s, %s, %s, @newAthleteID)"
        cursor.execute(query, (schoolID, firstName, lastName, gradeLevel, 
                              isEligible, isActive, emergencyContact))

        # Retrieve new athlete ID from out variable
        cursor.execute("SELECT @newAthleteID AS athleteID")
        row = cursor.fetchone()
        athleteID = row[0] if row else None

        dbConnection.commit()

        # If successful, redirect back to page with success message
        print(f"Athlete created. ID: {athleteID} Name: {firstName} {lastName}")
        return redirect("/athletes?msg=create_ok")

    except Exception as e:
        dbConnection.rollback()
        error_message = str(e)
        print(f"Error creating athlete: {error_message}")
        return redirect("/athletes?error=create_failed")

    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/athletes/update", methods=["POST"])
def update_athlete():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        # Get form data
        athleteID = request.form["update_athlete_id"]
        schoolID = request.form["update_athlete_school"]
        firstName = request.form["update_athlete_firstName"]
        lastName = request.form["update_athlete_lastName"]
        gradeLevel = request.form["update_athlete_gradeLevel"]
        isEligible = request.form["update_athlete_isEligible"]
        isActive = request.form["update_athlete_isActive"]
        emergencyContact = request.form.get("update_athlete_emergencyContact", "")

        # Call stored procedure to update athlete
        query = "CALL sp_UpdateAthlete(%s, %s, %s, %s, %s, %s, %s, %s)"
        cursor.execute(query, (athleteID, schoolID, firstName, lastName, gradeLevel,
                              isEligible, isActive, emergencyContact))

        dbConnection.commit()

        # If successful, redirect back to page with success message
        print(f"Athlete updated. ID: {athleteID} Name: {firstName} {lastName}")
        return redirect("/athletes?msg=update_ok")

    except Exception as e:
        dbConnection.rollback()
        error_message = str(e)
        print(f"Error updating athlete: {error_message}")
        return redirect("/athletes?error=update_failed")

    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/athletes/delete", methods=["POST"])
def delete_athlete():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        athlete_id = request.form["delete_athlete_id"]
        athlete_name = request.form["delete_athlete_name"]

        query1 = "CALL sp_DeleteAthlete(%s);"
        cursor.execute(query1, (athlete_id,))

        dbConnection.commit()
        print(f"DELETE athlete. ID: {athlete_id} Name: {athlete_name}")
        # Return success message
        return redirect("/athletes?msg=delete_ok")

    except Exception as e:
        dbConnection.rollback()
        error_message = str(e)
        print(f"Error executing queries: {error_message}")
        
        # Contraint error code 1451: Cannot delete or update a parent row: a foreign key constraint fails
        if "1451" in error_message:
            if "Players" in error_message:
                error_param = "athlete_has_players"
            else:
                error_param = "athlete_constraint_error"
            return redirect(f"/athletes?error={error_param}")
        else:
            return redirect(f"/athletes?error=delete_failed")

    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/athletes/details", methods=["GET"])
def athlete_details():
    """
    Returns details of the requested athleteID
    """
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        athleteID = request.args.get("athleteID")
        query = ("SELECT athleteID, schoolID, firstName, lastName, gradeLevel, isEligible, isActive, emergencyContact "
                 "FROM Athletes WHERE athleteID = %s")
        cursor.execute(query, (athleteID,))
        result = cursor.fetchone()

        if not result:
            return jsonify({"error": "Athlete not found"}), 404

        athlete = {
            "athleteID": result[0],
            "schoolID": result[1],
            "firstName": result[2],
            "lastName": result[3],
            "gradeLevel": result[4],
            "isEligible": result[5],
            "isActive": result[6],
            "emergencyContact": result[7] if result[7] else ""
        }

        return jsonify(athlete)

    except Exception as e:
        print(f"Error retrieving athlete details: {e}")
        return jsonify({"error": str(e)}), 500

    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()
            

@app.route("/teams", methods=["GET"])
def teams():
    try:
        dbConnection = db.connectDB()  # Open our database connection

        # Create and execute our queries
        # In query1, we use a JOIN clause to display the names of the homeworlds,
        #       instead of just ID values
        query1 = "SELECT t.teamID as 'Id', s.name as 'School', \
            t.teamName as 'Team Name', t.sportType as 'Sport Type', t.varsityJv as 'Varsity / JV', \
            t.seasonName as 'Season Name', t.academicYear as 'Academic Year' FROM Teams t \
            LEFT JOIN Schools s ON t.schoolID = s.schoolID;"
        query2 = "SELECT * FROM Schools;"
        teams = db.query(dbConnection, query1).fetchall()
        schools = db.query(dbConnection, query2).fetchall()

        headers = ('Id', 'School', 'Team Name', 'Sport Type', 'Varsity / JV', 
                   'Season Name', 'Academic Year')

        # Render the athletes.j2 file, and also send the renderer
        # a couple objects that contains teams and schools information
        return render_template(
            "teams.j2", teams=teams, schools=schools, headers=headers
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/teams/create", methods=["POST"])
def create_team():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        # Get form data
        schoolID = request.form["create_team_school"]
        teamName = request.form["create_team_name"]
        sportType = request.form["create_team_sportType"]
        varsityJv = request.form["create_team_varsityJv"]
        seasonName = request.form["create_team_seasonName"]
        academicYear = request.form["create_team_academicYear"]

        # Call stored procedure to create a team
        query = "CALL sp_CreateTeam(%s, %s, %s, %s, %s, %s, @newTeamID)"
        cursor.execute(query, (schoolID, teamName, sportType, varsityJv, 
                              seasonName, academicYear))

        # Retrieve new team ID from out variable
        cursor.execute("SELECT @newTeamID AS teamID")
        row = cursor.fetchone()
        teamID = row[0] if row else None

        dbConnection.commit()

        # If successful, redirect back to page with success message
        print(f"Team created. ID: {teamID} Name: {teamName} ({sportType})")
        return redirect("/teams?msg=create_ok")

    except Exception as e:
        dbConnection.rollback()
        error_message = str(e)
        print(f"Error creating team: {error_message}")
        
        # Check for sport-season constraint error
        if "Invalid season for" in error_message:
            # Extract just the error message part
            if "SQLSTATE[45000]: (1644)" in error_message:
                # Extract the message after the last colon
                parts = error_message.split(":")
                if len(parts) > 2:
                    clean_message = parts[-1].strip()
                else:
                    clean_message = error_message
            else:
                clean_message = error_message
            
            # URL encode the message
            import urllib.parse
            encoded_message = urllib.parse.quote(clean_message)
            return redirect(f"/teams?error=season_sport&message={encoded_message}")
        else:
            return redirect("/teams?error=create_failed")

    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/teams/update", methods=["POST"])
def update_team():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        # Get form data
        teamID = request.form["update_team_id"]
        schoolID = request.form["update_team_school"]
        teamName = request.form["update_team_name"]
        sportType = request.form["update_team_sportType"]
        varsityJv = request.form["update_team_varsityJv"]
        seasonName = request.form["update_team_seasonName"]
        academicYear = request.form["update_team_academicYear"]

        # Call stored procedure to update team
        query = "CALL sp_UpdateTeam(%s, %s, %s, %s, %s, %s, %s)"
        cursor.execute(query, (teamID, schoolID, teamName, sportType, 
                              varsityJv, seasonName, academicYear))

        dbConnection.commit()

        # If successful, redirect back to page with success message
        print(f"Team updated. ID: {teamID} Name: {teamName} ({sportType})")
        return redirect("/teams?msg=update_ok")

    except Exception as e:
        dbConnection.rollback()
        error_message = str(e)
        print(f"Error updating team: {error_message}")
        
        # Check for sport-season constraint error
        if "does not play in" in error_message:
            # Extract the sport-season error message
            error_param = error_message.split(": ")[-1] if ": " in error_message else error_message
            return redirect(f"/teams?error=season_sport&message={error_param}")
        else:
            return redirect("/teams?error=update_failed")

    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/teams/delete", methods=["POST"])
def delete_team():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        team_id = request.form["delete_team_id"]
        team_name = request.form["delete_team_name"]

        query1 = "CALL sp_DeleteTeam(%s);"
        cursor.execute(query1, (team_id,))

        dbConnection.commit()
        print(f"DELETE team. ID: {team_id} Name: {team_name}")
        # Return success message
        return redirect("/teams?msg=delete_ok")

    except Exception as e:
        dbConnection.rollback()
        error_message = str(e)
        print(f"Error executing queries: {error_message}")
        
        # Contraint error code 1451: Cannot delete or update a parent row: a foreign key constraint fails
        if "1451" in error_message:
            if "Players" in error_message and "Games" in error_message:
                error_param = "team_has_players_and_games"
            elif "Players" in error_message:
                error_param = "team_has_players"
            elif "Games" in error_message:
                error_param = "team_has_games"
            else:
                error_param = "team_constraint_error"
            return redirect(f"/teams?error={error_param}")
        else:
            return redirect(f"/teams?error=delete_failed")

    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/teams/details", methods=["GET"])
def team_details():
    """
    Returns details of the requested teamID
    """
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        teamID = request.args.get("teamID")
        query = ("SELECT teamID, schoolID, teamName, sportType, varsityJv, seasonName, academicYear "
                 "FROM Teams WHERE teamID = %s")
        cursor.execute(query, (teamID,))
        result = cursor.fetchone()

        if not result:
            return jsonify({"error": "Team not found"}), 404

        team = {
            "teamID": result[0],
            "schoolID": result[1],
            "teamName": result[2],
            "sportType": result[3],
            "varsityJv": result[4],
            "seasonName": result[5],
            "academicYear": result[6]
        }

        return jsonify(team)

    except Exception as e:
        print(f"Error retrieving team details: {e}")
        return jsonify({"error": str(e)}), 500

    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/players", methods=["GET"])
def players():
    """
    Renders Players page, sends list of players, athletes, and teams
    """
    try:
        dbConnection = db.connectDB()  # Open our database connection

        # Retrieve list of Players with their Athlete / Team / School info
        query1 = ("SELECT p.playerID AS 'id', a.firstName AS 'first_name', a.lastName AS 'last_name', "
                  "s.name AS 'school', t.sportType AS 'sport', t.varsityJv AS 'varsity_/_JV', "
                  "t.academicYear AS 'academic_year', IF(a.isEligible, '✓', '✗') AS 'eligible', "
                  "IF(a.isActive, '✓', '✗') AS 'active' "
                  "FROM Players AS p JOIN Athletes AS a ON p.athleteID = a.athleteID "
                  "JOIN Teams AS t ON p.teamID = t.teamID "
                  "JOIN Schools AS s ON s.schoolID = a.schoolID ;")
        players = db.query(dbConnection, query1).fetchall()

        query2 = ("SELECT a.athleteID, a.firstName, a.lastName, s.schoolID, s.name AS 'schoolName' "
                  "FROM Athletes as a "
                  "JOIN Schools as s ON s.schoolID = a.schoolID ")
        athletes = db.query(dbConnection, query2).fetchall()

        query3 = ("SELECT DISTINCT t.teamID, s.name as schoolName, t.sportType, t.varsityJv, t.academicYear "
                  "FROM Teams as t JOIN Schools as s ON t.schoolID = s.schoolID "
                  "ORDER BY t.teamID ")
        teams = db.query(dbConnection, query3).fetchall()

        headers = ('Id', 'First Name', 'Last Name', 'School', 'Sport',
                   'Varsity / JV', 'Academic Year', 'Eligible', 'Active')

        # Render schools.j2 file, and send school query results
        return render_template(
            "players.j2", players=players, athletes=athletes, teams=teams, headers = headers
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/players/teams", methods=["GET"])
def players_fetch_teams():
    """
    Returns list of teams at a single school based on the athleteID provided
    """
    try:
        dbConnection = db.connectDB()
        athleteID = request.args.get("athleteID")
        query = ("SELECT teamID, teamName, sportType, varsityJv, academicYear "
                 "FROM Schools as s "
                 "JOIN Teams as t ON s.schoolID = t.schoolID "
                 "JOIN Athletes as a ON a.schoolID = s.schoolID "
                 "WHERE a.athleteID = %s")
        teams_list = db.query(dbConnection, query, (athleteID,)).fetchall()
        return jsonify(teams_list)

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/players/roster", methods=["GET"])
def players_fetch_roster():
    """
    Returns roster information for a single team based on the teamID provided
    """
    try:
        dbConnection = db.connectDB()
        teamID = request.args.get("teamID")
        params = []
        query1 = ("SELECT p.playerID AS 'id', a.firstName AS 'first_name', a.lastName AS 'last_name', "
                  "s.name AS 'school', t.sportType AS 'sport', t.varsityJv AS 'varsity_/_JV', "
                  "t.academicYear AS 'academic_year', IF(a.isEligible, '✓', '✗') AS 'eligible', "
                  "IF(a.isActive, '✓', '✗') AS 'active' "
                  "FROM Players AS p JOIN Athletes AS a ON p.athleteID = a.athleteID "
                  "JOIN Teams AS t ON p.teamID = t.teamID "
                  "JOIN Schools AS s ON s.schoolID = a.schoolID ")
        if teamID:
            query1 += f"WHERE t.teamID = %s;"
            params.append(teamID)
        roster = db.query(dbConnection, query1, params).fetchall()
        return jsonify(roster)

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/players/delete", methods=["POST"])
def delete_player():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        playerID = request.form["delete_playerID"]
        name = request.form["delete_player_name"]

        # Construct query and call stored procedure
        query = "CALL sp_DeletePlayer(%s)"
        cursor.execute(query, (playerID,))
        dbConnection.commit()

        # If successful, redirect back to page
        print(f"PlayerID: {playerID} Name: {name} deleted")
        return redirect(url_for("players", msg=f"delete_ok"))

    except Exception as e:
        print(f"Error executing queries: {e}")
        return redirect(url_for("players", error="delete_unknown"))

    finally:
        # Close the DB connection if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/players/create", methods=["POST"])
def create_player():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        athleteID = request.form["athleteID"]
        teamID = request.form["teamID"]

        # Call stored procedure to create a player
        query = "CALL sp_CreatePlayer(%s, %s, @newPlayerID)"
        playerID = cursor.execute(query, (athleteID, teamID))

        # Retrieve new player ID from out variable
        cursor.execute("SELECT @newPlayerID AS playerID")
        row = cursor.fetchone()
        playerID = row[0] if row else None

        dbConnection.commit()

        # If successful, redirect back to page
        print(f"AthleteID: {athleteID} added to TeamID: {teamID}, new playerID: {playerID}")
        return redirect(url_for("players", msg=f"create_ok"))

    except Exception as e:
        # Pass player creation error message
        print(f"Error executing queries: {e}")
        return redirect(url_for("players", error="create_unknown"))

    finally:
        # CLose the DB connection
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/games", methods=["GET"])
def games():
    try:
        dbConnection = db.connectDB()  # Open database connection

        # Retrieve scheduled games list with associated details
        query1 = ("SELECT g.gameID AS id, ht.sportType as sport_type, "
                  "ht.teamName AS home_team, at.teamName AS away_team, "
                  "s.name AS facility_location, f.facilityName AS facility_name, "
                  "g.gameDate AS game_date, g.gameTime as game_time, g.gameType as game_type, g.status "
                  "FROM Games AS g JOIN Teams AS ht ON g.homeTeamID = ht.teamID "
                  "JOIN Teams AS at ON g.awayTeamID = at.teamID "
                  "JOIN Facilities AS f ON g.facilityID = f.facilityID "
                  "JOIN Schools AS s ON s.schoolID = f.schoolID ;")
        games = db.query(dbConnection, query1).fetchall()

        # Retrieve team list with associated details
        query2 = ("SELECT teamID, schoolID, teamName, sportType, varsityJv, seasonName, academicYear "
                  "FROM Teams")
        teams = db.query(dbConnection, query2).fetchall()

        # Retrieve list of facilities
        query3 = ("SELECT facilityID, schoolID, facilityName, capacity "
                  "FROM Facilities")
        facilities = db.query(dbConnection, query3).fetchall()

        # Retrieve list of sport types
        query4 = "SELECT DISTINCT sportType FROM Teams"
        sportTypes = db.query(dbConnection, query4).fetchall()

        headers = ('Id', 'Sport', 'Home Team', 'Away Team', 'Facility Location', 'Facility Name',
                   'Game Date', 'Game Time', 'Game Type', 'Status')

        # Render games.j2 file, and send game query results
        return render_template(
            "games.j2", games=games, teams=teams, facilities=facilities,
            sportTypes=sportTypes, headers=headers
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/games/delete", methods=["POST"])
def delete_game():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        gameID = request.form["delete_gameID"]

        # Construct query and call stored procedure
        query = "CALL sp_DeleteGame(%s)"
        cursor.execute(query, (gameID,))
        dbConnection.commit()

        # If successful, redirect back to page
        print(f"GameID: {gameID} deleted")
        return redirect(url_for("games", msg="delete_ok"))

    except Exception as e:
        print(f"Error executing queries: {e}")
        return redirect(url_for("games", error="delete_unknown"))

    finally:
        # Close the DB connection if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/games/create", methods=["POST"])
def create_game():
    """
    Creates a new game
    """
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        homeTeamID = request.form["homeTeamID"]
        awayTeamID = request.form["awayTeamID"]
        facilityID = request.form["facilityID"]
        gameDate = request.form["gameDate"]
        gameTime = request.form["gameTime"]
        gameType = request.form["gameType"]
        status = request.form["status"]

        # Call stored procedure to create a player
        query = "CALL sp_CreateGame(%s, %s, %s, %s, %s, %s, %s, @gameID)"
        cursor.execute(query, (homeTeamID, awayTeamID, facilityID,
                               gameDate, gameTime, gameType, status))

        # Retrieve and store new game ID
        cursor.execute("SELECT @gameID AS gameID")
        row = cursor.fetchone()
        gameID = row[0] if row else None

        dbConnection.commit()

        # If successful, redirect back to page
        print(f"Game successfully created gameID = {gameID}")
        return redirect(url_for("games", msg=f"create_ok"))

    except Exception as e:
        # Pass game creation error message
        print(f"Error executing queries: {e}")
        return redirect(url_for("games", error="create_unknown"))

    finally:
        # Close the DB connection
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/games/update", methods=["POST"])
def update_game():
    """
    Updates a game with the provided information
    """
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        # Retrieve updated game details
        gameID = request.form["update_gameID"]
        facilityID = request.form["update_facilityID"]
        gameDate = request.form["update_gameDate"]
        gameTime = request.form["update_gameTime"]
        gameType = request.form["update_gameType"]
        status = request.form["update_gameStatus"]

        # Call update procedure
        query = "CALL sp_UpdateGame(%s, %s, %s, %s, %s, %s)"
        cursor.execute(query, (gameID, facilityID, gameDate, gameTime, gameType, status,))
        dbConnection.commit()

        print(f"Game successfully updated gameID = {gameID}")
        return redirect(url_for("games", msg=f"update_ok"))

    except Exception as e:
        print(f"Error executing queries: {e}")
        return redirect(url_for("games", error="update_unknown"))

    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/games/teams", methods=["GET"])
def games_fetch_teams():
    try:
        dbConnection = db.connectDB()
        sportType = request.args.get("sportType")
        homeTeamID = request.args.get("teamID")
        query = ("SELECT t.teamID, s.name AS 'schoolName', t.varsityJv, t.academicYear "
                 "FROM Teams as t JOIN Schools as s ON t.schoolID = s.schoolID "
                 "WHERE t.sportType = %s")

        teams_list = db.query(dbConnection, query, (sportType,)).fetchall()
        return jsonify(teams_list)

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route('/games/details', methods=["GET"])
def game_details():
    """
    Returns details of the requested gameID
    """
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        gameID = request.args.get("gameID")
        query = ("SELECT gameID, homeTeamID, awayTeamID, facilityID, gameDate, gameTime, gameType, status "
                 "FROM Games WHERE gameID = %s")
        cursor.execute(query, (gameID,))
        result = cursor.fetchone()

        if not result:
            return redirect(url_for("games", error="details_unknown"))

        game = {
            "gameID":       result[0],
            "homeTeamID":   result[1],
            "awayTeamID":   result[2],
            "facilityID":   result[3],
            "gameDate":     str(result[4]),
            "gameTime":     str(result[5]),
            "gameType":     result[6],
            "status":       result[7]
        }

        return jsonify(game)

    except Exception as e:
        # Pass detail retrieval error message
        print(f"Error retrieving game details: {e}")
        return jsonify({"error": str(e)}), 500

    finally:
        # Close the DB connection
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


# RESET DB ROUTE
@app.route("/reset-database", methods=["POST"])
def reset_database():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        # Call the stored procedure to reset the database
        query = "CALL sp_load_athleticsdb();"
        cursor.execute(query)
        
        # Consume the result set (if any) before running the next query
        cursor.nextset()  # Move to the next result set (for CALL statements)
        
        dbConnection.commit()  # commit the transaction

        print("Database reset successfully!")

        return redirect("/")
        
    except Exception as e:
        print(f"Error resetting database: {e}")
        return (f"An error occurred while resetting the database: {e}"), 500
        
    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()



# ########################################
# ########## LISTENER

if __name__ == "__main__":
    app.run(
        port=PORT, debug=True
    )
