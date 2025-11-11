# ########################################
# ########## SETUP

from flask import Flask, render_template, request, redirect, jsonify
import database.db_connector as db

PORT = 3097

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
        query = ("SELECT schoolID AS 'ID', name AS 'Name', address AS 'Address', phone AS 'Phone' "
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
        query1 = "SELECT Facilities.facilityID, Schools.name as 'school', \
            Facilities.facilityName, Facilities.capacity FROM Facilities \
            LEFT JOIN Schools ON Facilities.schoolID = Schools.schoolID;"
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
        query1 = "SELECT Athletes.athleteID, Schools.name as 'school', \
            Athletes.firstName, Athletes.lastName, Athletes.gradeLevel, \
            Athletes.isEligible, Athletes.isActive, Athletes.emergencyContact FROM Athletes \
            LEFT JOIN Schools ON Athletes.schoolID = Schools.schoolID;"
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
        query1 = "SELECT Teams.teamID, Schools.name as 'school', \
            Teams.teamName, Teams.sportType, Teams.varsityJv, \
            Teams.seasonName, Teams.academicYear FROM Teams \
            LEFT JOIN Schools ON Teams.schoolID = Schools.schoolID;"
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
        query1 = ("SELECT p.playerID AS 'player_id', a.firstName AS 'first_name', a.lastName AS 'last_name', "
                  "s.name AS 'school', t.sportType AS 'sport', t.varsityJv AS 'varsity_/_JV', "
                  "t.academicYear AS 'academic_year', IF(a.isEligible, 'Yes', 'No') AS 'is_eligible', "
                  "IF(a.isActive, 'Yes', 'No') AS 'is_active' "
                  "FROM Players AS p JOIN Athletes AS a ON p.athleteID = a.athleteID "
                  "JOIN Teams AS t ON p.teamID = t.teamID "
                  "JOIN Schools AS s ON s.schoolID = a.schoolID ;")
        players = db.query(dbConnection, query1).fetchall()

        query2 = ("SELECT a.athleteID, a.firstName, a.lastName, s.schoolID, s.name AS 'schoolName' "
                  "FROM Athletes as a "
                  "JOIN Schools as s ON s.schoolID = a.schoolID ")
        athletes = db.query(dbConnection, query2).fetchall()

        # Render schools.j2 file, and send school query results
        return render_template(
            "players.j2", players=players, athletes=athletes
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


@app.route("/games", methods=["GET"])
def games():
    try:
        dbConnection = db.connectDB()  # Open our database connection

        # Retrieve scheduled games list with associated details
        query1 = ("SELECT g.gameID, "
                  "ht.teamName AS homeTeamName, at.teamName AS awayTeamName, "
                  "s.name AS facilitySchool, f.facilityName, "
                  "g.gameDate, g.gameTime, g.gameType, g.status "
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

        # Render games.j2 file, and send game query results
        return render_template(
            "games.j2", games=games, teams=teams, facilities=facilities
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

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