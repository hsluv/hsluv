FROM debian:7.4
RUN echo "deb http://http.debian.net/debian/ wheezy-backports main" >> /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y nodejs nodejs-legacy
RUN apt-get install -y curl moreutils
RUN curl https://www.npmjs.org/install.sh | sponge | clean=no sh

# Stuff necessary for PNG
RUN apt-get install -y build-essential
RUN apt-get install -y python
RUN apt-get install -y libpng-dev
RUN apt-get install -y pkg-config
RUN apt-get install -y libcairo2-dev

RUN npm install -g coffee-script
RUN npm install -g colorspaces
RUN npm install -g husl
RUN npm install -g onecolor
RUN npm install -g png
RUN npm install -g stylus
RUN npm install -g eco
RUN npm install -g mocha
RUN npm install -g imagediff

#RUN cd docs && npm install
