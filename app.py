# ########################################
# ########## SETUP

from flask import Flask, render_template, request, redirect
import database.db_connector as db

PORT = 65519

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


@app.route("/players", methods=["GET"])
def players():
    try:
        dbConnection = db.connectDB()  # Open our database connection

        # Retrieve list of Players with their Athlete / Team / School info
        query1 = ("SELECT p.playerID, a.firstName, a.lastName, "
                 "s.name AS schoolName, t.sportType, t.varsityJv, "
                 "t.academicYear, a.isEligible, a.isActive "
                 "FROM Players AS p JOIN Athletes AS a ON p.athleteID = a.athleteID "
                 "JOIN Teams AS t ON p.teamID = t.teamID "
                 "JOIN Schools AS s ON s.schoolID = a.schoolID ;")
        players = db.query(dbConnection, query1).fetchall()

        # Render schools.j2 file, and send school query results
        return render_template(
            "players.j2", players=players
        )

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
    )  # debug is an optional parameter. Behaves like nodemon in Node.
