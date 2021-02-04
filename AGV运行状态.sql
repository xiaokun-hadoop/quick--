#####################################################################################################################
###########################################    AGV运行状态  ##########################################################
#####################################################################################################################
#
# #####################################################################################################################
# ############################################  状态为 IDLE的数量  ######################################################
#
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                       lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00'),
#                interval -5 minute) count_start_time,
#        count(id)                   IDLE_num,
#        project_name,
#        project_num
# from agv_status_info
# where agv_status = 'IDLE'
# group by count_start_time, project_name, project_num;
#
# #####################################################################################################################
# ########################################### 状态为 CHARGING 的数量  ###################################################
#
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                       lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00'),
#                interval -5 minute) count_start_time,
#        count(id)                   CHARGING_num,
#        project_name,
#        project_num
# from agv_status_info
# where agv_status = 'CHARGING'
# group by count_start_time, project_name, project_num;
#
#
# #####################################################################################################################
# #############################################  状态为 BUSY 的数量  ####################################################
#
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                       lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00'),
#                interval -5 minute) count_start_time,
#        count(id)                   BUSY_num,
#        project_name,
#        project_num
# from agv_status_info
# where agv_status = 'BUSY'
# group by count_start_time, project_name, project_num;
#
# #####################################################################################################################
# ############################################ online_num 在线  ########################################################
#
# select project_num,
#        project_name,
#        count(agv_num)                                                       online_num,
#        concat(date_format(now(), '%Y-%m-%d %H:'),
#               lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
# from agv_status_info
# where online_status = 'REGISTERED'
# group by project_num, project_name, count_time;
#
# #####################################################################################################################
# ########################################### outline_num 离线  ########################################################
#
# select project_num,
#        project_name,
#        count(agv_num)                                                       outline_num,
#        concat(date_format(now(), '%Y-%m-%d %H:'),
#               lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
# from agv_status_info
# where online_status = 'UNREGISTERED'
# group by project_num, project_name, count_time;
#
# #####################################################################################################################
# ########################################### agv_type_code 机型  ######################################################
#
# select t1.project_name,
#        t1.project_num,
#        t2.agv_type_code                                                     agv_type_code,
#        concat(date_format(now(), '%Y-%m-%d %H:'),
#               lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
# from agv_status_info t1
#          left join basic_agv t2
#                    on t1.agv_num = t2.agv_code
# group by t1.project_name, t1.project_num, agv_type_code, count_time;
#
# ######################################################################################################################
# #######################################  error_num 故障数  ############################################################
#
# select project_num,
#        project_name,
#        count(agv_num)                                                       error_num,
#        concat(date_format(now(), '%Y-%m-%d %H:'),
#               lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
# from agv_status_info
# where agv_status = 'ERROR'
# group by project_num, project_name, count_time;
#
# ######################################################################################################################
# ######################################  work_num 工作数  ##############################################################
#
# select project_num,
#        project_name,
#        count(agv_num)                                                       work_num,
#        concat(date_format(now(), '%Y-%m-%d %H:'),
#               lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
# from agv_status_info
# where agv_status = 'BUSY'
# group by project_num, project_name, count_time;
#
# ######################################################################################################################
# ############################################# idle_num 空闲  ##########################################################
#
# select project_num,
#        project_name,
#        count(agv_num)                                                       idle_num,
#        concat(date_format(now(), '%Y-%m-%d %H:'),
#               lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
# from agv_status_info
# where agv_status = 'IDLE'
# group by project_num, project_name, count_time;
#
# ######################################################################################################################
# ##** charge_num 充电
#
# select project_num,
#        project_name,
#        count(agv_num)                                                       charge_num,
#        concat(date_format(now(), '%Y-%m-%d %H:'),
#               lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
# from agv_status_info
# where agv_status = 'CHARGING'
# group by project_num, project_name, count_time;
#
# #####################################################################################################################
# ##** locked_num 锁定
#
# select project_num,
#        project_name,
#        count(agv_num)                                                       locked_num,
#        concat(date_format(now(), '%Y-%m-%d %H:'),
#               lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
# from agv_status_info
# where agv_status = 'LOCKED'
# group by project_num, project_name, count_time;
#
# ###################################################################################################################
# ###################################################################################################################
# ##最后sql
# select m1.project_num,
#        m1.project_name,
#        m1.count_time,
#        m1.online_num,
#        m2.outline_num,
#        m3.agv_type_code,
#        m4.error_num,
#        m5.work_num,
#        m6.idle_num,
#        m7.charge_num,
#        m8.locked_num
# from (
#          select project_num,
#                 project_name,
#                 count(agv_num)                                                       online_num,
#                 concat(date_format(now(), '%Y-%m-%d %H:'),
#                        lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
#          from agv_status_info
#          where online_status = 'REGISTERED'
#          group by project_num, project_name, count_time
#      ) m1
#          join
#      (
#          select project_num,
#                 project_name,
#                 count(agv_num)                                                       outline_num,
#                 concat(date_format(now(), '%Y-%m-%d %H:'),
#                        lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
#          from agv_status_info
#          where online_status = 'UNREGISTERED'
#          group by project_num, project_name, count_time
#      ) m2 on m1.project_num = m2.project_num and m1.count_time = m2.count_time
#          join
#      (
#          select t1.project_name,
#                 t1.project_num,
#                 t2.agv_type_code                                                     agv_type_code,
#                 concat(date_format(now(), '%Y-%m-%d %H:'),
#                        lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
#          from agv_status_info t1
#                   left join basic_agv t2
#                             on t1.agv_num = t2.agv_code
#          group by t1.project_name, t1.project_num, agv_type_code, count_time
#      ) m3 on m1.project_num = m3.project_num and m1.count_time = m3.count_time
#          join
#      (
#          select project_num,
#                 project_name,
#                 count(agv_num)                                                       error_num,
#                 concat(date_format(now(), '%Y-%m-%d %H:'),
#                        lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
#          from agv_status_info
#          where agv_status = 'ERROR'
#          group by project_num, project_name, count_time
#      ) m4 on m1.project_num = m4.project_num and m1.count_time = m4.count_time
#          join
#      (
#          select project_num,
#                 project_name,
#                 count(agv_num)                                                       work_num,
#                 concat(date_format(now(), '%Y-%m-%d %H:'),
#                        lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
#          from agv_status_info
#          where agv_status = 'BUSY'
#          group by project_num, project_name, count_time
#      ) m5 on m1.project_num = m5.project_num and m1.count_time = m5.count_time
#          join
#      (
#          select project_num,
#                 project_name,
#                 count(agv_num)                                                       idle_num,
#                 concat(date_format(now(), '%Y-%m-%d %H:'),
#                        lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
#          from agv_status_info
#          where agv_status = 'IDLE'
#          group by project_num, project_name, count_time
#      ) m6 on m1.project_num = m6.project_num and m1.count_time = m6.count_time
#          join
#      (
#          select project_num,
#                 project_name,
#                 count(agv_num)                                                       charge_num,
#                 concat(date_format(now(), '%Y-%m-%d %H:'),
#                        lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
#          from agv_status_info
#          where agv_status = 'CHARGING'
#          group by project_num, project_name, count_time
#      ) m7 on m1.project_num = m7.project_num and m1.count_time = m7.count_time
#          join
#      (
#          select project_num,
#                 project_name,
#                 count(agv_num)                                                       locked_num,
#                 concat(date_format(now(), '%Y-%m-%d %H:'),
#                        lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
#          from agv_status_info
#          where agv_status = 'LOCKED'
#          group by project_num, project_name, count_time
#      ) m8 on m1.project_num = m8.project_num and m1.count_time = m8.count_time;

#################################################################################################################
###########################################    AGV运行状态  ######################################################
#################################################################################################################

### 优化后的sql

select t1.project_num                                                                                     project_num,
       t1.project_name                                                                                    project_name,
       agv_type_code,
       sum(if(online_status = 'REGISTERED', 1, 0))                                                        online_num,
       sum(if(online_status = 'UNREGISTERED', 1, 0))                                                      outline_num,
       sum(if(agv_status = 'ERROR', 1, 0))                                                                error_num,
       sum(if(agv_status = 'BUSY', 1, 0))                                                                 work_num,
       sum(if(agv_status = 'IDLE', 1, 0))                                                                 idle_num,
       sum(if(agv_status = 'CHARGING', 1, 0))                                                             charge_num,
       sum(if(agv_status = 'LOCKED', 1, 0))                                                               locked_num,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                      lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00'), interval -15 minute) count_time
from agv_status_info t1
         left join basic_agv t2
                   on t1.agv_num = t2.agv_code
group by project_num, project_name, agv_type_code;

####################################################################################################################
###########################################  插入数据  ##############################################################

insert into agv_run_info
select null,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                      lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00'), interval -15 minute) count_time,
       agv_type_code,
       sum(if(agv_status = 'ERROR', 1, 0))                                                                error_num,
       sum(if(online_status = 'REGISTERED', 1, 0))                                                        online_num,
       sum(if(online_status = 'UNREGISTERED', 1, 0))                                                      outline_num,
       sum(if(agv_status = 'BUSY', 1, 0))                                                                 work_num,
       sum(if(agv_status = 'IDLE', 1, 0))                                                                 idle_num,
       sum(if(agv_status = 'CHARGING', 1, 0))                                                             charge_num,
       sum(if(agv_status = 'LOCKED', 1, 0))                                                               locked_num,
       t1.project_num                                                                                     project_num,
       t1.project_name                                                                                    project_name
from agv_status_info t1
         left join basic_agv t2
                   on t1.agv_num = t2.agv_code
group by project_num, project_name, agv_type_code;

######################################################################################################################
######################################################################################################################



































