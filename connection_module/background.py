
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import urllib.parse
import subprocess
import schedule
import time
import sys
print(sys.executable)

cred = credentials.Certificate("architecture-project-cc43f-firebase-adminsdk-ek5os-3b8c46693c.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://architecture-project-cc43f-default-rtdb.firebaseio.com/'
})
def execute_task():
    # Verificar aqui que python no se confunda de interpretes
    subprocess.call([r"C:\Users\sirok\PycharmProjects\connection_module\.venv\Scripts\python.exe", r"C:\Users\sirok\PycharmProjects\connection_module\main.py"])


# Define the schedule (in seconds)
schedule_interval = 3

# Schedule the task
schedule.every(schedule_interval).seconds.do(execute_task)

# Run the scheduler
while True:
    schedule.run_pending()
    time.sleep(1)
