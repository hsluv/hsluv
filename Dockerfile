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
RUN npm install coffee-script
RUN npm install uglify-js
RUN npm install underscore
RUN npm install stylus
RUN npm install mocha

# Stuff for generating docs
RUN npm install colorspaces
RUN npm install onecolor
RUN npm install eco
RUN npm install png

ENV PATH $PATH:/node_modules/.bin

RUN groupadd --gid 1000 admin
RUN useradd --gid 1000 --uid 1000 admin
USER admin

WORKDIR /husl