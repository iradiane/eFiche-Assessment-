# eFiche Senior Data Engineer Assessment  
**Clinical Data Platform | 10,000+ PadChest Studies | Full DWH + Interactive Dashboard**

---
## Part 1: Data Modeling & Synthetic Data Generation

### Schema Design
- **Entities**: `patients`, `encounters`, `procedures`, `diagnoses`, `reports`  
- **Keys**: `TEXT` natural keys (e.g., `encounter_id`, `report_id`)  
- **Constraints**: Foreign keys, `NOT NULL`, referential integrity  
- **Indexes**: `GIN` on text fields, `BTREE` on `patient_id`, `encounter_date`  
- **Future-Proof**: `VECTOR(384)` column in `reports` for audio/text embeddings

### Synthetic Data
- **5,000 realistic patients** (age, sex, location distributions)  
- **~15,000 encounters**, **~30,000 procedures**  
- Generated via `eFiche_Assessment_code.ipynb`



## Part 2: Data Pipeline (Continuous Ingestion)

### Pipeline Overview

### Requirements Met
1. **Pulls data periodically** (every 60s simulation)  
2. **Parses new rows** (skip previously processed)  
3. **Transforms fields** to match schema  
4. **Randomly matches** to existing patient  
5. **Handles duplicates** (`ON CONFLICT DO NOTHING/UPDATE`)

### Key Features
- **Stateful**: `pipeline_state.json` tracks `last_row`  
- **Idempotent**: Safe reruns  
- **Random patient assignment** preserves anonymity

## Part 3: Data Warehouse & Analytics Layer

### Star Schema Design

### Required Metrics
| Metric | Result |
|-------|--------|
| **Encounters per month** | **March: 852** (peak) |
| **Frequent diagnoses by age** | **55+: normal (949)** |
| **Avg studies per patient** | **1.82** |
| **Top diagnosis clusters** | **normal (849), pneumonia, edema** |

## Bonus: Interactive Clinical Dashboard

---

## How to Run (100% Reproducible)

```bash
# 1. Start PostgreSQL
docker run -d --name pg -e POSTGRES_PASSWORD=didi20189@ -p 5432:5432 postgres

# 2. Create DB
psql -U postgres -c "CREATE DATABASE Efiche_assessment1;"

# 3. Load ODS
psql -U postgres -d Efiche_assessment1 -f 01_schema.sql

# 4. Generate patients
python 02_synthetic_patients.py

# 5. Run pipeline
python part2_pipeline.py

# 6. Load DWH
psql -U postgres -d Efiche_assessment1 -f 03_dwh_schema.sql
psql -U postgres -d Efiche_assessment1 -f part3_etl.py

# 7. Run analytics
psql -U postgres -d Efiche_assessment1 -f 04_analytics.sql

# 8. Launch dashboard
python dashboard.py

- **Built with Python + Plotly**  
- **KPIs at top**: Total encounters, patients, avg studies  
- **4 required charts** + bonus text clustering  
- **Fully interactive**: hover, zoom, export  
- **Self-contained HTML** — no dependencies

**Open `interactive dashboard.html` in any browser**
