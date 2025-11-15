from flask import Flask, render_template, request, redirect, url_for, session, flash
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
import os

app = Flask(__name__)
app.secret_key = 'secret'

# SQLite local database setup
DB_FILE = os.getenv("SQLITE_DB_FILE", "movie_rental.db")
DB_URL = f"sqlite:///{DB_FILE}"
engine = create_engine(DB_URL, future=True)

def init_db():
    schema = [
        '''
        CREATE TABLE IF NOT EXISTS customer (
            customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
            Full_Name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            phone TEXT UNIQUE,
            status TEXT DEFAULT 'Active'
        )
        ''',
        '''
        CREATE TABLE IF NOT EXISTS staff (
            staff_id INTEGER PRIMARY KEY AUTOINCREMENT,
            full_name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL,
            hire_date TEXT,
            branch_code TEXT
        )
        ''',
        '''
        CREATE TABLE IF NOT EXISTS category (
            code TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            parent_code TEXT
        )
        ''',
        '''
        CREATE TABLE IF NOT EXISTS branch (
            branch_code TEXT PRIMARY KEY,
            name TEXT NOT NULL
        )
        ''',
        '''
        CREATE TABLE IF NOT EXISTS equipment (
            equip_id INTEGER PRIMARY KEY AUTOINCREMENT,
            Name TEXT NOT NULL,
            brand TEXT,
            model TEXT,
            daily_rate REAL,
            deposit REAL,
            status TEXT,
            category_code TEXT,
            FOREIGN KEY (category_code) REFERENCES category(code)
        )
        ''',
        '''
        CREATE TABLE IF NOT EXISTS equip_copy (
            equip_id INTEGER,
            copy_no INTEGER,
            equip_code TEXT PRIMARY KEY,
            branch_code TEXT,
            condition TEXT,
            purchase_date TEXT,
            serial_number TEXT UNIQUE,
            FOREIGN KEY (equip_id) REFERENCES equipment(equip_id),
            FOREIGN KEY (branch_code) REFERENCES branch(branch_code)
        )
        ''',
        '''
        CREATE TABLE IF NOT EXISTS reservation (
            reservation_id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER,
            equip_id INTEGER,
            status TEXT DEFAULT 'Pending',
            start_date TEXT,
            end_date TEXT,
            FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
            FOREIGN KEY (equip_id) REFERENCES equipment(equip_id)
        )
        '''
    ]
    with engine.begin() as conn:
        for stmt in schema:
            conn.execute(text(stmt))

# Initialize DB and tables
init_db()

def get_conn():
    return engine.connect()

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        password = request.form['password']
        phone = request.form['phone']
        with get_conn() as conn:
            existing_email = conn.execute(text("SELECT 1 FROM customer WHERE email=:email"), {"email": email}).scalar()
            existing_phone = conn.execute(text("SELECT 1 FROM customer WHERE phone=:phone"), {"phone": phone}).scalar() if phone else False
            if existing_email:
                flash('Email already exists!')
            elif phone and existing_phone:
                flash('Phone number already exists!')
            else:
                try:
                    conn.execute(
                        text("INSERT INTO customer (Full_Name, email, password, phone, status) VALUES (:name, :email, :password, :phone, 'Active')"),
                        {"name": name, "email": email, "password": password, "phone": phone or None}
                    )
                    conn.commit()
                    flash('Account created! Please log in.')
                    return redirect(url_for('login_customer'))
                except SQLAlchemyError:
                    flash('Signup failed. Try again.')
    return render_template('signup.html')

@app.route('/login/customer', methods=['GET', 'POST'])
def login_customer():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        try:
            with get_conn() as conn:
                r = conn.execute(
                    text("SELECT customer_id, Full_Name, status FROM customer WHERE email=:email AND password=:password"),
                    {"email": email, "password": password}
                ).fetchone()
                if r and r.status == 'Active':
                    session['user'] = r.customer_id
                    session['role'] = 'customer'
                    session['user_name'] = r.Full_Name
                    flash('Welcome, ' + r.Full_Name)
                    return redirect(url_for('customer_dashboard'))
                else:
                    flash('Invalid credentials or account is not active.')
        except SQLAlchemyError:
            flash("Login error (check db connection and credentials).")
    return render_template('login_customer.html')

@app.route('/login/employee', methods=['GET', 'POST'])
def login_employee():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        try:
            with get_conn() as conn:
                r = conn.execute(
                    text("SELECT staff_id, full_name, role FROM staff WHERE email=:email AND password=:password"),
                    {"email": email, "password": password}
                ).fetchone()
                if r:
                    session['user'] = r.staff_id
                    session['role'] = r.role
                    session['user_name'] = r.full_name
                    flash('Welcome, ' + r.full_name)
                    return redirect(url_for('employee_dashboard'))
                else:
                    flash('Invalid credentials.')
        except SQLAlchemyError:
            flash("Login error (check db connection and credentials).")
    return render_template('login_employee.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('Logged out.')
    return redirect(url_for('home'))

@app.route('/customer')
def customer_dashboard():
    if session.get('role') != 'customer':
        return redirect(url_for('login_customer'))
    return render_template('customer_dashboard.html', name=session.get('user_name','Customer'))

@app.route('/employee')
def employee_dashboard():
    if not session.get('role') or session.get('role') not in ['Clerk', 'Manager', 'Tech']:
        return redirect(url_for('login_employee'))
    return render_template('employee_dashboard.html', role=session['role'], name=session.get('user_name','Employee'))

@app.route('/reservations', methods=['GET', 'POST'])
def make_reservation():
    if session.get('role') != 'customer':
        return redirect(url_for('login_customer'))
    with get_conn() as conn:
        categories = conn.execute(text("SELECT code, name FROM category")).fetchall()
        if request.method == 'POST':
            equip_id = request.form['equip_id']
            start = request.form['start']
            end = request.form['end']
            customer_id = session['user']
            try:
                conn.execute(
                    text("INSERT INTO reservation (customer_id, equip_id, status, start_date, end_date) VALUES (:cid, :eid, 'Pending', :start, :end)"),
                    {"cid": customer_id, "eid": equip_id, "start": start, "end": end}
                )
                conn.commit()
                flash('Reservation requested!')
            except SQLAlchemyError:
                flash('Reservation failed.')
        equip = conn.execute(
            text("SELECT equip_id, Name, brand, model FROM equipment WHERE status='Active'")
        ).fetchall()
        return render_template('reservations.html', equip=equip, categories=categories)

@app.route('/available')
def available_equipment():
    with get_conn() as conn:
        equip = conn.execute(
            text("SELECT e.equip_id, e.Name, e.brand, e.model, e.daily_rate, c.name AS category FROM equipment e JOIN category c ON c.code = e.category_code WHERE e.status='Active'")
        ).fetchall()
        return render_template('available.html', equip=equip)

@app.route('/employee/available')
def employee_available_equipment():
    if not session.get('user') or session.get('role') not in ['Clerk', 'Manager', 'Tech']:
        return redirect(url_for('login_employee'))
    staff_id = session['user']
    with get_conn() as conn:
        branch = conn.execute(
            text("SELECT branch_code FROM staff WHERE staff_id=:sid"),
            {"sid": staff_id}
        ).scalar()
        equip = conn.execute(
            text("""SELECT e.equip_id, e.Name, e.brand, e.model, e.daily_rate, b.name AS branch
                    FROM equipment e
                    JOIN equip_copy ec ON ec.equip_id = e.equip_id
                    JOIN branch b ON ec.branch_code = b.branch_code
                    WHERE e.status='Active' AND ec.branch_code=:branch
                """),
            {"branch": branch}
        ).fetchall()
        return render_template('employee_available.html', equip=equip, branch=branch)

if __name__ == "__main__":
    app.run(debug=True)
