FROM ubuntu:14.04
RUN apt-get update

# Install node and NPM
RUN apt-get install -y nodejs
RUN apt-get install -y npm

# Required by coffee executable
RUN apt-get install -y nodejs-legacy

# Required by Node PNG
RUN apt-get install -y libpng-dev

# Stuff for generating docs
RUN npm install -g coffee-script@1.7.1
RUN npm install colorspaces@0.1.3
RUN npm install onecolor@2.4.0
RUN npm install eco@1.1.0-rc-2
RUN npm install png@3.0.3
RUN npm install stylus@0.47.3
RUN npm install husl
RUN npm install coffee-script@1.7.1

ADD . /husl
WORKDIR /husl
