from flask import Flask
app = Flask(__name__)

import os
from flask_sqlalchemy import SQLAlchemy

app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get ('DATABASE_URL', 'sqlite:///app.db')
app.config['SQL_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

@app.route('/health')
def health():
    return {'status': 'ok'}, 200 