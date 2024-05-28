project="demo_site"
mkdir "${project}_project"
cd "${project}_project/"
mkdir $project
mkdir $project/certificate/
sudo apt install python3-virtualenv -y
virtualenv venv
source venv/bin/activate
pip install flask flask-wtf

touch $project/certificate/openssl.cnf

cat >> $project/certificate/openssl.cnf <<EOF
[ req ]
prompt = no
distinguished_name = alshawwaf.ca

[ alshawwaf.ca ]
countryName=            CA
stateOrProvinceName=    ON
localityName=           Ottawa
organizationName=       Americas-ses
organizationalUnitName= Demo TLS Web Server
commonName=             www.americas-ses.ca
emailAddress = kalshaww@checkpoint.com
EOF


# You can generate self-signed certificates easily from the command line. All you need is to have openssl installed:
# sudo apt install openssl
openssl req -x509 --config $project/certificate/openssl.cnf -newkey rsa:4096 -nodes -out $project/certificate/cert.pem -keyout $project/certificate/key.pem -days 365

cd $project
mkdir static templates data
touch forms.py
cat > __init__.py << EOF
from flask import Flask
app = Flask(__name__)
from $project import views
EOF
cat > views.py << EOF
from $project import app
from flask import render_template
@app.route('/')
def index():
    return render_template('index.html')
EOF
cat > run.py << EOF
import os
import sys
sys.path.append(os.path.dirname(os.getcwd()))
from $project import app
if __name__ == '__main__':
    app.run(host ='0.0.0.0', debug=True, ssl_context=('certificate/cert.pem', 'certificate/key.pem'))
EOF
cat > templates/base.html << 'EOF'
<!DOCTYPE html>
<html>
    <head>
    {% block head %}
    {% endblock %}
    </head>
    
    <body>
    {% block content %}
    {% endblock %}
    </body>
</html>
EOF
cat > templates/index.html << EOF
{% extends 'base.html' %}
{% block content %}
    <h1>Demo TLS Webste</h1>
    <h2> Use this server to test inbound HTTPS Inspection</h1>
{% endblock %}
EOF
pip freeze > requirements.txt
python3 run.py
