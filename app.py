# ########################################
# ########## SETUP

from flask import Flask, render_template, request, redirect, jsonify, flash
import database.db_connector as db

# 3097 is gunicorn port
PORT = 3092 # Port to test the app on

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

        # Render the athletes.j2 file, and also send the renderer
        # a couple objects that contains athletes and schools information
        return render_template(
            "athletes.j2", athletes=athletes, schools=schools
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
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

        # Render the athletes.j2 file, and also send the renderer
        # a couple objects that contains teams and schools information
        return render_template(
            "teams.j2", teams=teams, schools=schools
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/players", methods=["GET"])
def players():
    try:
        dbConnection = db.connectDB()  # Open our database connection

        # Retrieve list of Players with their Athlete / Team / School info
        query1 = ("SELECT p.playerID AS 'id', a.firstName AS 'first_name', a.lastName AS 'last_name', "
                  "s.name AS 'school', t.sportType AS 'sport', t.varsityJv AS 'varsity_/_JV', "
                  "t.academicYear AS 'academic_year', IF(a.isEligible, '✓', '✗') AS 'Eligible', "
                  "IF(a.isActive, '✓', '✗') AS 'Active' "
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

        # Render schools.j2 file, and send school query results
        return render_template(
            "players.j2", players=players, athletes=athletes, teams=teams
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
    try:
        dbConnection = db.connectDB()
        teamID = request.args.get("teamID")
        query1 = ("SELECT p.playerID AS 'id', a.firstName AS 'first_name', a.lastName AS 'last_name', "
                  "s.name AS 'school', t.sportType AS 'sport', t.varsityJv AS 'varsity_/_JV', "
                  "t.academicYear AS 'academic_year', IF(a.isEligible, 'Yes', 'No') AS 'eligible', "
                  "IF(a.isActive, 'Yes', 'No') AS 'active' "
                  "FROM Players AS p JOIN Athletes AS a ON p.athleteID = a.athleteID "
                  "JOIN Teams AS t ON p.teamID = t.teamID "
                  "JOIN Schools AS s ON s.schoolID = a.schoolID ")
        if teamID:
            query1 += f"WHERE t.teamID = {teamID};"
        roster = db.query(dbConnection, query1).fetchall()
        return jsonify(roster)

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


@app.route("/games", methods=["GET"])
def games():
    try:
        dbConnection = db.connectDB()  # Open our database connection

        # Retrieve scheduled games list with associated details
        query1 = ("SELECT g.gameID AS id, "
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

        # Render games.j2 file, and send game query results
        return render_template(
            "games.j2", games=games, teams=teams, facilities=facilities, sportTypes=sportTypes
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
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
        return redirect("/athletes")

    except Exception as e:
        dbConnection.rollback()
        error_message = str(e)
        print(f"Error executing queries: {error_message}")
        
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
        return redirect("/teams")

    except Exception as e:
        dbConnection.rollback()
        error_message = str(e)
        print(f"Error executing queries: {error_message}")
        
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



# ########################################
# ########## LISTENER

if __name__ == "__main__":
    app.run(
        port=PORT, debug=True
    )
