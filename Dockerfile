FROM azul/zulu-openjdk-alpine:11-jre

# Default payara ports to expose
EXPOSE 6900 8080

# Configure environment variables
ENV PAYARA_HOME=/opt/payara\
    DEPLOY_DIR=/opt/payara/deployments

# Create and set the Payara user and working directory owned by the new user
RUN addgroup payara && \
    adduser -D -h ${PAYARA_HOME} -H -s /bin/bash payara -G payara && \
    echo payara:payara | chpasswd && \
    mkdir -p ${DEPLOY_DIR} && \
    chown -R payara:payara ${PAYARA_HOME}
USER payara
WORKDIR ${PAYARA_HOME}

# Default command to run
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=90.0", "-jar", "payara-micro.jar"]
CMD ["--deploymentDir", "/opt/payara/deployments"]

# Download specific
ARG PAYARA_VERSION="5.201"
ENV PAYARA_VERSION="$PAYARA_VERSION"
RUN wget --no-verbose -O ${PAYARA_HOME}/payara-micro.jar https://repo1.maven.org/maven2/fish/payara/extras/payara-micro/${PAYARA_VERSION}/payara-micro-${PAYARA_VERSION}.jar
