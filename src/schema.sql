.open fittrackpro.db
.mode column

DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS class_schedule;
DROP TABLE IF EXISTS memberships;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS class_attendance;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS personal_training_sessions;
DROP TABLE IF EXISTS member_health_metrics;
DROP TABLE IF EXISTS equipment_maintenance_logs;


PRAGMA foreign_keys = ON;

-- locations table
CREATE TABLE locations (
    location_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone_number TEXT NOT NULL
        CHECK (phone_number GLOB "0[0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9][0-9]"
            OR phone_number GLOB "0[0-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9][0-9]"
            OR phone_number GLOB "0[0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9][0-9][0-9]"),
    email TEXT NOT NULL
        CHECK (email LIKE "%@%.%"),
    opening_hours TEXT NOT NULL
        CHECK (opening_hours GLOB "[0-2][0-9]:[0-5][0-9]-[0-2][0-9]:[0-5][0-9]")
);

-- members table
CREATE TABLE members (
    member_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL
        CHECK (email LIKE "%@%.%"),
    phone_number TEXT NOT NULL
        CHECK (phone_number GLOB "0[0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9][0-9][0-9]"),
    date_of_birth DATE NOT NULL
        CHECK (date_of_birth = date(date_of_birth)),
    join_date DATE NOT NULL
        CHECK (join_date = date(join_date)),
    emergency_contact_name TEXT NOT NULL,
    emergency_contact_phone TEXT NOT NULL
        CHECK (emergency_contact_phone GLOB "0[0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9][0-9][0-9]")
);

-- staff table
CREATE TABLE staff (
    staff_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL
        CHECK (email LIKE "%@%.%"),
    phone_number TEXT NOT NULL
        CHECK (phone_number GLOB "0[0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9][0-9][0-9]"),
    position TEXT NOT NULL
        CHECK (position IN ("Trainer", "Manager", "Receptionist", "Maintenance")),
    hire_date DATE NOT NULL
        CHECK (hire_date = date(hire_date)),
    location_id INTEGER NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE
);

-- equipment table
CREATE TABLE equipment (
    equipment_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL
        CHECK (type IN ("Cardio", "Strength")),
    purchase_date DATE NOT NULL
        CHECK (purchase_date = date(purchase_date)),
    last_maintenance_date DATE NOT NULL
        CHECK (last_maintenance_date = date(last_maintenance_date)),
    next_maintenance_date DATE NOT NULL
        CHECK (next_maintenance_date = date(next_maintenance_date)),
    location_id INTEGER NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE
);

-- classes table
CREATE TABLE classes (
    class_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    capacity INTEGER NOT NULL
        CHECK (capacity > 0),
    duration INTEGER NOT NULL
        CHECK (duration > 0),
    location_id INTEGER NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE
);

-- class_schedule table
CREATE TABLE class_schedule (
    schedule_id INTEGER PRIMARY KEY,
    class_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    start_time DATETIME NOT NULL
        CHECK (start_time = datetime(start_time)),
    end_time DATETIME NOT NULL
        CHECK (end_time = datetime(end_time)),
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE,
    CHECK (end_time > start_time)
);

-- memberships table
CREATE TABLE memberships (
    membership_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    type TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status TEXT NOT NULL
        CHECK (status IN ("Active", "Inactive")),
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    CHECK (end_date > start_date)
);

-- attendance table
CREATE TABLE attendance (
    attendance_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    check_in_time DATETIME NOT NULL
        CHECK (check_in_time = datetime(check_in_time)),
    check_out_time DATETIME
        CHECK (check_out_time = datetime(check_out_time)),
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE,
    CHECK (check_out_time > check_in_time)
);

-- class_attendance table
CREATE TABLE class_attendance (
    class_attendance_id INTEGER PRIMARY KEY,
    schedule_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    attendance_status TEXT NOT NULL
        CHECK (attendance_status IN ("Registered", "Attended", "Unattended")),
    FOREIGN KEY (schedule_id) REFERENCES class_schedule(schedule_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- payments table
CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    amount REAL NOT NULL
        CHECK (amount >= 0),
    payment_date DATETIME NOT NULL
        CHECK (payment_date = datetime(payment_date)),
    payment_method TEXT NOT NULL
        CHECK (payment_method IN ("Credit Card", "Bank Transfer", "PayPal", "Cash")),
    payment_type TEXT NOT NULL
        CHECK (payment_type IN ("Monthly membership fee", "Day pass")),
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- personal_training_sessions table
CREATE TABLE personal_training_sessions (
    session_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    session_date DATE NOT NULL
        CHECK (session_date = date(session_date)),
    start_time TEXT NOT NULL
        CHECK (start_time GLOB "[0-2][0-9]:[0-5][0-9]:[0-5][0-9]"),
    end_time TEXT NOT NULL
        CHECK (end_time GLOB "[0-2][0-9]:[0-5][0-9]:[0-5][0-9]"),
    notes TEXT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE,
    CHECK (end_time > start_time)
);

-- member_health_metrics table
CREATE TABLE member_health_metrics (
    metric_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    measurement_date DATE NOT NULL
        CHECK (measurement_date = date(measurement_date)),
    weight REAL NOT NULL
        CHECK (weight > 0),
    body_fat_percentage REAL NOT NULL
        CHECK (body_fat_percentage >= 0 AND body_fat_percentage <= 100),
    muscle_mass REAL NOT NULL
        CHECK (muscle_mass >= 0),
    bmi REAL NOT NULL
        CHECK (bmi > 0),
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- equipment_maintenance_log table
CREATE TABLE equipment_maintenance_log (
    log_id INTEGER PRIMARY KEY,
    equipment_id INTEGER NOT NULL,
    maintenance_date DATE NOT NULL
        CHECK (maintenance_date = date(maintenance_date)),
    description TEXT NOT NULL,
    staff_id INTEGER NOT NULL,
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE
);
