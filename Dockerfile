FROM python:3.9
ADD . /folder_3x03
WORKDIR /folder_3x03
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# selanium testing
RUN sbase install geckodriver
RUN export PATH=$PATH:/usr/local/lib/python3.9/site-packages/seleniumbase/drivers

# Install OpenJDK-11
RUN apt-get update && \
    apt-get install -y default-jdk

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
RUN export JAVA_HOME

# Install Firefox
RUN apt-get update && \
    apt-get install firefox-esr -y
    

## WARNINGS NEXT GEN PLUGIN
RUN apt-get install npm
RUN npm install -g dockerfile_lint



EXPOSE 5000

# CMD ["uwsgi", "--socket", "0.0.0.0:5000", "--protocol=http", "-w", "wsgi:app", "--logto", "/tmp/wsgi.log"]
CMD ["python3", "app.py"]
