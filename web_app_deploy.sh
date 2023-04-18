#!/bin/bash

# Update and install necessary packages
sudo yum update -y
sudo yum install -y python3-pip

# Install Flask
sudo pip3 install Flask

mkdir -p /home/ec2-user/myapp/
# Create the Flask app
cat <<EOF > /home/ec2-user/myapp/app.py
from flask import Flask, request, redirect, url_for
import os

app = Flask(__name__)

@app.route('/')
def index():
    return '''
        <html>
            <body>
                <h1>File Upload</h1>
                <form method="POST" action="/upload" enctype="multipart/form-data">
                    <input type="file" name="file">
                    <input type="text" name="directory" placeholder="Directory">
                    <button type="submit">Upload</button>
                </form>
            </body>
        </html>
    '''

@app.route('/upload', methods=['POST'])
def upload_file():
    file = request.files['file']
    directory = request.form['directory']
    if file:
        filename = file.filename
        if directory:
            filename = os.path.join(directory, filename)
        file.save(filename)
        return redirect(url_for('index'))
    else:
        return 'No file selected'

if __name__ == '__main__':
    app.run()
EOF

# Start the Flask app using Gunicorn
cd /home/ec2-user/myapp/
sudo pip3 install gunicorn
sudo gunicorn --bind 0.0.0.0:8000 app:app &
