FROM debian:7.4
RUN echo "deb http://http.debian.net/debian/ wheezy-backports main" >> /etc/apt/sources.list
RUN apt-get update

# Install node and NPM
RUN apt-get install -y nodejs nodejs-legacy
RUN apt-get install -y curl moreutils
RUN curl https://www.npmjs.org/install.sh | sponge | clean=no sh

# Stuff necessary for PNG
RUN apt-get install -y build-essential
RUN apt-get install -y python
RUN apt-get install -y libpng-dev
RUN apt-get install -y pkg-config
RUN apt-get install -y libcairo2-dev

# Basics for building and testing
RUN npm install coffee-script@1.7.1
RUN npm install uglify-js@2.4.13
RUN npm install underscore@1.6.0
RUN npm install mocha@1.7.0

# Stuff for generating docs
RUN npm install colorspaces@0.1.3
RUN npm install onecolor@2.4.0
RUN npm install eco@1.1.0-rc-2
RUN npm install png@3.0.3
RUN npm install stylus@0.47.3
RUN npm install husl

ENV PATH $PATH:/node_modules/.bin

WORKDIR /husl
