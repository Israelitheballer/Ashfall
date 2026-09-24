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

from datetime import datetime

class Incident(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(120), nullable=False)
    description = db.Column(db.Text, nullable=True)
    status = db.Column(db.String(20), nullable=False, default='open')
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow) 
    
    
from flask import request
@app.route ('/incidents', methods = ['POST'])
def create_incident():
    data = request.get_json()
    
    if not data or 'title' not in data:
        return {'error': 'title is required'}, 400
    
    incident = Incident(
        title = data['title'],
        description = data.get('description'),
        status = data.get('status', 'open')
    )
    db.session.add(incident)
    db.session.commit()
    
    return {
        "id" : incident.id,
        "title" : incident.title,
        "description" : incident.description, 
        "status" : incident.status, 
        "created_at" : incident.created_at.isoformat()
    }, 201
