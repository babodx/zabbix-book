#!/bin/bash
#author: itnihao
#mail: itnihao@qq.com
#http://wwww.itnihao.com
#https://github.com/itnihao/zabbix-book/blob/master/03-chapter/Zabbix_MySQLdump_per_table.sh

#加载环境配置
source /etc/bashrc
source /etc/profile

#定义一些变量，包括数据库用户名、密码、端口、备份路径、日期
MySQL_USER=zabbix
MySQL_PASSWORD=zabbix
MySQL_HOST=localhost
MySQL_PORT=3306
MySQL_DUMP_PATH=/mysql_backup
MySQL_DATABASE_NAME=zabbix
DATE=$(date '+%Y-%m-%d')

#判断有备份路径，就进入，没有就创建，logs目录和日期目录也同样。
[ -d ${MySQL_DUMP_PATH} ] || mkdir ${MySQL_DUMP_PATH}
cd ${MySQL_DUMP_PATH}
[ -d logs    ] || mkdir logs
[ -d ${DATE} ] || mkdir ${DATE}
cd ${DATE}

#获取数据库中的表名，然后循环用mysqldump备份每个数据表。
TABLE_NAME_ALL=$(mysql -u${MySQL_USER} -p${MySQL_PASSWORD} -P${MySQL_PORT} -h${MySQL_HOST} ${MySQL_DATABASE_NAME} -e "show tables"|egrep -v "(Tables_in_zabbix|history*|trends*|acknowledges|alerts|auditlog|events|service_alarms)")
for TABLE_NAME in ${TABLE_NAME_ALL}
do
    mysqldump -u${MySQL_USER} -p${MySQL_PASSWORD} -P${MySQL_PORT} -h${MySQL_HOST} ${MySQL_DATABASE_NAME} ${TABLE_NAME} >${TABLE_NAME}.sql
    sleep 1
done

#根据结束标记，判断是否成功，并写入日志。
[ "$?" == 0 ] && echo "${DATE}: Backup zabbix succeed"     >> ${MySQL_DUMP_PATH}/logs/ZabbixMysqlDump.log
[ "$?" != 0 ] && echo "${DATE}: Backup zabbix not succeed" >> ${MySQL_DUMP_PATH}/logs/ZabbixMysqlDump.log

#删除5天前的备份数据
cd ${MySQL_DUMP_PATH}/
rm -rf $(date +%Y%m%d --date='5 days ago')
exit 0
