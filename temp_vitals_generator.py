import json
from datetime import datetime, timedelta
import random

def generate_vitals(count=1000):
    base_time = datetime(2025, 10, 26, 9, 0, 0)
    vital_signs = []
    
    # Initialize cumulative steps and calories for the day
    daily_steps = 1000  # Starting from 1000 steps
    daily_calories = 100
    
    for i in range(count):
        current_time = base_time + timedelta(minutes=i)
        
        # Generate steps that accumulate throughout the day
        step_increment = random.randint(50, 200)  # Steps per minute
        daily_steps += step_increment
        daily_steps = min(daily_steps, 10000)  # Cap at 10000
        
        # Calculate calories based on steps and activity
        calorie_increment = random.randint(5, 15)  # Calories per minute
        daily_calories += calorie_increment
        daily_calories = min(daily_calories, 1000)  # Cap at 1000
        
        entry = {
            "time": current_time.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "heartRate": random.randint(70, 85),
            "bpSystolic": random.randint(118, 125),
            "bpDiastolic": random.randint(78, 85),
            "spo2": random.randint(95, 99),
            "steps": daily_steps,
            "caloriesBurnt": daily_calories
        }
        vital_signs.append(entry)
    
    return {"vitalSigns": vital_signs}

# Generate and save the data
data = generate_vitals()
with open('assets/vitals.json', 'w') as f:
    json.dump(data, f, indent=2)