# !/user/bin/env python3
# -*- coding: utf-8 -*-
import os
import pymysql
import time
import argparse
parser = argparse.ArgumentParser(description='Jenkins pipline parameters')
 
parser.add_argument('--host', type=str, default='', help='host')
parser.add_argument('--port', type=str, default='3306', help='port')
parser.add_argument('--username', type=str, default='', help='username')
parser.add_argument('--password', type=str, default='', help='password')
parser.add_argument('--database', type=str, default='', help='database')

args = parser.parse_args()
 
host = args.host
port = int(args.port)
username = args.username
password = args.password
database = args.database

database
def sync_mysql_data(conn, file):
    cursor = conn.cursor()
    cursor.execute("show databases;")
    # data = cursor.fetchone()
    for line in cursor.fetchall():
        print(line[0])
        if 'dataxweb' == line[0]:
            print('database dataxweb exists,won`t init!!!')
            return
    cursor.execute("create database if not exists dataxweb default character SET utf8mb4 COLLATE utf8mb4_general_ci")

    cursor.execute("use dataxweb;")
    with open(file, "r") as f:  # 打开文件
        data = f.read()
        lines = data.splitlines()
        sql_data = ''
        # 将--注释开头的全部过滤，将空白行过滤
        for line in lines:
            if len(line) == 0:
                continue
            elif line.startswith("--"):
                continue
            else:
                sql_data += line
        sql_list = sql_data.split(';')[:-1]
        sql_list = [x.replace('\n', ' ') if '\n' in x else x for x in sql_list]

    for sql_item in sql_list:
        print('ready to execute sql:\n {}\n'.format(sql_item))
        cursor.execute(sql_item)
    cursor.close()


conn = None
counter = 12 * 20
while conn is None:
    try:
        conn = pymysql.connect(host=host,port=port, user=username, password=password, database=database)
    except Exception as e:
        print('Get conn failed,try again.\n' + str(e))
        time.sleep(5)
        counter = counter - 1
        if counter < 0:
            break
            print('ERROR: can`t get database connection!!!')

# python 处理SQL文件
DATAX_WEB_HOME = os.getenv('DATAX_WEB_HOME')
sync_mysql_data(conn, '%s/bin/db/datax_web.sql' % (DATAX_WEB_HOME))
conn.close()
