
import pandas as pd
import numpy as np
import joblib
import lightgbm as lgb
from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional
from sklearn.preprocessing import StandardScaler

app = FastAPI(title="Mexican Bank ML API")

# ── Load models ONCE at startup ───────────────────────────────────────────────
print("Loading models...")
cluster_models  = joblib.load('models/mx_cluster_models.pkl')
feature_cols    = joblib.load('models/mx_feature_cols.pkl')
classifier      = joblib.load('models/mx_transaction_classifier.pkl')
classifier_cols = joblib.load('models/mx_classifier_cols.pkl')
kmeans          = joblib.load('models/mx_kmeans.pkl')
scaler          = joblib.load('models/mx_scaler.pkl')
print("Models loaded!")

# ── Request schemas ───────────────────────────────────────────────────────────
class UserProfile(BaseModel):
    cc_num:           int
    income_range:     int        # 0-3
    is_parent:        int        # 0 or 1
    has_partner:      int
    is_student:       int
    has_budget:       int
    spending_style_enc:   int
    financial_goal_enc:   int
    life_stage_enc:       int
    volatility:       float
    avg_monthly_spend: float
    # last month stats
    lag_1:            float
    lag_2:            float
    lag_3:            float
    rolling_3m:       float
    month:            int        # next month to forecast

class Transaction(BaseModel):
    cc_num:           int
    amt:              float
    category:         str
    hour:             int
    dayofweek:        int
    month:            int
    is_weekend:       int
    is_night:         int
    # calendar flags
    is_regreso_clases: int
    is_decembrina:    int
    is_semana_santa:  int
    is_cuesta_enero:  int
    is_dia_madres:    int
    is_buen_fin:      int
    is_verano:        int
    # user context
    income_range:     int
    life_stage_enc:   int
    is_parent:        int
    has_partner:      int
    is_student:       int
    spending_style_enc: int
    has_budget:       int
    financial_goal_enc: int
    avg_monthly_spend: float
    volatility:       float
    # user stats for this category
    cat_mean:         float
    cat_median:       float
    cat_freq:         int
    z_score:          float
    pct_of_monthly:   float
    is_essential:     int
    is_discretionary: int
    is_impulsive_cat: int

# ── Endpoint 1: Assign user to cluster ───────────────────────────────────────
@app.post("/user/cluster")
def get_user_cluster(profile: UserProfile):
    cluster_features = ['avg_monthly_spend', 'volatility',
                        'income_range', 'is_parent',
                        'has_partner', 'is_student', 'life_stage_enc']
    
    X = np.array([[getattr(profile, f) for f in cluster_features]])
    X_scaled = scaler.transform(X)
    cluster  = int(kmeans.predict(X_scaled)[0])
    
    cluster_labels = {
        0: 'familia_cuidadosa',
        1: 'pareja_sin_hijos',
        2: 'ejecutivo',
        3: 'estudiante',
        4: 'medio_cuidadoso',
        5: 'familia_equilibrada'
    }
    
    return {
        "cc_num":        profile.cc_num,
        "cluster":       cluster,
        "cluster_label": cluster_labels.get(cluster, f"cluster_{cluster}")
    }

# ── Endpoint 2: Classify a transaction ───────────────────────────────────────
@app.post("/transaction/classify")
def classify_transaction(tx: Transaction):
    X = pd.DataFrame([tx.dict()])
    X = X[classifier_cols]
    
    label     = classifier.predict(X)[0]
    proba     = classifier.predict_proba(X)[0]
    classes   = classifier.classes_
    
    label_es = {
        'normal':             'Gasto normal',
        'compra_inteligente': 'Compra inteligente',
        'compra_innecesaria': 'Compra innecesaria',
        'gasto_excesivo':     'Gasto excesivo'
    }
    
    advice = {
        'normal':             'Tu gasto está dentro de lo normal.',
        'compra_inteligente': '¡Buen trabajo! Esta compra está por debajo de tu promedio.',
        'compra_innecesaria': 'Esta compra podría no ser necesaria dado tu presupuesto.',
        'gasto_excesivo':     'Cuidado — este gasto es significativamente mayor a tu promedio.'
    }
    
    return {
        "cc_num":      tx.cc_num,
        "amount":      tx.amt,
        "category":    tx.category,
        "label":       label,
        "label_es":    label_es.get(label, label),
        "advice":      advice.get(label, ''),
        "confidence":  round(float(max(proba)), 3),
        "probabilities": dict(zip(classes, [round(float(p), 3) for p in proba]))
    }

# ── Endpoint 3: Forecast next month spend ────────────────────────────────────
@app.post("/user/forecast")
def forecast_next_month(profile: UserProfile):
    # First get cluster
    cluster_features = ['avg_monthly_spend', 'volatility',
                        'income_range', 'is_parent',
                        'has_partner', 'is_student', 'life_stage_enc']
    
    X_cluster = np.array([[getattr(profile, f) for f in cluster_features]])
    X_scaled  = scaler.transform(X_cluster)
    cluster   = int(kmeans.predict(X_scaled)[0])
    
    # Build feature vector for forecast
    data = profile.dict()
    
    # Calendar flags for the forecast month
    month = profile.month
    data['is_regreso_clases'] = int(month in [8, 9])
    data['is_decembrina']     = int(month in [11, 12])
    data['is_semana_santa']   = int(month in [3, 4])
    data['is_cuesta_enero']   = int(month == 1)
    data['is_dia_madres']     = int(month == 5)
    data['is_buen_fin']       = int(month == 11)
    data['is_verano']         = int(month in [6, 7])
    
    # Interaction features
    data['regreso_x_parent']    = data['is_regreso_clases'] * data['is_parent']
    data['decembrina_x_income'] = data['is_decembrina'] * data['income_range']
    data['buen_fin_x_income']   = data['is_buen_fin'] * data['income_range']
    data['cuesta_x_low_income'] = data['is_cuesta_enero'] * int(data['income_range'] == 0)
    data['verano_x_student']    = data['is_verano'] * data['is_student']
    data['madres_x_parent']     = data['is_dia_madres'] * data['is_parent']
    data['semana_x_family']     = (data['is_semana_santa'] *
                                    data['is_parent'] * data['has_partner'])
    data['budget_x_excesivo']   = data['has_budget'] * data.get('pct_gasto_excesivo', 0)

    # Fill missing features with 0
    X = pd.DataFrame([data])
    for col in feature_cols:
        if col not in X.columns:
            X[col] = 0
    X = X[feature_cols].fillna(0)

    model = cluster_models.get(cluster, cluster_models[0])
    prediction = float(model.predict(X)[0])

    # Spending tier
    if prediction < 7000:
        tier = 'bajo'
    elif prediction < 15000:
        tier = 'medio_bajo'
    elif prediction < 35000:
        tier = 'medio'
    else:
        tier = 'alto'

    return {
        "cc_num":            profile.cc_num,
        "cluster":           cluster,
        "forecast_month":    month,
        "predicted_spend":   round(prediction, 2),
        "spending_tier":     tier,
        "currency":          "MXN"
    }

# ── Endpoint 4: Full user summary (all 3 in one call) ────────────────────────
@app.post("/user/summary")
def user_summary(profile: UserProfile):
    cluster_result  = get_user_cluster(profile)
    forecast_result = forecast_next_month(profile)
    
    return {
        "cc_num":          profile.cc_num,
        "cluster":         cluster_result['cluster'],
        "cluster_label":   cluster_result['cluster_label'],
        "predicted_spend": forecast_result['predicted_spend'],
        "spending_tier":   forecast_result['spending_tier'],
        "forecast_month":  forecast_result['forecast_month'],
        "currency":        "MXN"
    }

# ── Request schemas for insights ─────────────────────────────────────────────
class UserInsightsProfile(UserProfile):
    transactions: Optional[list] = None

class ChatMessage(BaseModel):
    role:    str
    content: str

class ChatRequest(BaseModel):
    cc_num:         int
    conversation:   list[ChatMessage]
    income_range:   int
    life_stage_enc: int
    is_parent:      int
    has_partner:    int
    is_student:     int
    spending_style_enc: int
    has_budget:     int
    financial_goal_enc: int
    avg_monthly_spend: float
    volatility:     float

# ── Endpoint 5: Generate comprehensive user insights ─────────────────────────
@app.post("/insights/generate")
def generate_insights(profile: UserInsightsProfile):
    # Get cluster
    cluster_features = ['avg_monthly_spend', 'volatility',
                        'income_range', 'is_parent',
                        'has_partner', 'is_student', 'life_stage_enc']
    X = np.array([[getattr(profile, f) for f in cluster_features]])
    X_scaled = scaler.transform(X)
    cluster = int(kmeans.predict(X_scaled)[0])
    
    # Get forecast
    forecast_data = profile.dict()
    month = profile.month
    forecast_data['is_regreso_clases'] = int(month in [8, 9])
    forecast_data['is_decembrina']     = int(month in [11, 12])
    forecast_data['is_semana_santa']   = int(month in [3, 4])
    forecast_data['is_cuesta_enero']   = int(month == 1)
    forecast_data['is_dia_madres']     = int(month == 5)
    forecast_data['is_buen_fin']       = int(month == 11)
    forecast_data['is_verano']         = int(month in [6, 7])
    
    X_fc = pd.DataFrame([forecast_data])
    for col in feature_cols:
        if col not in X_fc.columns:
            X_fc[col] = 0
    X_fc = X_fc[feature_cols].fillna(0)
    
    model = cluster_models.get(cluster, cluster_models[0])
    prediction = float(model.predict(X_fc)[0])
    
    # Analyze transactions if provided
    transaction_insights = []
    if profile.transactions:
        for tx in profile.transactions:
            tx_data = {
                'cc_num': tx.get('cc_num', profile.cc_num),
                'amt': tx.get('amt', 0),
                'category': tx.get('category', 'unknown'),
                'hour': tx.get('hour', 12),
                'dayofweek': tx.get('dayofweek', 0),
                'month': tx.get('month', 1),
                'is_weekend': tx.get('is_weekend', 0),
                'is_night': tx.get('is_night', 0),
                'is_regreso_clases': int(month in [8, 9]),
                'is_decembrina': int(month in [11, 12]),
                'is_semana_santa': int(month in [3, 4]),
                'is_cuesta_enero': int(month == 1),
                'is_dia_madres': int(month == 5),
                'is_buen_fin': int(month == 11),
                'is_verano': int(month in [6, 7]),
                'income_range': profile.income_range,
                'life_stage_enc': profile.life_stage_enc,
                'is_parent': profile.is_parent,
                'has_partner': profile.has_partner,
                'is_student': profile.is_student,
                'spending_style_enc': profile.spending_style_enc,
                'has_budget': profile.has_budget,
                'financial_goal_enc': profile.financial_goal_enc,
                'avg_monthly_spend': profile.avg_monthly_spend,
                'volatility': profile.volatility,
                'cat_mean': tx.get('cat_mean', 0),
                'cat_median': tx.get('cat_median', 0),
                'cat_freq': tx.get('cat_freq', 1),
                'z_score': tx.get('z_score', 0),
                'pct_of_monthly': tx.get('pct_of_monthly', 0),
                'is_essential': tx.get('is_essential', 0),
                'is_discretionary': tx.get('is_discretionary', 0),
                'is_impulsive_cat': tx.get('is_impulsive_cat', 0),
            }
            X_tx = pd.DataFrame([tx_data])
            X_tx = X_tx[classifier_cols]
            label = classifier.predict(X_tx)[0]
            transaction_insights.append({
                'category': tx.get('category', 'unknown'),
                'amount': tx.get('amt', 0),
                'label': label,
                'is_essential': tx.get('is_essential', 0),
            })
    
    # Generate insights summary
    tier = 'bajo' if prediction < 7000 else 'medio_bajo' if prediction < 15000 else 'medio' if prediction < 35000 else 'alto'
    
    insights = {
        "cc_num": profile.cc_num,
        "cluster": cluster,
        "cluster_label": ['familia_cuidadosa', 'pareja_sin_hijos', 'ejecutivo', 
                         'estudiante', 'medio_cuidadoso', 'familia_equilibrada'][cluster],
        "forecast": {
            "next_month_spend": round(prediction, 2),
            "tier": tier,
            "currency": "MXN"
        },
        "current_month_spend": round(profile.avg_monthly_spend, 2),
        "risk_level": "bajo" if profile.volatility < 0.5 else "medio" if profile.volatility < 1.0 else "alto",
        "recommendations": []
    }
    
    # Add recommendations based on cluster and spending
    cluster_recommendations = {
        0: "Como padre de familia cuidadosa, considere ahorrar un 10% de su presupuesto para emergencias.",
        1: "Como pareja sin hijos, podrían considerar invertir un 15% de sus ahorros en fondos de bajo riesgo.",
        2: "Como ejecutivo, revise sus gastos de entretenimiento; podrían ser más eficientes.",
        3: "Como estudiante, aproveche las herramientas de presupuesto para controlar gastos no esenciales.",
        4: "Con un estilo de gasto medio, considite establecer metas financieras mensuales específicas.",
        5: "Como familia equilibrada, podrían beneficiarse de planificación financiera trimestral."
    }
    
    if cluster in cluster_recommendations:
        insights["recommendations"].append(cluster_recommendations[cluster])
    
    # Add transaction-based insights
    if transaction_insights:
        essential_count = sum(1 for tx in transaction_insights if tx.get('is_essential', 0) == 1)
        total_tx = len(transaction_insights)
        essential_ratio = essential_count / total_tx if total_tx > 0 else 0
        
        if essential_ratio < 0.6:
            insights["recommendations"].append(
                "Sus gastos esenciales representan menos del 60% del total. Considere ajustar su presupuesto."
            )
        
        over_limit_tx = [tx for tx in transaction_insights if tx.get('label') == 'gasto_excesivo']
        if over_limit_tx:
            insights["recommendations"].append(
                f"Ha tenido {len(over_limit_tx)} gastos excesivos recientemente. Revise sus categorías de mayor gasto."
            )
    
    insights["transactions_analyzed"] = len(transaction_insights)
    
    return insights

# ── Endpoint 6: Chat with context-aware advice ───────────────────────────────
@app.post("/insights/chat")
def chat_with_context(chat_request: ChatRequest):
    # Get user profile context
    cluster_features = ['avg_monthly_spend', 'volatility',
                        'income_range', 'is_parent',
                        'has_partner', 'is_student', 'life_stage_enc']
    X = np.array([[chat_request.avg_monthly_spend, chat_request.volatility,
                   chat_request.income_range, chat_request.is_parent,
                   chat_request.has_partner, chat_request.is_student, chat_request.life_stage_enc]])
    X_scaled = scaler.transform(X)
    cluster = int(kmeans.predict(X_scaled)[0])
    
    # Get forecast for additional context
    forecast_data = chat_request.dict()
    month = 4  # Default to April
    forecast_data['is_regreso_clases'] = int(month in [8, 9])
    forecast_data['is_decembrina']     = int(month in [11, 12])
    forecast_data['is_semana_santa']   = int(month in [3, 4])
    forecast_data['is_cuesta_enero']   = int(month == 1)
    forecast_data['is_dia_madres']     = int(month == 5)
    forecast_data['is_buen_fin']       = int(month == 11)
    forecast_data['is_verano']         = int(month in [6, 7])
    
    X_fc = pd.DataFrame([forecast_data])
    for col in feature_cols:
        if col not in X_fc.columns:
            X_fc[col] = 0
    X_fc = X_fc[feature_cols].fillna(0)
    
    model = cluster_models.get(cluster, cluster_models[0])
    prediction = float(model.predict(X_fc)[0])
    
    # Generate context-aware response based on conversation history
    last_message = chat_request.conversation[-1]['content'].lower() if chat_request.conversation else ""
    
    cluster_names = ['familia cuidadosa', 'pareja sin hijos', 'ejecutivo', 
                    'estudiante', 'medio cuidadoso', 'familia equilibrada']
    
    responses = {
        "gasto": f"Como usuario en el cluster {cluster_names[cluster]}, su promedio mensual es de ${chat_request.avg_monthly_spend:,.0f}. "
                f"Se pronostica que gastará ${prediction:,.0f} el próximo mes. "
                f"Su volatilidad es {'baja' if chat_request.volatility < 0.5 else 'alta'}.",
        
        "presupuesto": f"Con un ingreso en rango {chat_request.income_range} y {'sin presupuesto' if not chat_request.has_budget else 'con presupuesto'}, "
                      f"le recomendamos establecer límites por categoría. Su gasto proyectado es ${prediction:,.0f}.",
        
        "ahorro": f"Para alguien en su situación ({cluster_names[cluster]}), considere ahorrar entre 10-15% de sus ingresos. "
                 f"A la fecha ha gastado ${chat_request.avg_monthly_spend:,.0f} mensuales.",
        
        "invitacion": f"Con {chat_request.is_parent} hijos y {'pareja' if chat_request.has_partner else 'sin pareja'}, "
                     f"los gastos familiares representan {('altos' if cluster in [0, 5] else 'moderados')}. "
                     f"Se pronostica un gasto de ${prediction:,.0f} para el próximo mes.",
        
        "default": f"Basado en su perfil de usuario ({cluster_names[cluster]}), "
                  f"su gasto promedio es ${chat_request.avg_monthly_spend:,.0f} y se pronostica ${prediction:,.0f}. "
                  f"Tenga en cuenta que su volatilidad de gasto es {'baja' if chat_request.volatility < 0.5 else 'moderada' if chat_request.volatility < 1.0 else 'alta'}."
    }
    
    response_text = ""
    if any(keyword in last_message for keyword in ["gasto", "gastado", "dinero", "compra", "compras"]):
        response_text = responses["gasto"]
    elif any(keyword in last_message for keyword in ["presupuesto", "gastar", "limites", "controlar"]):
        response_text = responses["presupuesto"]
    elif any(keyword in last_message for keyword in ["ahorrar", "ahorros", "ahorro", "emergencia"]):
        response_text = responses["ahorro"]
    elif any(keyword in last_message for keyword in ["familia", "hijos", "niños", "pareja", "invitaciones"]):
        response_text = responses["invitacion"]
    else:
        response_text = responses["default"]
    
    return {
        "cc_num": chat_request.cc_num,
        "response": response_text,
        "context": {
            "cluster": cluster,
            "cluster_label": cluster_names[cluster],
            "forecasted_spend": round(prediction, 2),
            "user_status": "estable" if chat_request.has_budget and chat_request.volatility < 1.0 else "requiere_atencion" if chat_request.volatility > 2.0 else "monitorizar"
        }
    }

if __name__ == "__main__":
    import uvicorn
    # This starts the server when the file is executed directly
    # Binding to all interfaces for external access (needed for Railway/Flutter web)
    uvicorn.run("app_api:app", host="0.0.0.0", port=8000, reload=True)