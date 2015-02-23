FROM ubuntu:14.04
MAINTAINER Boyan Bonev <b.bonev@redbuffstudio.com>

#Setup container environment parameters
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

#Configure locale.
RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

#Prepare the image
RUN apt-get -y update

#Make our life easy with utilities added unzip and zip...
RUN apt-get install -y -q python-software-properties software-properties-common bash-completion wget nano \
curl libcurl3 libcurl3-dev build-essential unzip zip

# Install VCS
RUN apt-get install -y -q git subversion

#Install Ruby 2.1.3 (for sass)
RUN apt-get install -y -q libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.1.3"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

# Install Javasript build toolchain.
RUN curl -sL https://deb.nodesource.com/setup | sudo bash -
RUN apt-get install -y -q nodejs

#Install javascript toolkit.
RUN npm install -g bower
RUN npm install -g grunt-cli
RUN npm install -g gulp

#Install PHP 5.6.2
RUN echo "deb http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key E5267A6C
RUN apt-get -y update
RUN apt-get install -y -q php5-cli php5-mongo
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

#Fetch wraptodocker for docker nesting
RUN apt-get install -y apparmor
RUN curl -s https://get.docker.io/ubuntu/ | sudo sh
ADD https://raw.githubusercontent.com/jpetazzo/dind/master/wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker


#Install Java
RUN wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u25-b17/jdk-8u25-linux-x64.tar.gz -O /tmp/java8.tar.gz
RUN mkdir -p /opt/oracle
RUN tar zxf /tmp/java8.tar.gz -C /opt/oracle

ENV JAVA_HOME /opt/oracle/jdk1.8.0_25
ENV PATH $PATH:$JAVA_HOME/bin

RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 2
RUN update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 2

#Install SBT
RUN wget http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.7/sbt-launch.jar -O /bin/sbt-launch.jar
RUN echo -e "SBT_OPTS=\"-Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=256M\" \njava \$SBT_OPTS -jar \`dirname \$0\`/sbt-launch.jar \"\$@\"" >> /bin/sbt
RUN chmod a+x /bin/sbt /bin/sbt-launch.jar

#Install AWS CLI
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
RUN unzip awscli-bundle.zip
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

#need to set aws credentials

#Fetch Jenkins LTS
#ENV JENKINS_VERSION 1.590
ENV JENKINS_HOME /jenkins

RUN mkdir -p /opt/jenkins
RUN wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war -O /opt/jenkins/jenkins.war
RUN chmod 644 /opt/jenkins/jenkins.war

#Install fleet
RUN wget https://github.com/coreos/fleet/releases/download/v0.8.3/fleet-v0.8.3-linux-amd64.tar.gz -O /tmp/fleet.tar.gz
RUN tar zxf /tmp/fleet.tar.gz -C /tmp
RUN mv /tmp/fleet-v0.8.3-linux-amd64/fleetctl /usr/local/bin/

#Clean up packages
RUN rm -rf /tmp/java8.tar.gz
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /var/cache/apt/archives/*

#We always launch jenkins.
ENTRYPOINT ["java", "-jar", "/opt/jenkins/jenkins.war"]
EXPOSE 8080

#Add jenkins plguins
RUN mkdir -p /copy_over/plugins
RUN wget http://updates.jenkins-ci.org/latest/ant.hpi -O /copy_over/plugins/ant.hpi
RUN wget http://updates.jenkins-ci.org/latest/antisamy-markup-formatter.hpi -O /copy_over/plugins/antisamy-markup-formatter.hpi
RUN wget http://updates.jenkins-ci.org/latest/awseb-deployment-plugin.hpi -O /copy_over/plugins/awseb-deployment-plugin.hpi
RUN wget http://updates.jenkins-ci.org/latest/credentials.hpi -O /copy_over/plugins/credentials.hpi
RUN wget http://updates.jenkins-ci.org/latest/credentials.hpi -O /copy_over/plugins/credentials.hpi.pinned
RUN wget http://updates.jenkins-ci.org/latest/cvs.hpi -O /copy_over/plugins/cvs.hpi
RUN wget http://updates.jenkins-ci.org/latest/embeddable-build-status.hpi -O /copy_over/plugins/embeddable-build-status.hpi
RUN wget http://updates.jenkins-ci.org/latest/external-monitor-job.hpi -O /copy_over/plugins/external-monitor-job.hpi
RUN wget http://updates.jenkins-ci.org/latest/git-client.hpi -O /copy_over/plugins/git-client.hpi
RUN wget http://updates.jenkins-ci.org/latest/git.hpi -O /copy_over/plugins/git.hpi
RUN wget http://updates.jenkins-ci.org/latest/github-api.hpi -O /copy_over/plugins/github-api.hpi
RUN wget http://updates.jenkins-ci.org/latest/github.hpi -O /copy_over/plugins/github.hpi
RUN wget http://updates.jenkins-ci.org/latest/greenballs.hpi -O /copy_over/plugins/greenballs.hpi
RUN wget http://updates.jenkins-ci.org/latest/javadoc.hpi -O /copy_over/plugins/javadoc.hpi
RUN wget http://updates.jenkins-ci.org/latest/junit.hpi -O /copy_over/plugins/junit.hpi
RUN wget http://updates.jenkins-ci.org/latest/ldap.hpi -O /copy_over/plugins/ldap.hpi
RUN wget http://updates.jenkins-ci.org/latest/mailer.hpi -O /copy_over/plugins/mailer.hpi
RUN wget http://updates.jenkins-ci.org/latest/matrix-auth.hpi -O /copy_over/plugins/matrix-auth.hpi
RUN wget http://updates.jenkins-ci.org/latest/matrix-project.hpi -O /copy_over/plugins/matrix-project.hpi
RUN wget http://updates.jenkins-ci.org/latest/matrix-project.hpi -O /copy_over/plugins/matrix-project.hpi.pinned
RUN wget http://updates.jenkins-ci.org/latest/maven-plugin.hpi -O /copy_over/plugins/maven-plugin.hpi
RUN wget http://updates.jenkins-ci.org/latest/pam-auth.hpi -O /copy_over/plugins/pam-auth.hpi
RUN wget http://updates.jenkins-ci.org/latest/sbt.hpi -O /copy_over/plugins/sbt.hpi
RUN wget http://updates.jenkins-ci.org/latest/scm-api.hpi -O /copy_over/plugins/scm-api.hpi
RUN wget http://updates.jenkins-ci.org/latest/slack.hpi -O /copy_over/plugins/slack.hpi
RUN wget http://updates.jenkins-ci.org/latest/ssh-credentials.hpi -O /copy_over/plugins/ssh-credentials.hpi
RUN wget http://updates.jenkins-ci.org/latest/ssh-slaves.hpi -O /copy_over/plugins/ssh-slaves.hpi
RUN wget http://updates.jenkins-ci.org/latest/subversion.hpi -O /copy_over/plugins/subversion.hpi
RUN wget http://updates.jenkins-ci.org/latest/translation.hpi -O /copy_over/plugins/translation.hpi
RUN wget http://updates.jenkins-ci.org/latest/windows-slaves.hpi -O /copy_over/plugins/windows-slaves.hpi

CMD [""]

#todo
#jenkins aws credentials
#jenkins configure
#