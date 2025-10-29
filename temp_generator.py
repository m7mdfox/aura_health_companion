import json
from datetime import datetime, timedelta
import random

base_time = datetime(2025, 10, 26, 9, 0, 0)
vital_signs = []

for i in range(1000):
    current_time = base_time + timedelta(minutes=i)
    entry = {
        "time": current_time.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "heartRate": random.randint(70, 85),  # Keeping heart rate in normal range
        "bpSystolic": random.randint(118, 125),  # Keeping BP in normal range
        "bpDiastolic": random.randint(78, 85),
        "spo2": random.randint(95, 99)  # Keeping SpO2 in normal range
    }
    vital_signs.append(entry)

data = {"vitalSigns": vital_signs}

with open('assets/vitals.json', 'w') as f:
    json.dump(data, f, indent=2)