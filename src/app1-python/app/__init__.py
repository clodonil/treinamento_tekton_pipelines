from flask import Flask, render_template
app = Flask(__name__)
app.config.from_object('config')


@app.route('/')
def message():
    message = app.config['MSG']
    return render_template('page.html',message=message,db_url=app.config['DB_URL'], db_user=app.config['DB_USER'],db_passwd=app.config['DB_PASSWD'])
    
    