# ########################################
# ########## SETUP

from flask import Flask, render_template, request, redirect
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



# ########################################
# ########## LISTENER

if __name__ == "__main__":
    app.run(
        port=PORT, debug=True
    )