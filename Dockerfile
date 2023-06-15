ARG CIRRUS_AWS_ACCOUNT
FROM ${CIRRUS_AWS_ACCOUNT}.dkr.ecr.eu-central-1.amazonaws.com/base:j18-latest

USER root

# renovate: datasource=github-releases depName=SonarSource/differential-validation
ENV SNAPSHOT_APP_VERSION=1.0.0.220
RUN apt-get update && apt-get install -y nodejs

USER sonarsource
