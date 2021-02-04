####################################################################################################################
#################################################  任务平均耗时  #####################################################
#################################################    15分钟版   #####################################################
####################################################################################################################


####################################################################################################################
#########################################  当前时间段任务平均耗时  #####################################################
####################################################################################################################

select null,
       avg(timestampdiff(second, created_date, updated_date)) done_used_time,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval -15 minute)                           done_start_time,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval -1 second)                            done_end_time,
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
group by project_name, project_num;


#####################################################################################################################
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval -15 minute);
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval -1 second);
#####################################################################################################################

#####################################################################################################################
#########################################  插入数据到表  ##############################################################

insert into picking_job_done_use_time
select null,
       avg(timestampdiff(second, created_date, updated_date)) done_used_time,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval -15 minute)                           done_start_time,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'),
               interval -1 second)                            done_end_time,
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
group by project_name, project_num;

##################################################################################################################
#################################################  历史任务平均耗时  ###############################################
##################################################################################################################

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
group by project_name, project_num;

###################################################################################################################
######################################### 插入数据到表  #############################################################

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
group by project_name, project_num;


###################################################################################################################
# ###时间测试字段
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval - 15 minute);
# select adddate(
#                concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0') + 14,
#                       ':59'),
#                interval - 15 minute);
#
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'),
#                interval -15 minute);
#
# select date_format(adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                   lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'), ':00'), interval -15 minute),
#                    '%H:%i:%s');
# select date_format(now(), '%H:%i:%s');
###################################################################################################################