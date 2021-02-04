####################################################################################################################
####################################################################################################################
####################################################################################################################

####################################################################################################################
#############################################  AGV即时状态  #########################################################
# 这个指标的要求数据每五分钟同步一次，且数据计算要安排在数据同步之后，整个过程要在五分钟内完成

####################################################################################################################
#
# ##时间字段测试
# select concat(date_format(now(), '%Y-%m-%d %H:'),
#               lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time;

####################################################################################################################
############################################  AGV总数  #############################################################

# select project_num,
#        project_name,
#        count(agv_num)                                                       agv_total,
#        concat(date_format(now(), '%Y-%m-%d %H:'),
#               lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
# from agv_status_info
# group by project_num, project_name, count_time;
#
# #####################################################################################################################
# ##########################################  AGV故障数  ###############################################################
#
# select project_num,
#        project_name,
#        count(agv_num)                                                       agv_error_num,
#        concat(date_format(now(), '%Y-%m-%d %H:'),
#               lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
# from agv_status_info
# where agv_status = 'ERROR'
# group by project_num, project_name, count_time;
#
# #####################################################################################################################
# ###########################################  AGV锁定数  ##############################################################
#
# select project_num,
#        project_name,
#        count(agv_num)                                                       agv_locked_num,
#        concat(date_format(now(), '%Y-%m-%d %H:'),
#               lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
# from agv_status_info
# where agv_status = 'LOCKED'
# group by project_num, project_name, count_time;
#
# #####################################################################################################################
# ###########################################  三表联查  ###############################################################
#
# select t1.count_time     count_time,
#        t1.agv_total      total_num,
#        t2.agv_error_num  error_num,
#        t3.agv_locked_num locked_num,
#        t1.project_name   project_name,
#        t1.project_num    project_num
# from (
#          select project_num,
#                 project_name,
#                 count(agv_num)                                                       agv_total,
#                 concat(date_format(now(), '%Y-%m-%d %H:'),
#                        lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
#          from agv_status_info
#          group by project_num, project_name, count_time
#      ) t1
#          join
#      (
#          select project_num,
#                 project_name,
#                 count(agv_num)                                                       agv_error_num,
#                 concat(date_format(now(), '%Y-%m-%d %H:'),
#                        lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
#          from agv_status_info
#          where agv_status = 'ERROR'
#          group by project_num, project_name, count_time
#      ) t2
#      on t1.count_time = t2.count_time and t1.project_name = t2.project_name
#          join
#      (
#          select project_num,
#                 project_name,
#                 count(agv_num)                                                       agv_locked_num,
#                 concat(date_format(now(), '%Y-%m-%d %H:'),
#                        lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time
#          from agv_status_info
#          where agv_status = 'LOCKED'
#          group by project_num, project_name, count_time
#      ) t3
#      on t1.count_time = t3.count_time and t1.project_name = t3.project_name;

######################################################################################################################
######################################################################################################################
############################################ 优化后  ##################################################################

select null,
       concat(date_format(now(), '%Y-%m-%d %H:'),
              lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time,
       count(agv_num)                                                       agv_total,
       sum(if(agv_status = 'ERROR', 1, 0))                                  agv_error_num,
       sum(if(agv_status = 'LOCKED', 1, 0))                                 agv_locked_num,
       project_num,
       project_name
from agv_status_info
group by project_num, project_name;

######################################################################################################################
#############################################  插入数据  ##############################################################

insert into agv_run_status
select null,
       concat(date_format(now(), '%Y-%m-%d %H:'),
              lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'), ':00') count_time,
       count(agv_num)                                                       agv_total,
       sum(if(agv_status = 'ERROR', 1, 0))                                  agv_error_num,
       sum(if(agv_status = 'LOCKED', 1, 0))                                 agv_locked_num,
       project_num,
       project_name

from agv_status_info
group by project_num, project_name;

######################################################################################################################
######################################################################################################################
