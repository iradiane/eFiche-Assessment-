-- ===================================================
-- eFiche Assessment – Part 1: Data Model 
-- ===================================================

-- Patients: one patient → many encounters
CREATE TABLE patients (
    patient_id TEXT PRIMARY KEY,           
    age INTEGER CHECK (age >= 0 AND age <= 130),
    sex CHAR(1) CHECK (sex IN ('M', 'F')),
    location TEXT
);

-- Encounters (visits/studies)
CREATE TABLE encounters (
    encounter_id TEXT PRIMARY KEY,         
    patient_id TEXT NOT NULL REFERENCES patients(patient_id),
    facility_id TEXT,
    encounter_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedures (images performed during encounter)
CREATE TABLE procedures (
    procedure_id TEXT PRIMARY KEY,         
    encounter_id TEXT NOT NULL REFERENCES encounters(encounter_id),
    procedure_name TEXT DEFAULT 'Chest X-Ray',
    modality TEXT,                         
    projection TEXT                      
);

-- Diagnoses master table
CREATE TABLE diagnoses (
    diagnosis_id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,             
    description TEXT
);

-- Reports (free-text radiology reports)
CREATE TABLE reports (
    report_id TEXT PRIMARY KEY,            
    encounter_id TEXT NOT NULL REFERENCES encounters(encounter_id),
    text TEXT,                            
    language TEXT DEFAULT 'es',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Junction: many-to-many encounter ↔ diagnosis
CREATE TABLE encounter_diagnoses (
    encounter_id TEXT REFERENCES encounters(encounter_id),
    diagnosis_id INTEGER REFERENCES diagnoses(diagnosis_id),
    severity TEXT,                       
    PRIMARY KEY (encounter_id, diagnosis_id)
);

-- Indexes for performance & scalability
CREATE INDEX idx_encounters_patient_id ON encounters(patient_id);
CREATE INDEX idx_encounters_date ON encounters(encounter_date);
CREATE INDEX idx_procedures_encounter ON procedures(encounter_id);
CREATE INDEX idx_reports_text ON reports USING GIN (to_tsvector('english', text));
CREATE INDEX idx_reports_text_es ON reports USING GIN (to_tsvector('spanish', text));