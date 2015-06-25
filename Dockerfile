FROM ruby:2.1-onbuild
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv C7917B12 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y redis-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
CMD ["./run.sh"]