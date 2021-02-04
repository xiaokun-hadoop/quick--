######################################################################################################################
######################################################################################################################
######################################################################################################################

######################################################################################################################
##############################################   任务完成数    #########################################################
######################################################################################################################
select null,
       sum(if(adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                             lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                             ':00'), INTERVAL -15 minute) <= date_format(updated_date, '%Y-%m-%d %H:%i:%s')
                  and adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                                     lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                                     ':00'), INTERVAL -1 second) >= date_format(updated_date, '%Y-%m-%d %H:%i:%s'), 1,
              0))                                  done_num,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'), INTERVAL -15 minute) done_start_time,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'), INTERVAL -1 second)  done_end_time,
       project_name,
       project_num,
       now()
from picking_job_bi
group by project_name, project_num;

##################################################################################################################
#########################################  插入数据到picking_job_down_num  #########################################
##################################################################################################################

insert into picking_job_done_num
select null,
       sum(if(adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                             lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                             ':00'), INTERVAL -15 minute) <= date_format(updated_date, '%Y-%m-%d %H:%i:%s')
                  and adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
                                     lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                                     ':00'), INTERVAL -1 second) >= date_format(updated_date, '%Y-%m-%d %H:%i:%s'), 1,
              0))                                  done_num,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'), INTERVAL -15 minute) done_start_time,
       adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
                      ':00'), INTERVAL -1 second)  done_end_time,
       project_name,
       project_num,
       now()
from picking_job_bi
group by project_name, project_num;

#####################################################################################################################
#####################################################################################################################

# ##  时间字段测试
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'), INTERVAL -15 minute);
# ##
# select adddate(concat(date_format(now(), '%Y-%m-%d %H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'),
#                       ':00'), INTERVAL -1 second);
# ##  针对当前时段进行测试
# ####################################################  错误形式  #######################################################
# select adddate(concat(date_format(now(), '%H:'), lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'), ':00'),
#                INTERVAL -15 minute);
# #####################################################################################################################
# select date_format(now(), '%H:%i:%s');
# select date_format(adddate(concat(date_format(now(), '%Y-%m-%d %H:'),
#                                   lpad(floor(date_format(now(), '%i') / 15) * 15, 2, '0'), ':00'), interval -15 minute),
#                    '%H:%i:%s');

####################################################################################################################
###########################################   历史七天任务完成数    ####################################################
####################################################################################################################

select null,
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
group by project_name, project_num;

##################################################################################################################
#########################################  插入数据到picking_job_down_num  #########################################
##################################################################################################################

insert into picking_job_done_num_avg
select null,
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
group by project_name, project_num;

#####################################################################################################################
#####################################################################################################################
