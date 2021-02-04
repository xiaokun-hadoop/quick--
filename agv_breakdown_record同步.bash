id,time,agvId,breakdownId,errorCodes,x,y,speed,warehouse_id,warehouse_code,warehouse_name,bucketId,project_num,project_name

#!/bin/bash

 /opt/module/sqoop/bin/sqoop import \
--connect "jdbc:mysql://lanpi-rds.quicktron.com.cn:3306/evo_wds_base?useUnicode=true&characterEncoding=utf-8" \
--username quicktron \
--password kc87654321! \
--table agv_breakdown_record_where \
--target-dir /evo_wds_base/agv_breakdown_record \
--delete-target-dir \
--columns  id,time,agvId,breakdownId,errorCodes,x,y,speed,warehouse_id,warehouse_code,warehouse_name,bucketId,project_num,project_name \
--num-mappers 4 \
--split-by id \
--fields-terminated-by "\t"


#!/bin/bash

/opt/module/sqoop/bin/sqoop export \
--connect "jdbc:mysql://172.31.236.82:3306/evo_wds_base?useUnicode=true&characterEncoding=utf-8" \
--username root \
--password 123456 \
--table agv_breakdown_record \
--export-dir /evo_wds_base/agv_breakdown_record \
--m 4 \
--input-fields-terminated-by "\t" \
--update-mode allowinsert \
--update-key id 

#!/bin/bash

cd /opt/xxljob && nohup java  -XX:+UseG1GC -Xmx2048m    -Xms2048m     -jar  xxl-job-admin-2.3.0-SNAPSHOT.jar >/dev/null &

cd /opt/xxljob && nohup java  -XX:+UseG1GC -Xmx2048m    -Xms2048m     -jar   xxl-job-executor-sample-springboot-2.3.0-SNAPSHOT.jar >/dev/null &