# s2i-java
FROM openshift/base-centos7

# HOME in base image is /opt/app-root/src
ENV MAVEN_VERSION=3.3.9 \
    MAINTAINER="John Deng <john.deng@outlook.com>" \
    GRADLE_VERSION=4.10 \
    PATH=/opt/maven/bin/:/opt/gradle/bin/:$PATH \
    BUILDER_VERSION=1.0 \
    LC_ALL="zh_CN.UTF-8"

 
LABEL io.k8s.description="Platform for building Java (fatjar) applications with maven or gradle" \
      io.k8s.display-name="Java S2I builder 1.0" \
      io.openshift.expose-services="7575:http,8080:http" \
      io.openshift.tags="builder,maven-3,gradle-2.6,java,microservices,fatjar" \
      io.openshift.s2i.scripts-url=image:///usr/local/sti


# Install build tools on top of base image
# Java jdk 8, Maven 3.3, Gradle 2.6
RUN INSTALL_PKGS="tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
     \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    yum -y install kde-l10n-Chinese telnet && \
    ocaledef -c -f UTF-8 -i zh_CN zh_CN.utf8 \
    mkdir -p /opt/openshift && \
    mkdir -p /opt/app-root/source && chmod -R a+rwX /opt/app-root/source && \
    mkdir -p /opt/s2i/destination && chmod -R a+rwX /opt/s2i/destination && \
    mkdir -p /opt/app-root/src && chmod -R a+rwX /opt/app-root/src

RUN (curl -0 https://mirrors.ustc.edu.cn/macports/distfiles/maven3/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    ln -sf /usr/local/maven/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && chmod -R a+rwX $HOME/.m2

RUN curl -sL -0 https://mirrors.ustc.edu.cn/macports/distfiles/gradle/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /usr/local/ && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    mv /usr/local/gradle-${GRADLE_VERSION} /usr/local/gradle && \
    ln -sf /usr/local/gradle/bin/gradle /usr/local/bin/gradle

# TODO (optional): Copy the builder files into /opt/openshift
# COPY ./<builder_folder>/ /opt/openshift/
# COPY Additional files,configurations that we want to ship by default, like a default setting.xml
COPY ./contrib/settings.xml $HOME/.m2/

COPY ./sti/bin/ /usr/local/sti

RUN chown -R 1001:1001 /opt/openshift 

# 设置环境变量
# This default user is created in the openshift/base-centos7 image
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080 

# Set the default grpc server port
EXPOSE 7575

# Set the default CMD for the image
# CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/opt/openshift/app.jar"]
CMD ["usage"]
