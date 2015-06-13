FROM ubuntu:14.04
RUN apt-get update

# Install node and NPM
RUN apt-get install -y nodejs
RUN apt-get install -y npm

# Required by coffee executable
RUN apt-get install -y nodejs-legacy

# Stuff for generating docs
RUN npm install

ADD . /husl
WORKDIR /husl