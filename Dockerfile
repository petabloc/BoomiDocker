FROM amazonlinux:latest

RUN yum update -y && yum install shadow-utils systemd python-pip python3-wheel -y && pip install boto3 --user

COPY jdk1.8.0_181 jdk1.8
RUN chmod +x jdk1.8
RUN mv jdk1.8 /usr/local/share
ENV JAVA_HOME=/usr/local/share/jdk1.8
ENV PATH="$JAVA_HOME/bin:${PATH}"

RUN groupadd -g 1002 boomi && useradd -r -u 1002 -g boomi boomi

RUN mkdir -p /usr/local/boomi/work && mkdir -p /usr/local/boomi/molecule && mkdir -p /mnt/data/molecule
RUN ln -s /mnt/data/molecule /usr/local/boomi/molecule

ADD etc/systemd/system/mol_qa.service /etc/systemd/system/
ADD etc/boomi_environment_file.conf /etc/boomi_environment_file.conf 

RUN chmod 744 /etc/systemd/system/mol_qa.service /etc/boomi_environment_file.conf

EXPOSE 9093 7800
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./getIdFromSqs.py /getIdFromSqs.py
RUN chmod +x /docker-entrypoint.sh /getIdFromSqs.py

ENTRYPOINT ["sh", "/docker-entrypoint.sh"]

#CMD ["/bin/bash", "-c", "while true; do sleep 1000; done"]
#update the env config file before you start the service 
#CMD ["/bin/bash", "-c", "systemctl enable mol_qa.service"]
