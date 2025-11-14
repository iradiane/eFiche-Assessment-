
CREATE SCHEMA dwh;

-- Dim Date
CREATE TABLE dwh.dim_date (
    date_key SERIAL PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    quarter INTEGER,
    month_name TEXT,
    day_of_week TEXT,
    is_weekend BOOLEAN
);

-- Dim Patient (SCD2 ready)
CREATE TABLE dwh.dim_patient (
    patient_key SERIAL PRIMARY KEY,
    patient_id TEXT UNIQUE NOT NULL,        
    age INTEGER,
    sex CHAR(1),
    location TEXT,
    valid_from TIMESTAMP DEFAULT NOW(),
    valid_to TIMESTAMP DEFAULT 'infinity',
    is_current BOOLEAN DEFAULT TRUE
);

-- Dim Procedure
CREATE TABLE dwh.dim_procedure (
    procedure_key SERIAL PRIMARY KEY,
    procedure_id TEXT UNIQUE NOT NULL,      
    procedure_name TEXT,
    modality TEXT,
    projection TEXT
);

-- Dim Diagnosis
CREATE TABLE dwh.dim_diagnosis (
    diagnosis_key SERIAL PRIMARY KEY,
    diagnosis_id INTEGER UNIQUE,            
    code TEXT,
    description TEXT
);

-- Fact Encounter
CREATE TABLE dwh.fact_encounter (
    encounter_key SERIAL PRIMARY KEY,
    encounter_id TEXT UNIQUE NOT NULL,      
    patient_key INTEGER REFERENCES dwh.dim_patient(patient_key),
    procedure_key INTEGER REFERENCES dwh.dim_procedure(procedure_key),
    diagnosis_key INTEGER REFERENCES dwh.dim_diagnosis(diagnosis_key),
    date_key INTEGER REFERENCES dwh.dim_date(date_key),
    report_text TEXT,
    report_language TEXT,
    ingested_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_fact_patient ON dwh.fact_encounter(patient_key);
CREATE INDEX idx_fact_date ON dwh.fact_encounter(date_key);
CREATE INDEX idx_fact_diagnosis ON dwh.fact_encounter(diagnosis_key);