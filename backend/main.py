"""FastAPI backend serving the ASD screening Random Forest model.

Requires Python 3.10 and scikit-learn 1.7.2 (see backend/requirements.txt).
Run with:  backend/.venv/Scripts/python -m uvicorn main:app --host 0.0.0.0 --port 8000
"""
import sys
from pathlib import Path
from typing import List, Optional

import joblib
import numpy as np
import pandas as pd
import sklearn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

# ---------------------------------------------------------------------------
# Runtime checks — model was trained on Python 3.10 + scikit-learn 1.7.2
# ---------------------------------------------------------------------------
if sys.version_info[:2] != (3, 10):
    raise RuntimeError(
        f"This backend must run on Python 3.10 (use backend/.venv). "
        f"Current interpreter: {sys.version.split()[0]}"
    )

if not sklearn.__version__.startswith("1.7."):
    raise RuntimeError(
        f"Incompatible scikit-learn {sklearn.__version__}. "
        f"Install requirements.txt (expected 1.7.x)."
    )

app = FastAPI(title="ASD Screening API", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Load model artifact (trained in ml/.venv, Python 3.10, sklearn 1.7.2)
# ---------------------------------------------------------------------------
_MODEL_NAME = "asd_risk_rf_model.joblib"
_CANDIDATES = [
    Path(__file__).parent / _MODEL_NAME,
    Path(__file__).parent.parent / "ml" / _MODEL_NAME,
]

_artifact = None
for _path in _CANDIDATES:
    if _path.exists():
        _artifact = joblib.load(_path)
        print(f"Loaded model from {_path}")
        break

if _artifact is None:
    raise RuntimeError(
        f"Could not find {_MODEL_NAME}. Train it first (see ml/asd_random_forest.ipynb)."
    )

MODEL = _artifact["model"]
IMPUTER = _artifact["imputer"]
FEATURES: List[str] = _artifact["features"]
ITEM_COLS: List[str] = _artifact["item_cols"]
CLASSES = list(_artifact.get("classes", getattr(MODEL, "classes_", [])))
MAX_SCORE = 120

# Plain median array — backup if imputer ever fails; also documents fill values.
IMPUTER_MEDIANS = np.asarray(
    _artifact.get("imputer_medians", IMPUTER.statistics_), dtype=float
)

RISK_BANDS = [(30, "low"), (70, "moderate"), (MAX_SCORE, "high")]

SUMMARIES = {
    "low": "Your child is displaying typical developmental patterns for their age group.",
    "moderate": "Your child's responses suggest some behavioral patterns that may be "
                "associated with Autism Spectrum Disorder.",
    "high": "Your child's responses suggest several behavioral patterns associated with "
            "Autism Spectrum Disorder.",
}


def risk_level_from_score(total: int) -> str:
    for upper, label in RISK_BANDS:
        if total <= upper:
            return label
    return "high"


class ScreeningRequest(BaseModel):
    answers: List[int] = Field(..., min_length=30, max_length=30)
    age: Optional[int] = None
    gender: Optional[str] = None
    relationship: Optional[str] = None
    include_shap: bool = False


def build_feature_row(req: ScreeningRequest) -> pd.DataFrame:
    """Build one feature row in the same column order used during training."""
    row = {feat: np.nan for feat in FEATURES}

    for col, value in zip(ITEM_COLS, req.answers):
        row[col] = value

    if "Age (Years)" in row and req.age is not None:
        row["Age (Years)"] = req.age

    if "Gender" in row and req.gender:
        row["Gender"] = 1.0 if req.gender.strip().lower().startswith("m") else 0.0

    rel_cols = [f for f in FEATURES if f.startswith("Relationship to Child_")]
    if rel_cols:
        for c in rel_cols:
            row[c] = 0.0
        rel = (req.relationship or "").strip().lower()
        match = {
            "parent": "Relationship to Child_Parent",
            "caregiver": "Relationship to Child_Caregiver",
            "other": "Relationship to Child_Other",
        }.get(rel)
        if match is None or match not in rel_cols:
            match = next((c for c in rel_cols if c.endswith("_nan")), None)
        if match:
            row[match] = 1.0

    return pd.DataFrame([row], columns=FEATURES)


def impute_features(df: pd.DataFrame) -> pd.DataFrame:
    """Apply the same median imputation used when the model was trained."""
    try:
        imputed = IMPUTER.transform(df)
    except Exception:
        # Fallback using stored medians (should not happen on Python 3.10 + sklearn 1.7.2)
        arr = df.to_numpy(dtype=float, copy=True)
        nan_mask = np.isnan(arr)
        if nan_mask.any():
            arr[nan_mask] = IMPUTER_MEDIANS[nan_mask]
        imputed = arr
    return pd.DataFrame(imputed, columns=FEATURES)


def _underlying_rf():
    """Return the RandomForest estimator (unwraps imblearn Pipeline if needed)."""
    if hasattr(MODEL, "named_steps"):
        return MODEL.named_steps["rf"]
    return MODEL


def _shap_for_request(req: ScreeningRequest) -> dict:
    """Compute SHAP values for the predicted class using TreeExplainer."""
    import shap  # lazy import — keeps startup fast if SHAP is unused

    X = impute_features(build_feature_row(req))
    rf = _underlying_rf()
    predicted = str(rf.predict(X)[0])
    class_names = [str(c) for c in rf.classes_]
    class_idx = class_names.index(predicted)

    explainer = shap.TreeExplainer(rf)
    shap_values = explainer.shap_values(X)

    if isinstance(shap_values, list):
        sv = shap_values[class_idx][0]
    else:
        sv = shap_values[0, :, class_idx]

    features = []
    for i, col in enumerate(ITEM_COLS):
        val = float(sv[FEATURES.index(col)])
        features.append({
            "feature": col,
            "question_index": i,
            "answer": req.answers[i],
            "shap_value": round(val, 4),
            "impact": round(abs(val), 4),
        })

    features.sort(key=lambda x: x["impact"], reverse=True)
    return {
        "predicted_class": predicted,
        "top_features": features[:15],
    }


@app.get("/")
def root():
    return {
        "status": "ok",
        "model": "asd_risk_random_forest",
        "python": sys.version.split()[0],
        "sklearn": sklearn.__version__,
        "classes": CLASSES,
    }


@app.get("/health")
def health():
    return {"status": "healthy", "features": len(FEATURES)}


@app.post("/predict")
def predict(req: ScreeningRequest):
    if any(a < 0 or a > 4 for a in req.answers):
        raise HTTPException(status_code=422, detail="Each answer must be between 0 and 4.")

    total_score = int(sum(req.answers))
    risk_level = risk_level_from_score(total_score)
    concern_percent = round(total_score / MAX_SCORE * 100)

    X = impute_features(build_feature_row(req))
    model_prediction = str(MODEL.predict(X)[0])

    probabilities = {}
    confidence = None
    if hasattr(MODEL, "predict_proba"):
        proba = MODEL.predict_proba(X)[0]
        probabilities = {str(c): round(float(p), 4) for c, p in zip(CLASSES, proba)}
        confidence = round(float(max(proba)), 4)

    response = {
        "risk_level": risk_level,
        "concern_percent": concern_percent,
        "total_score": total_score,
        "max_score": MAX_SCORE,
        "summary": SUMMARIES[risk_level],
        "model_prediction": model_prediction,
        "confidence": confidence,
        "probabilities": probabilities,
    }
    if req.include_shap:
        try:
            response["shap"] = _shap_for_request(req)
        except Exception as exc:
            response["shap_error"] = str(exc)
    return response


@app.post("/explain")
def explain(req: ScreeningRequest):
    """SHAP-based feature importance for clinical review."""
    if any(a < 0 or a > 4 for a in req.answers):
        raise HTTPException(status_code=422, detail="Each answer must be between 0 and 4.")
    return _shap_for_request(req)
