1、脚本用法
bestpay用户 cd /tools/scripts/ansible
python3.6 invscript.py -h
1）、查询某个分组中包含哪些主机,oracle_nj_all为inventory_group.py中的组名
python3.6 invscript.py --group oracle_nj_all
2）、查询所有
python3.6 invscript.py --list
3）、查询某分组主机中主机名,脚本也可以在play-book中使用-i指定inventory
ansible -i invscript.py mysql_nj_all -m shell -a "hostname"
2、更新数据库主机列表,sql中最好对ip进行去除空格并排序，否则可能会有warning
inventory_group.py中格式：
mygrp2就是ansible使用的组名
'ssh_user':'root'  root用户代表连到目标主机的用户。如果ansible server主机的test用户和目标的root用户有互信，那么ansible脚本在test用户下执行。
例子如下：
mygrp2 = {'sql':"""
select '1.1.3.8' as ips
union all
select '1.1.3.112' as ips
union all
select '1.1.3.113' as ips
""",
'ssh_user':'root'}