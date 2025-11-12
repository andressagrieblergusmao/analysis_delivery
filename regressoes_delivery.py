
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression, HuberRegressor
from sklearn.preprocessing import PolynomialFeatures
from sklearn.metrics import r2_score
import numpy as np

# Load and preprocess data
df = pd.read_csv(r"C:\Users\Andressa\Downloads\cardapiofull.csv", delimiter=";")
df['Distance_Num'] = df['Distance'].apply(parse_distance)
df['Rider wait time (minutes)'] = pd.to_numeric(df['Rider wait time (minutes)'], errors='coerce')

# Names of restaurants to analyze
restaurant_list = ['Aura Pizzas', 'Dilli Burguer Adda', 'Swaad', 'Tandoori Junction']

for name in restaurant_list:
    analyze_restaurant(df, name)


def parse_distance(d):
    if pd.isnull(d):
        return None
    d = str(d).replace("km", "").replace(" ", "")
    if "<" in d:
        return 0.5
    try:
        return float(d)
    except:
        return None

def analyze_restaurant(df, restaurant_name):
    df_rest = df[df['Restaurant name'].str.strip() == restaurant_name.strip()]
    if df_rest.empty:
        print(f"No data found for: {restaurant_name}")
        return
    df_group = df_rest.groupby('Distance_Num', as_index=False)['Rider wait time (minutes)'].mean().dropna()
    print(f"{restaurant_name}: {len(df_group)} grouped points")
    X = df_group[['Distance_Num']]
    y = df_group['Rider wait time (minutes)']

    if len(X) < 2:
        print(f"Not enough data for regression: {restaurant_name}")
        return

    # Linear regression
    model = LinearRegression()
    model.fit(X, y)
    y_pred = model.predict(X)
    r2 = r2_score(y, y_pred)
    plt.figure(figsize=(8,6))
    plt.scatter(X, y, label='Mean by distance', color='blue')
    plt.plot(X, y_pred, label=f'Linear regression (R²={r2:.3f})', color='red')
    plt.xlabel('Distance (km)')
    plt.ylabel('Mean Rider wait time (minutes)')
    plt.title(f'{restaurant_name}: Linear Regression')
    plt.legend()
    plt.show()

    # Polynomial regressions (degrees 2 and 3)
    for degree in [2,3]:
        poly = PolynomialFeatures(degree=degree)
        X_poly = poly.fit_transform(X)
        model_poly = LinearRegression()
        model_poly.fit(X_poly, y)
        y_poly_pred = model_poly.predict(X_poly)
        r2_poly = r2_score(y, y_poly_pred)

        plt.figure(figsize=(8,6))
        plt.scatter(X, y, color='blue', label='Mean by distance')
        plt.plot(X, y_poly_pred, color='green', label=f'Polynomial degree {degree} (R²={r2_poly:.3f})')
        plt.xlabel('Distance (km)')
        plt.ylabel('Mean Rider wait time (minutes)')
        plt.title(f'{restaurant_name}: Polynomial Regression, Degree {degree}')
        plt.legend()
        plt.show()

    # Robust regression (Huber)
    model_huber = HuberRegressor()
    model_huber.fit(X, y)
    y_huber_pred = model_huber.predict(X)
    r2_huber = r2_score(y, y_huber_pred)

    plt.figure(figsize=(8,6))
    plt.scatter(X, y, color='blue', label='Mean by distance')
    plt.plot(X, y_huber_pred, color='purple', label=f'Huber Regressor (R²={r2_huber:.3f})')
    plt.xlabel('Distance (km)')
    plt.ylabel('Mean Rider wait time (minutes)')
    plt.title(f'{restaurant_name}: Huber Robust Regression')
    plt.legend()
    plt.show()

    # Logarithmic regression
    X_log = np.log1p(X)
    model_log = LinearRegression()
    model_log.fit(X_log, y)
    y_log_pred = model_log.predict(X_log)
    r2_log = r2_score(y, y_log_pred)

    plt.figure(figsize=(8,6))
    plt.scatter(X_log, y, color='blue', label='Mean by log(distance)')
    plt.plot(X_log, y_log_pred, color='orange', label=f'Logarithmic (R²={r2_log:.3f})')
    plt.xlabel('log(Distance + 1)')
    plt.ylabel('Mean Rider wait time (minutes)')
    plt.title(f'{restaurant_name}: Logarithmic Regression')
    plt.legend()
    plt.show()


