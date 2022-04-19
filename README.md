# datax-web-docker

此项目只用于使用容器化部署docker-web
源项目地址：<https://github.com/WeiYe-Jing/datax-web>
希望大家多多支持原作者

## 编译datax

```text
替换datax项目中的  /core/src/main/bin/ 替换3个文件 文件在项目python3文件夹下
```



## 生成dockerfile

## 

构建服务

```shell
# 构建mysql docker 容器
mkdir -p /root/mysql/conf
touch /root/mysql/conf/my.cn

docker run --name mysql5.7 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d  -v /usr/local/docker_data/mysql/data:/var/lib/mysql -v /usr/local/docker_data/mysql/conf:/etc/mysql/ -v /usr/local/docker_data/mysql/logs:/var/log/mysql mysql:5.7

# 单独测试datax
rm -rf $DATAX_HOME/plugin/*/._*
python $DATAX_HOME/bin/datax.py $DATAX_HOME/job/job.json

# 构建datax-web容器
docker run -it -d -p 9527:9527 --name datax-web lisacumt/datax-web-docker:1.1.0
# 查看容器内服务
docker exec -it datax-web /bin/bash
docker exec -it datax-web jps
# 199 DataXAdminApplication
# 493 DataXExecutorApplication

# 注意：如果使用docker-compose内的mysql则不需要设置子网，因为compose内已是同一子网；如果连接其他服务器则直接修改bootstrap.properties的地址即可，同样不需要如下子网设置

# datax-web在首次启动的20min内会不断尝试连接mysql容器，并初始化数据库。
# 超时没有完成初始化请手动在数据库执行$DATAX_WEB_HOME/bin/db/datax_web.sql。
# 初始化子网
docker network create --subnet 192.168.100.0/16 --gateway 192.168.0.1 mybridge
# 将mysql添加到子网
docker network connect mybridge mysql
# 将datax-web添加到子网
docker network connect mybridge datax-web
# 测试是否能够双向ping通
docker exec -it mysql ping datax-web
docker exec -it datax-web ping mysql
```

## datax-admin启动命令

```text
    运行生成的images  使用/bin/bash 切勿使用/bin/sh
```

### 参数解释

```text
    PORT 代表admin端口 启动时需要和映射端口保持一致
    MYSQL_SERVICE_HOST 代表数据库host，可直接填写地址
    MYSQL_SERVICE_PORT 代表访问端口，基本都是3306 填写
    MYSQL_USER 代表数据库 用户名
    MYSQL_PASSWORD 代表数据库 密码
    DB_DATABASE  初始化数据库 名称
```

### docker运行命令参考

```text
    docker run -i -d -p 2020:2020 \
    --name datax-admin \
    --net datax-network \
    --ip 172.10.0.2 zanderchao/datax-admin:v2  \
    java -jar datax-admin-2.1.2.jar \
    --PORT=$(PORT) \
    --MYSQL_SERVICE_HOST=$(MYSQL_SERVICE_HOST) \
    --MYSQL_SERVICE_PORT=$(MYSQL_SERVICE_PORT) \
    --MYSQL_USER=$(MYSQL_USER) \
    --MYSQL_PASSWORD=$(MYSQL_PASSWORD) \
    --DB_DATABASE=$(DB_DATABASE)
```

## datax-admin 日志路径

```text
    /tmp/datax-admin.log
```

## datax-executor启动命令

参数解释

```text
    PORT 代表executor端口
    ADDRESSES 代表admin服务器地址 eg：http://172.10.0.2:2020
```

docker运行命令参考

```text
    docker run -i -d -p 2020:2020 \
    --name datax-admin \
    --net datax-network \
    --ip 172.10.0.2  zanderchao/datax-executor:v2  \
    java -jar datax-executor-2.1.2.jar \
    --PORT=$(PORT) \
    --ADDRESSES=$(ADDRESSES)
```

## datax-executor 日志路径

```text
    /home/applogs/executor/jobhandler
```

## 集群部署暂未测试

```text
    admin只需要启动一次就可以
    多个executor启动，可将命令中的指定--ip 及 --name 更换为不同即可
```

## 访问

```text
    浏览器访问datax-admin 运行时配置的映射端口
    http://127.0.0.1:port/index.html 初始化密码123456
```

## FAQ

数据库初始化，可在<https://github.com/WeiYe-Jing/datax-web项目中https://github.com/WeiYe-Jing/datax-web/tree/master/bin/db> 中找到sql文件，手动进行初始化
