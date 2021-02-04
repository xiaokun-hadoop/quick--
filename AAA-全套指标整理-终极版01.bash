 
## 任务完成数
## 测试完成

#!/bin/bash

HOSTNAME="172.31.236.82"                                         #数据库信息
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="evo_wds_base"                                           #数据库名称

#插入数据
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "
insert into picking_job_done_num
select null,
       sum(if(adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                     ':00'), INTERVAL -15 minute) <= date_format(updated_date, '%Y-%m-%d %H:%i:%s')
  and adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                     ':00'), INTERVAL -1 second) >= date_format(updated_date, '%Y-%m-%d %H:%i:%s'),1,0)) done_num,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'), INTERVAL -15 minute) done_start_time,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'), INTERVAL -1 second)  done_end_time,
       project_name,
       project_num,
       now()
from picking_job_bi
group by project_name, project_num;
"


## 任务完成历史平均数
## 测试完成

#!/bin/bash

HOSTNAME="172.31.236.82"                                         #数据库信息
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="evo_wds_base"                                           #数据库名称

#插入数据
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "
insert into picking_job_done_num_avg
select
    null,
       avg(done_rate) done_rate_avg,
       done_start_time,
       done_end_time,
       project_name,
       project_num,
       now()
from (
         select null,
                done_rate,
                adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                               lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'), ':00'),
                        INTERVAL -15 minute) done_start_time,
                adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                               lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'), ':00'),
                        INTERVAL -1 second)  done_end_time,
                project_name,
                project_num
         from picking_job_done_rate
         WHERE date_format(done_start_time, '%Y-%m-%d') >=
               adddate(date_format(now(), '%Y-%m-%d'), interval -7 day)
           and date_format(done_start_time, '%Y-%m-%d') <=
               adddate(date_format(now(), '%Y-%m-%d'), interval -1 day)
           and date_format(adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                                          lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                                          ':00'), interval -15 minute),
                           '%H:%i:%s') = date_format(done_start_time, '%H:%i:%s')
     ) t1
group by done_start_time, done_end_time, project_name, project_num;
"


## 任务完成率
## 测试完成

#!/bin/bash

HOSTNAME="172.31.236.82"                                         #数据库信息
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="evo_wds_base"                                           #数据库名称

#插入数据
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "
insert into picking_job_done_rate
select null,
       t1.done_num / t2.num_sum_all  done_rate,
       t1.done_start_time,
       t1.done_end_time,
       t1.project_name,
       t1.project_num,
       now()
from (
         select sum(if(updated_date >=
      adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                     ':00'),
              interval -15 minute)
  and updated_date <=
      adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                     ':00'),
              interval -1 second)##时间限制
  and state = 'DONE',1,0))                     done_num,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval - 15 minute) done_start_time,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval -1 second)   done_end_time,
       project_name,
       project_num
from picking_job_bi
group by done_start_time, done_end_time, project_num, project_name
     ) t1
         join
     (
         select count(id)                    num_sum_all,
                adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                               lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                               ':00'),
                        interval -15 minute) done_start_time,
                adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                               lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                               ':00'),
                        interval -1 second)  done_end_time,
                project_name,
                project_num
         from picking_job_bi
         where created_date <
               adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                              lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                              ':00'),
                       interval -15 minute) and state != 'done'
            or created_date >=
               adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                              lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                              ':00'),
                       interval -15 minute) and
               created_date <=
               adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                              lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                              ':00'),
                       interval -1 second)##时间限制
         group by done_start_time, done_end_time, project_num, project_name
     ) t2
     on t1.done_start_time = t2.done_start_time
         and t1.project_name = t2.project_name;
"
		 
## 任务完成率历史平均值
## 测试完成

#!/bin/bash

HOSTNAME="172.31.236.82"                                         #数据库信息
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="evo_wds_base"                                           #数据库名称

#插入数据
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "
insert into picking_job_done_rate_avg
select
		null,
		avg(done_rate) done_rate_avg,
		done_start_time,
		done_end_time,
		project_name,
		project_num,
		now()
from 
(
select 
       done_rate,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),':00'),INTERVAL -15 minute ) done_start_time ,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),':00'),INTERVAL -1 second ) done_end_time ,
       project_name,
       project_num
from picking_job_done_rate
WHERE date_format(done_start_time, '%Y-%m-%d') >= adddate(date_format(now(), '%Y-%m-%d'), interval -7 day)
  and date_format(done_start_time, '%Y-%m-%d') <= adddate(date_format(now(), '%Y-%m-%d'), interval -1 day)
  and date_format(adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                                 lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'), ':00'), interval -15 minute),
                  '%H:%i:%s') = date_format(done_start_time, '%H:%i:%s')
) t1 
group by done_start_time, done_end_time, project_name, project_num;
"



## 任务平均耗时
## 测试完成

#!/bin/bash

HOSTNAME="172.31.236.82"                                         #数据库信息
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="evo_wds_base"                                           #数据库名称

#插入数据
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "
insert into picking_job_done_use_time
select null,
       avg(timestampdiff(minute, created_date,updated_date)) done_used_time,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),':00'),INTERVAL -15 minute ) done_start_time ,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),':00'),INTERVAL -1 second ) done_end_time ,
       project_name,
       project_num,
       now()
from picking_job_bi
where updated_date >=
      adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                     ':00'),
              interval -15 minute)
  and updated_date <=
      adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                     ':00'),
              interval -1 second)
group by done_start_time, done_end_time, project_name, project_num;
"


## 任务平均耗时历史平均值
## 测试完成

#!/bin/bash

HOSTNAME="172.31.236.82"                                         #数据库信息
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="evo_wds_base"                                           #数据库名称

#插入数据
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "
insert into picking_job_done_use_time_avg
SELECT NULL,
       avg(done_use_time) done_use_time_avg,
       done_start_time,
       done_end_time,
       project_name,
       project_num,
       now()
from (
         select done_use_time,
                adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                               lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                               ':00'), INTERVAL -15 minute) done_start_time,
                adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                               lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                               ':00'), INTERVAL -1 second)  done_end_time,
                project_name,
                project_num
         from picking_job_done_use_time
         WHERE date_format(done_start_time, '%Y-%m-%d') >= adddate(date_format(NOW(), '%Y-%m-%d'), interval -7 DAY)
           and date_format(done_start_time, '%Y-%m-%d') <= adddate(date_format(NOW(), '%Y-%m-%d'), interval -1 DAY)
           and date_format(adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                                          lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'), ':00'),
                                   interval -15 minute),
                           '%H:%i:%s') = date_format(done_start_time, '%H:%i:%s')
     ) t1
group by done_start_time, project_name, project_num;
"




## AGV即时状态
## 测试完成

#!/bin/bash

HOSTNAME="172.31.236.82"                                         #数据库信息
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="evo_wds_base"                                           #数据库名称

#插入数据
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "
insert into agv_run_status
select null,
       concat(date_format(now(), '%Y-%m-%d %H:'),
              lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time,
       count(agv_num)                                                       agv_total,
       sum(if(agv_status = 'ERROR', 1, 0))                                  agv_error_num,
       sum(if(agv_status = 'LOCKED', 1, 0))                                 agv_locked_num,
       project_name,
	   project_num

from agv_status_info
group by project_num, project_name, count_time;
"



## AGV运行状态
## 测试完成

#!/bin/bash

HOSTNAME="172.31.236.82"                                         #数据库信息
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="evo_wds_base"                                           #数据库名称

#插入数据
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "
insert into agv_run_info
select null,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                      lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00'), interval -15 minute) count_time,
       agv_type_code,
       sum(if(agv_status = 'ERROR', 1, 0))                                                                error_num,
       sum(if(online_status = 'REGISTERED', 1, 0))                                                        online_num,
       sum(if(agv_status = 'BUSY', 1, 0))                                                                 work_num,
       sum(if(agv_status = 'IDLE', 1, 0))                                                                 idle_num,
       sum(if(agv_status = 'CHARGING', 1, 0))                                                             charge_num,
       sum(if(agv_status = 'LOCKED', 1, 0))                                                               locked_num,
       t1.project_name                                                                                     project_name,
       t1.project_num                                                                                    project_num
from agv_status_info t1
         left join basic_agv t2
                   on t1.agv_num = t2.agv_code
group by project_num, project_name, count_time, agv_type_code;
"



## 任务即时状态
## 测试完成

#!/bin/bash

HOSTNAME="172.31.236.82"                                         #数据库信息
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="evo_wds_base"                                           #数据库名称

#插入数据
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "
insert into picking_job_status
select null,
       sum(if(state not in ('DONE', 'CANCEL'), 1, 0))                                          job_total_num,
       sum(if(state in ('INIT_JOB', 'GO_TARGET', 'WAITING_EXECUTOR', 'START_EXECUTOR'), 1, 0)) job_working_num,
       sum(if(state = 'WAITING_SUSPEND', 1, 0))                                                job_guaqi_num,
       sum(if(state in ('INIT', 'WAITING_RESOURCE', 'WAITING_NEXTSTOP', 'WAITING_AGV'), 1, 0)) job_waiting_num,
	   project_name,
       project_num,
       concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'),
              ':00')                                                                           count_time,
       now()
from picking_job_bi
group by project_num, project_name, count_time;
"



## 任务运行状态
## 测试完成

#!/bin/bash

HOSTNAME="172.31.236.82"                                         #数据库信息
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="evo_wds_base"                                           #数据库名称

#插入数据
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "
insert into picking_job_info
select null,
       sum(if(created_date < adddate(
               concat(date_format(now(), '%Y-%m-%d %H:'),
                      lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval - 15 minute) and state != 'DONE' ||
              created_date < adddate(
                      concat(date_format(now(), '%Y-%m-%d %H:'),
                             lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                             ':00'),
                      interval - 15 minute) and updated_date >= adddate(
                      concat(date_format(now(), '%Y-%m-%d %H:'),
                             lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                             ':00'),
                      interval - 15 minute) and updated_date <= adddate(
                      concat(date_format(now(), '%Y-%m-%d %H:'),
                             lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                             ':00'),
                      interval - 1 second) || created_date >= adddate(
                   concat(date_format(now(), '%Y-%m-%d %H:'),
                          lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                          ':00'),
                   interval - 15 minute) and created_date <= adddate(
                   concat(date_format(now(), '%Y-%m-%d %H:'),
                          lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                          ':00'),
                   interval - 1 second), 1, 0))                           total_num,
       sum(if(updated_date >=
              adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                             lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                             ':00'),
                      interval -15 minute)
                  and updated_date <=
                      adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                                     lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                                     ':00'),
                              interval -1 second)##时间限制
                  and state = 'DONE', 1, 0))                              done_num,
       sum(if(updated_date >= adddate(
               concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval - 15 minute) and updated_date <= adddate(
               concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval - 1 second) and state = 'WAITING_SUSPEND', 1, 0)) guaqi_num,
	   sum(if(state in ('INIT_JOB', 'GO_TARGET', 'WAITING_EXECUTOR', 'START_EXECUTOR'), 1, 0)) working_num,
       project_name,
       project_num,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                      lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval - 15 minute)                                      done_start_time,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                      lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval - 1 second)                                       done_end_time,
       now()
from picking_job_bi
group by project_name, project_num, done_start_time, done_end_time;
"




































































