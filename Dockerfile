FROM jupyter/scipy-notebook

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl
# RUN apt-get install curl

EXPOSE 8888:8888
VOLUME $PWD:/home/jovyan/workspace
