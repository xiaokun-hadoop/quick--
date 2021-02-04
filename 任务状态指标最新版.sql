#####################################################################################################################
#####################################################################################################################
#####################################################################################################################


#####################################################################################################################
#############################################  任务即时状态指标   ######################################################
#####################################################################################################################
## 总任务数/作业中任务数/排队中任务数/挂起任务数

select null,
       sum(if(state not in ('DONE', 'CANCEL'), 1, 0))                                          job_total_num,
       sum(if(state in ('INIT_JOB', 'GO_TARGET', 'WAITING_EXECUTOR', 'START_EXECUTOR'), 1, 0)) job_working_num,
       sum(if(state = 'WAITING_SUSPEND', 1, 0))                                                job_guaqi_num,
       sum(if(state in ('INIT', 'WAITING_RESOURCE', 'WAITING_NEXTSTOP', 'WAITING_AGV'), 1, 0)) job_waiting_num,
       project_num,
       project_name,
       concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'),
              ':00')                                                                           count_time
from picking_job_bi
group by project_num, project_name;

#####################################################################################################################
######################################### 插入数据到 picking_job_status  #############################################

insert into picking_job_status
select null,
       sum(if(state not in ('DONE', 'CANCEL'), 1, 0))                                          job_total_num,
       sum(if(state in ('INIT_JOB', 'GO_TARGET', 'WAITING_EXECUTOR', 'START_EXECUTOR'), 1, 0)) job_working_num,
       sum(if(state = 'WAITING_SUSPEND', 1, 0))                                                job_guaqi_num,
       sum(if(state in ('INIT', 'WAITING_RESOURCE', 'WAITING_NEXTSTOP', 'WAITING_AGV'), 1, 0)) job_waiting_num,
       project_num,
       project_name,
       concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 5) * 5, 2, '0'),
              ':00')                                                                           count_time,
       now()
from picking_job_bi
group by project_num, project_name;



#####################################################################################################################
######################################        任务状态指标       ######################################################
#####################################################################################################################

#####################################################################################################################
########################################  当前时段完成的任务数   ########################################################

# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 15 minute)         done_start_time,
#        adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 1 second)          done_end_time,
#        sum(if(updated_date >=
#               adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                              lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                              ':00'),
#                       interval -15 minute)
#                   and updated_date <=
#                       adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                      lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                      ':00'),
#                               interval -1 second)##时间限制
#                   and state = 'DONE', 1, 0)) done_num,
#        project_name,
#        project_num
# from picking_job_bi
# group by project_num, project_name;
#
# #####################################################################################################################
# ########################################   当前时段的总任务数   ########################################################
#
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 15 minute)                             done_start_time,
#        adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 1 second)                              done_end_time,
#        sum(if(created_date < adddate(
#                concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 15 minute) and state != 'DONE', 1, 0)) sum1, # create < 0 且未完成的
#        sum(if(created_date < adddate(
#                concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 15 minute) and updated_date >= adddate(
#                concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 15 minute) and updated_date <= adddate(
#                concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 1 second), 1, 0))                      sum2, # create < 0且 0 <= update < 15
#        sum(if(created_date >= adddate(
#                concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 15 minute) and created_date <= adddate(
#                concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 1 second), 1, 0))                      sum3, # 0 < create < 15
#        project_name,
#        project_num
# from picking_job_bi
# group by project_name, project_num;
#
# #####################################################################################################################
# #############################################   当前时段的总任务数   ###################################################
#
# select done_start_time,
#        done_end_time,
#        sum1 + sum2 + sum3 total_num,
#        project_name,
#        project_num
# from (
#          select adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 15 minute)                             done_start_time,
#                 adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 1 second)                              done_end_time,
#                 sum(if(created_date < adddate(
#                         concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 15 minute) and state != 'DONE', 1, 0)) sum1, # create < 0 且未完成的
#                 sum(if(created_date < adddate(
#                         concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 15 minute) and updated_date >= adddate(
#                         concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 15 minute) and updated_date <= adddate(
#                         concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 1 second), 1, 0))                      sum2, # create < 0且 0 <= update < 15
#                 sum(if(created_date >= adddate(
#                         concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 15 minute) and created_date <= adddate(
#                         concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 1 second), 1, 0))                      sum3, # 0 < create < 15
#                 project_name,
#                 project_num
#          from picking_job_bi
#          group by project_name, project_num
#      ) m1;
#
# #####################################################################################################################
# ##########################################   当前时段的挂起任务数  #####################################################
#
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 15 minute)                                      done_start_time,
#        adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 1 second)                                       done_end_time,
#        sum(if(updated_date >= adddate(
#                concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 15 minute) and updated_date <= adddate(
#                concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 1 second) and state = 'WAITING_SUSPEND', 1, 0)) guaqi_num,
#        project_name,
#        project_num
# from picking_job_bi
# group by project_name, project_num;
#
# ####################################################################################################################
# ########################################### 三表联查  ################################################################
#
# select null,
#        t1.total_num,
#        t2.done_num,
#        t3.guaqi_num,
#        t1.project_name,
#        t1.project_num,
#        t1.done_start_time,
#        t1.done_end_time,
#        now()
# from (
#          select done_start_time,
#                 done_end_time,
#                 sum1 + sum2 + sum3 total_num,
#                 project_name,
#                 project_num
#          from (
#                   select adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                         lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                         ':00'),
#                                  interval - 15 minute)                             done_start_time,
#                          adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                         lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                         ':00'),
#                                  interval - 1 second)                              done_end_time,
#                          sum(if(created_date < adddate(
#                                  concat(date_format(now(), '%Y-%m-%d %H:'),
#                                         lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                         ':00'),
#                                  interval - 15 minute) and state != 'DONE', 1, 0)) sum1, # create < 0 且未完成的
#                          sum(if(created_date < adddate(
#                                  concat(date_format(now(), '%Y-%m-%d %H:'),
#                                         lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                         ':00'),
#                                  interval - 15 minute) and updated_date >= adddate(
#                                  concat(date_format(now(), '%Y-%m-%d %H:'),
#                                         lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                         ':00'),
#                                  interval - 15 minute) and updated_date <= adddate(
#                                  concat(date_format(now(), '%Y-%m-%d %H:'),
#                                         lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                         ':00'),
#                                  interval - 1 second), 1, 0))                      sum2, # create < 0且 0 <= update < 15
#                          sum(if(created_date >= adddate(
#                                  concat(date_format(now(), '%Y-%m-%d %H:'),
#                                         lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                         ':00'),
#                                  interval - 15 minute) and created_date <= adddate(
#                                  concat(date_format(now(), '%Y-%m-%d %H:'),
#                                         lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                         ':00'),
#                                  interval - 1 second), 1, 0))                      sum3, # 0 < create < 15
#                          project_name,
#                          project_num
#                   from picking_job_bi
#                   group by project_name, project_num
#               ) m1
#      ) t1
#          join
#      (
#          select adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 15 minute)         done_start_time,
#                 adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 1 second)          done_end_time,
#                 sum(if(updated_date >=
#                        adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                       lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                       ':00'),
#                                interval -15 minute)
#                            and updated_date <=
#                                adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                               lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                               ':00'),
#                                        interval -1 second)##时间限制
#                            and state = 'DONE', 1, 0)) done_num,
#                 project_name,
#                 project_num
#          from picking_job_bi
#          group by done_start_time, project_num, project_name
#      ) t2 on t1.project_name = t2.project_name and t1.done_start_time = t2.done_start_time
#          join
#      (
#          select adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 15 minute)                                      done_start_time,
#                 adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 1 second)                                       done_end_time,
#                 sum(if(updated_date >= adddate(
#                         concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 15 minute) and updated_date <= adddate(
#                         concat(date_format(now(), '%Y-%m-%d %H:'),
#                                lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                                ':00'),
#                         interval - 1 second) and state = 'WAITING_SUSPEND', 1, 0)) guaqi_num,
#                 project_name,
#                 project_num
#          from picking_job_bi
#          group by project_name, project_num, done_start_time, done_end_time
#      ) t3 on t1.project_name = t2.project_name and t1.done_start_time = t2.done_start_time;
#
# select project_name,
#        sum(if(created_date > '2021-01-17 ,00:00:00' || updated_date < '2021-02-17 ,00:00:00', 1, 0))
# from picking_job_bi
# group by project_name;
#
# ###################################################################################################################
# ###############################################  优化后的任务总数  ###################################################
#
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'),############
#                       lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 15 minute)            done_start_time,
#        adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                       lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 1 second)             done_end_time,
#        sum(if(created_date < adddate(
#                concat(date_format(now(), '%Y-%m-%d %H:'),
#                       lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 15 minute) and state != 'DONE' ||
#               created_date < adddate(
#                       concat(date_format(now(), '%Y-%m-%d %H:'),
#                              lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                              ':00'),
#                       interval - 15 minute) and updated_date >= adddate(
#                       concat(date_format(now(), '%Y-%m-%d %H:'),
#                              lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                              ':00'),
#                       interval - 15 minute) and updated_date <= adddate(
#                       concat(date_format(now(), '%Y-%m-%d %H:'),
#                              lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                              ':00'),
#                       interval - 1 second) || created_date >= adddate(
#                    concat(date_format(now(), '%Y-%m-%d %H:'),
#                           lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                           ':00'),
#                    interval - 15 minute) and created_date <= adddate(
#                    concat(date_format(now(), '%Y-%m-%d %H:'),
#                           lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                           ':00'),
#                    interval - 1 second), 1, 0)) total_num,
#        project_name,
#        project_num
# from picking_job_bi
# group by project_name, project_num;

####################################################################################################################
####################################################################################################################
#########################################    最终sql   ##############################################################

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
group by project_name, project_num;

###################################################################################################################
########################################    插入数据     ###########################################################
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
group by project_name, project_num;



# ##############################################
# ## 当前时段的总任务数
# select count(id)                    num_sum_all,
#        adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval -15 minute) done_start_time,
#        adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval -1 second)  done_end_time,
#        project_name,
#        project_num
# from picking_job
# where created_date <
#       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                      ':00'),
#               interval -15 minute) and state != 'done'
#    or created_date >=
#       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                      ':00'),
#               interval -15 minute) and
#       created_date <=
#       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                      ':00'),
#               interval -1 second)##时间限制
# group by done_start_time, done_end_time, project_num, project_name;
