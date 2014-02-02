FROM ubuntu:12.10
RUN apt-get update
RUN apt-get install -y nodejs nodejs-legacy npm
RUN apt-get install -y libcairo2-dev
ADD . /docs
RUN rm -rf /docs/node_modules
RUN cd docs; npm install
# Fails to install. Why? -no-cache doesn't help.
