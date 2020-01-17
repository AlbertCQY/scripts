#!/usr/bin/env python
# -*- coding:utf-8 -*-
import pymysql as db
import sys
import threading
import settings
class Mysql_Conn():
    def __init__(self,username,password,ip,port,dbname):

        try:
            self.con=db.connect(host=ip,port=port,user=username, passwd=password,db=dbname, charset='utf8', connect_timeout=20)               
            self.cur=self.con.cursor()
        except Exception as errmsg:
            print('connect error the error msg is:',str(errmsg))
            sys.exit()
        else:
            pass

    def execsql(self,sqltext,timeout=60):
        try:
            t=threading.Timer(timeout,self.cancel)#超时会执行函数cancel()
            t.start() #开始任务 开始计时
            self.cur.execute(sqltext)
            self.con.commit()
            t.cancel() #正常结束任务
        except Exception as errmsg:
            #语句执行失败或者超时
            return str(errmsg)
        else:
            #语句执行成功
            #(fetchone出来是一个元祖 返回第一行)  fetchall返回多行 是列表 列表的元素是元祖
            #dml和explain plan和存储过程都是返回None
            try:
                res = self.cur.fetchall()
            except:
                return None
            else:
                return res
        finally:
            try:
                t.cancel()
            except:
                pass
            else:
                pass



    def close_commit(self):#提交后关闭连接
        self.con.commit()
        self.cur.close()
        self.con.close()

    def close_rollback(self):#回滚后关闭连接
        self.con.rollback()
        self.cur.close()
        self.con.close()

    def cancel(self):
        self.con.cancel()#取消正在执行的sql 不做提交和回滚动作



if __name__ == '__main__':
    try:
       connection=Mysql_Conn(settings.my_usr,settings.my_pass,settings.my_ip,settings.my_port,settings.my_db)
    except Exception as err:
        print('+++++++++++++++++++++++++++++++++++++++++++++++')
        print("connect wrong",err)
    else:
        print('+++++++++++++++++++++++++++++++++++')
        print(connection.execsql("""SELECT '测试1','测试2' from t_hosts"""))
        connection.close_commit()
        #pass




