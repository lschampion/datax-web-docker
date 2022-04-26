##########################  ENV  ##########################
FROM adoptopenjdk/openjdk8 as env

ENV USR_PROGRAM_DIR=/usr/program
ENV DATAX_HOME="${USR_PROGRAM_DIR}/datax"
ENV DATAX_WEB_HOME="${USR_PROGRAM_DIR}/datax-web"
ENV DATAX_PACKAGE=datax.tar.gz
ENV DATAX_WEB_POACKEAGE=datax-web-2.1.2.tar.gz

##########################  BUILDER  ##########################
FROM env as builder
WORKDIR /usr/program/

COPY tar-source-files/* "/source_dir/"
RUN tar -xf "/source_dir/${DATAX_PACKAGE}" -C "${USR_PROGRAM_DIR}"  
RUN tar -xf "/source_dir/${DATAX_WEB_POACKEAGE}" -C "${USR_PROGRAM_DIR}"  \
 && mv "${USR_PROGRAM_DIR}/datax-web-2.1.2" "${USR_PROGRAM_DIR}/datax-web" \
 && "${DATAX_WEB_HOME}/bin/install.sh" --force
RUN rm -rf  /source_dir

##########################  APP  ##########################
FROM env as app

# ENV USR_PROGRAM_DIR=/usr/program
# ENV DATAX_HOME="${USR_PROGRAM_DIR}/datax"
# ENV DATAX_WEB_HOME="${USR_PROGRAM_DIR}/datax-web"
# ENV DATAX_PACKAGE=datax.tar.gz
# ENV DATAX_WEB_POACKEAGE=datax-web-2.1.2.tar.gz
WORKDIR /usr/program/

RUN mkdir -p "${USR_PROGRAM_DIR}/source_dir"
COPY conf/* "${USR_PROGRAM_DIR}/source_dir/"

COPY --from=builder "${USR_PROGRAM_DIR}/" "${USR_PROGRAM_DIR}/"

RUN rm -rf  "${DATAX_HOME}/bin/*" \
 && ls -l "${USR_PROGRAM_DIR}/source_dir/" \
 && cp "${USR_PROGRAM_DIR}/source_dir/datax.py" "${DATAX_HOME}/bin/" \
 && cp "${USR_PROGRAM_DIR}/source_dir/dxprof.py" "${DATAX_HOME}/bin/" \
 && cp "${USR_PROGRAM_DIR}/source_dir/perftrace.py" "${DATAX_HOME}/bin/" \
 && rm -rf ${DATAX_HOME}/plugin/*/._* \
 && chmod 755 -R "${DATAX_HOME}"

RUN cp -f "${USR_PROGRAM_DIR}/source_dir/application.yml" "${DATAX_WEB_HOME}/modules/datax-admin/conf/" \
 && cp -f "${USR_PROGRAM_DIR}/source_dir/bootstrap.properties" "${DATAX_WEB_HOME}/modules/datax-admin/conf/" \
 && cp -f "${USR_PROGRAM_DIR}/source_dir/env.properties" "${DATAX_WEB_HOME}/modules/datax-executor/bin/" \
 && chmod 755 -R "${DATAX_WEB_HOME}" 

RUN mv /etc/apt/sources.list /etc/apt/sources.list.backup \
 && touch /etc/apt/sources.list \
 && echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse' >> /etc/apt/sources.list \
 && echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse' >> /etc/apt/sources.list \
 && echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse' >> /etc/apt/sources.list \
 && echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse' >> /etc/apt/sources.list \
 && echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse' >> /etc/apt/sources.list \
 && echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse' >> /etc/apt/sources.list \
 && echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse' >> /etc/apt/sources.list \
 && echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse' >> /etc/apt/sources.list \
 && echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse' >> /etc/apt/sources.list \
 && echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse' >> /etc/apt/sources.list 
RUN rm -rf /var/lib/apt/lists/partial/*
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
# for postgresql env
# RUN apt-get install -y libpq-dev python-dev
RUN apt-get install -y vim
RUN apt-get install -y inetutils-ping

#RUN apt-get install -y freetds-dev freetds-bin 
RUN pip3 install --upgrade pip \
 && pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip \
 && pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple pymysql \
 && pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple argparse \
# && pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple pymssql \
# && pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple psycopg2 \
 && rm -rf /usr/bin/python \
 && ln -s /usr/bin/`ls -l /usr/bin/ | grep python | grep "^-" | awk 'NR==1{print $9}'` /usr/bin/python
# 设置python 至python3.n的软连接，此处可能有多个python3.n取第一个即可

RUN rm -rf "${USR_PROGRAM_DIR}/source_dir"
COPY scripts/init_database.py /
COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh && chmod +x /init_database.py
ENTRYPOINT ["/entrypoint.sh"]
#ENTRYPOINT ["/bin/bash"]
