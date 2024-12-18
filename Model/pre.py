import pandas as pd
import numpy as np
from flask_cors import CORS
from sklearn.preprocessing import StandardScaler
from xgboost import XGBClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score,classification_report
from flask import Flask,request,jsonify

app = Flask(__name__)
CORS(app)

df = pd.read_csv("Model/diabetes.csv")
df.fillna(df.median(),inplace=True)

X = df.drop('Outcome',axis=1)
y = df['Outcome']

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

X_train,X_test,y_train,y_test = train_test_split(X_scaled,y,test_size=0.2,random_state=42)

model = XGBClassifier()
model.fit(X_train,y_train)

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json()
        input_data = [
            data['pregnancies'],
            data['glucose'],
            data['bloodPressure'],
            data['skinThickness'],
            data['insulin'],
            data['bmi'],
            data['diabetesPedigreeFunction'],
            data['age']
        ]
        input_df = pd.DataFrame([input_data],columns=['Pregnancies', 'Glucose', 'BloodPressure', 'SkinThickness', 'Insulin', 'BMI', 'DiabetesPedigreeFunction', 'Age'])
        input_scaled = scaler.transform(input_df)

        prediction = model.predict(input_scaled)
        return jsonify({'Prediction': int(prediction[0])})
    except Exception as e:
        return jsonify({"error":str(e)})

if __name__ == '__main__':
    app.run(debug=True)
