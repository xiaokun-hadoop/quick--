#####################################################################################################################
#####################################################################################################################
#####################################################################################################################

#####################################################################################################################
#################################################  任务完成率  ########################################################
#####################################################################################################################
########################## 任务完成率 = 当前时段完成的任务数 / 当前时段的总任务数  ##########################################

#####################################################################################################################
######################################### 当前时段完成的任务数  ########################################################
select sum(if(updated_date >=
              adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                             lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                             ':00'),
                      interval -15 minute)
                  and updated_date <=
                      adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                                     lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                                     ':00'),
                              interval -1 second)##时间限制
                  and state = 'DONE', 1, 0)) done_num,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval - 15 minute)         done_start_time,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval -1 second)           done_end_time,
       project_name,
       project_num
from picking_job_bi
group by project_num, project_name;

#####################################################################################################################

# ## 时间字段测试
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval -15 minute);
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval -1 second);

######################################################################################################################
######################################### 当前时段的总任务数  ###########################################################
select count(id)                    num_sum_all,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval -15 minute) done_start_time,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval -1 second)  done_end_time,
       project_name,
       project_num
from picking_job_bi
where created_date <
      adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                     ':00'),
              interval -15 minute) and state != 'done'
   or created_date >=
      adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                     ':00'),
              interval -15 minute) and
      created_date <=
      adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                     ':00'),
              interval -1 second)##时间限制
group by project_num, project_name;

#####################################################################################################################
######################################### 当前时段的任务完成率  ########################################################
#####################################################################################################################

select null,
       t1.done_num / t2.num_sum_all done_rate,
       t1.done_start_time,
       t1.done_end_time,
       t1.project_name,
       t1.project_num,
       now()
from (
         select sum(if(updated_date >=
                       adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                                      lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                                      ':00'),
                               interval -15 minute)
                           and updated_date <=
                               adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                                              lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                                              ':00'),
                                       interval -1 second)##时间限制
                           and state = 'DONE', 1, 0)) done_num,
                adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                               lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                               ':00'),
                        interval - 15 minute)         done_start_time,
                adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                               lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                               ':00'),
                        interval -1 second)           done_end_time,
                project_name,
                project_num
         from picking_job_bi
         group by  project_num, project_name
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
         group by project_num, project_name
     ) t2
     on t1.done_start_time = t2.done_start_time
         and t1.project_name = t2.project_name;


######################################################################################################################
######################################### 补充字段插入数据到picking_job_down_rate  ######################################
insert into picking_job_done_rate
select null,
       t1.done_num / t2.num_sum_all done_rate,
       t1.done_start_time,
       t1.done_end_time,
       t1.project_name,
       t1.project_num,
       now()
from (
         select sum(if(updated_date >=
                       adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                                      lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                                      ':00'),
                               interval -15 minute)
                           and updated_date <=
                               adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                                              lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                                              ':00'),
                                       interval -1 second)##时间限制
                           and state = 'DONE', 1, 0)) done_num,
                adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                               lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                               ':00'),
                        interval - 15 minute)         done_start_time,
                adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                               lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                               ':00'),
                        interval -1 second)           done_end_time,
                project_name,
                project_num
         from picking_job_bi
         group by  project_num, project_name
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
         group by project_num, project_name
     ) t2
     on t1.done_start_time = t2.done_start_time
         and t1.project_name = t2.project_name;

#####################################################################################################################
#################################################  历史任务完成率  ####################################################
#####################################################################################################################

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
group by project_name, project_num;

######################################################################################################################
#########################################  插入数据到picking_job_down_rate_avg  ########################################
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
group by project_name, project_num;

#####################################################################################################################
#####################################################################################################################

# ##  时间字段测试
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format('10:01:00', '%i') / 15) * 15, 2, '0'),
#                       ':00'), interval -1 minute);
# ##  针对当前时段进行测试
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval -15 minute);
#
# ##
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval -15 minute);
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0') + 14,
#                       ':59'),
#                interval -15 minute);

#####################################################################################################################
