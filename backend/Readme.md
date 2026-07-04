# ASD Screening Backend (FastAPI + Random Forest)

**Python 3.10 only.** The model (`asd_risk_rf_model.joblib`) was trained with
Python 3.10 and scikit-learn 1.7.2 in `../ml/`. The backend must use the same
versions or predictions may be wrong.

## Setup (one time)

```bash
cd backend
py -3.10 -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

## Run

```bash
# Windows — uses .venv Python 3.10 automatically
run.bat

# or manually
.venv\Scripts\activate
python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

Do **not** run with system Python 3.12/3.13 — `main.py` will refuse to start.

## Retrain / refresh model

From the `ml/` folder (also Python 3.10):

```bash
cd ml
.venv\Scripts\activate
python build_notebook.py
copy asd_risk_rf_model.joblib ..\backend\
```

## Endpoint

`POST /predict`

```json
{
  "answers": [0, 1, 2, ...],
  "age": 7,
  "gender": "Male",
  "relationship": "Parent"
}
```

| Total score (max 120) | Risk level |
|---|---|
| 0–30 | low |
| 31–70 | moderate |
| 71+ | high |
