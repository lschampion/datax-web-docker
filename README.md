# datax-web-docker

此项目只用于使用容器化部署docker-web
源项目地址：<https://github.com/WeiYe-Jing/datax-web>
希望大家多多支持原作者

### 特性

1、全自动启动（自动给连接初始化mysql数据库）

2、datax支持python3

### 构建服务

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

浏览器访问datax-admin 运行时配置的映射端口
http://地址:9527/index.html   注意：index.html  必须有

账号: admin 密码: 123456

