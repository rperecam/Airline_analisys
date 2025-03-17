import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV, cross_val_score, StratifiedKFold
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import Pipeline
from sklearn.metrics import log_loss, f1_score, accuracy_score
import numpy as np

def train_and_evaluate_model(file_path='data/model.csv'):
    """
    Entrena y evalúa un modelo RandomForestClassifier para predecir categorías de puntos.

    Args:
        file_path (str): Ruta al archivo CSV con los datos.

    Returns:
        dict: Diccionario con métricas del modelo, importancias de características y resultados de validación cruzada.
    """

    # Carga tus datos
    df = pd.read_csv(file_path)

    # Elimina las columnas de ciudad y provincia
    df = df.drop(['City', 'Province', 'Postal Code'], axis=1)

    # Categoriza la variable objetivo como "alto" y "bajo"
    median_points = df['Total Points Redeemed'].median()
    df['Points Category'] = np.where(df['Total Points Redeemed'] >= median_points, 'alto', 'bajo')

    # Identifica variables categóricas y numéricas
    categorical_features = ['Gender', 'Education', 'Marital Status', 'Loyalty Card', 'Enrollment Type']
    numerical_features = ['Salary']

    # Variable objetivo
    target = 'Points Category'

    # Transforma las columnas
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', StandardScaler(), numerical_features),
            ('cat', OneHotEncoder(handle_unknown='ignore'), categorical_features)])

    # Pipeline
    pipeline = Pipeline(steps=[('preprocessor', preprocessor),
                               ('model', RandomForestClassifier(random_state=42))])

    X = df.drop(['Total Points Redeemed', target], axis=1)
    y = df[target]

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

    # Parámetros para GridSearchCV
    param_grid = {
        'model__n_estimators': [100, 200],
        'model__max_depth': [10, 15],
        'model__min_samples_split': [2, 5],
        'model__min_samples_leaf': [1, 2]
    }

    # GridSearchCV
    grid_search = GridSearchCV(pipeline, param_grid, cv=StratifiedKFold(n_splits=5), scoring='f1_macro', n_jobs=-1, verbose=2)
    grid_search.fit(X_train, y_train)

    # Mejor modelo
    best_model = grid_search.best_estimator_

    y_pred = best_model.predict(X_test)
    y_pred_proba = best_model.predict_proba(X_test)

    logloss = log_loss(y_test, y_pred_proba)
    f1 = f1_score(y_test, y_pred, average='macro')
    accuracy = accuracy_score(y_test, y_pred)

    # Validación cruzada
    cv_scores_logloss = -cross_val_score(best_model, X, y, cv=StratifiedKFold(n_splits=5), scoring='neg_log_loss')
    cv_scores_f1 = cross_val_score(best_model, X, y, cv=StratifiedKFold(n_splits=5), scoring='f1_macro')

    # Obtener la importancia de las características
    feature_importances = best_model.named_steps['model'].feature_importances_
    feature_names = numerical_features + list(best_model.named_steps['preprocessor'].named_transformers_['cat'].get_feature_names_out(categorical_features))
    feature_importance_df = pd.DataFrame({'Feature': feature_names, 'Importance': feature_importances})
    feature_importance_df = feature_importance_df.sort_values(by='Importance', ascending=False)

    return {
        'metrics': {'log_loss': logloss, 'f1_score': f1, 'accuracy': accuracy},
        'cv_metrics': {'cv_log_loss': np.mean(cv_scores_logloss), 'cv_f1_score': np.mean(cv_scores_f1)},
        'feature_importance': feature_importance_df.to_dict(orient='records')
    }

if __name__ == "__main__":
    results = train_and_evaluate_model()
    print(results)