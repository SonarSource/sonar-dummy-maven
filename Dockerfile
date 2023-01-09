ARG CIRRUS_AWS_ACCOUNT
FROM ${CIRRUS_AWS_ACCOUNT}.dkr.ecr.eu-central-1.amazonaws.com/base:j18-latest

USER root

RUN apt-get update && apt-get install -y nodejs

USER sonarsource
