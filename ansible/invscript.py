#!/usr/bin/env python
#-*- coding: UTF-8 -*-
# =========================================================================
"""
-- File Name : invscript.py
-- Purpose : 从mysql数据中动态获取主机列表，动态inventory,不用维护主机列表
-- Date : 2020/01
-- Author:陈晴阳
Vervisons:
-- 20200106 1.0，陈晴阳，实现了动态获取主机列表，按照默认互信方式获取主机信息。
-- 20200116 2.0，陈晴阳，增加--group参数，并统计各个分组主机个数；重构了group_all 所有主机按照各组设置的互信用户来抓信息；增加对IP地址排序功能。
"""
# =========================================================================
import argparse
import sys
import json
import settings
import inventory_group as invgrp
from connect_mysql import Mysql_Conn


class DynamicInventory(object):

    def read_cli(self):
        parser = argparse.ArgumentParser()
        parser.add_argument('--host', nargs=1)
        parser.add_argument('--list', action='store_true')
        parser.add_argument('--group')
        self.options = parser.parse_args()

    def GetItemList(self):
        list_item = []
        for item in dir(invgrp):
            if not item.startswith("__"):
                list_item.append(item)
        return list_item

    def GetGrpList(self):
        list_grpinfo = []
        list_item = self.GetItemList()
        for item in list_item:
            itemcontent = getattr(invgrp, item)
            tmp_dic = {}
            tmp_dic[item] = itemcontent
            list_grpinfo.append(tmp_dic)
        return list_grpinfo

    def get_groups(self):
        hostgroups = self.GetGrpList()
        #allhost = []
        for hostdic in hostgroups:#hostgroup为字典
            for hostgroup in hostdic: #获取字典的key
                self.result[hostgroup] = {}
                v_sql = hostdic[hostgroup]['sql'] #获取sql
                v_ssh_user = hostdic[hostgroup]['ssh_user']  # 获取sql
                hosts = self.connection.execsql(v_sql)
                #print(hosts)
                # 构建每个分组
                grp_host_list = [host[0] for host in hosts]
                grp_host_list = sorted(grp_host_list, key=lambda x: (int(x.split('.')[0]), int(x.split('.')[1]), int(x.split('.')[2]))) #排序
                self.result[hostgroup]['hosts'] =  grp_host_list
                self.result[hostgroup]['vars'] = {'ansible_ssh_user': v_ssh_user}
                #构建_meta,注意ip为元组，需要做个小转换ip[0] 需要字符串值
                for ip in hosts:
                    tmp_dic = {}
                    tmp_dic['ansible_ssh_host'] = ip[0]
                    self.result['_meta']['hostvars'][ip[0]] = tmp_dic
        # 构建group_all
        self.result[self.defaultgroup]['hosts']=[]
        self.result[self.defaultgroup]['children'] =self.GetItemList()
        return self.result

    def get_host(self,ipaddr):
        ip = ''
        for i in ipaddr:
            ip = i
        data = {'ansible_ssh_host': ip}
        return data

    def get_group_hosts(self,grpname):
        if grpname == 'group_all':
            allhosts = []
            #查询出来所有的主机列表
            hostgroups = self.GetGrpList()
            for hostdic in hostgroups:  # hostgroup为字典
                for hostgroup in hostdic:  # 获取字典的key
                    v_sql = hostdic[hostgroup]['sql']  # 获取sql
                    hosts = self.connection.execsql(v_sql)
                    allhosts.extend([host[0] for host in hosts])

            allhosts = set(allhosts)  # 去重
            allhosts = sorted(allhosts, key=lambda x: (int(x.split('.')[0]), int(x.split('.')[1]), int(x.split('.')[2]))) #排序
            cnt = 0
            for i in allhosts:
                print(cnt + 1, i)
                cnt = cnt + 1
            print('Group ' + grpname + ' Total hosts:', cnt)
        else:
            txt_grp ='invgrp.'+grpname+"""['sql']"""
            v_sql = eval(txt_grp) #这里偷懒用了邪恶函数eval
            hosts = self.connection.execsql(v_sql)
            cnt = 0
            for i in hosts:
                print(cnt + 1,i[0])
                cnt = cnt + 1
            print('Group '+grpname+' Total hosts:',cnt)


    def __init__(self):

        try:
            self.connection = Mysql_Conn(settings.my_usr, settings.my_pass, settings.my_ip, settings.my_port, settings.my_db)
        except Exception as err:
            print("connect wrong", err)
        self.defaultgroup = 'group_all'
        self.options = None
        self.read_cli()

        self.result = {}
        self.result[self.defaultgroup] = {}
        self.result[self.defaultgroup]['hosts'] = []
        self.result[self.defaultgroup]['vars'] = {'ansible_ssh_user': 'bestpay'}
        self.result['_meta'] = {}
        self.result['_meta']['hostvars'] = {}

        if self.options.host:
            data = self.get_host(self.options.host)
            print(json.dumps(data,indent=4))
        elif self.options.list:
            data = self.get_groups()
            print(json.dumps(data,indent=4))
        elif self.options.group:
            data = self.get_group_hosts(self.options.group)
        else:
            sys.exit("usage: --list or --host HOSTNAME or --group GROUPNAME")

if __name__ == '__main__':
    DynamicInventory()
