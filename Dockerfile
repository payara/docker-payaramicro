FROM openjdk:8-jdk-alpine

# Default payara ports to expose
EXPOSE 4848 9009 8080 8181

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
ENTRYPOINT ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-XX:MaxRAMFraction=1", "-jar", "payara-micro.jar"]
CMD ["--deploymentDir", "/opt/payara/deployments"]

# Download specific
ENV PAYARA_VERSION 5.183
RUN wget --no-verbose -O ${PAYARA_HOME}/payara-micro.jar http://central.maven.org/maven2/fish/payara/extras/payara-micro/5.184/payara-micro-5.184.jar 
