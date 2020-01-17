#!/usr/bin/python
# -*- coding: UTF-8 -*-

# =========================================================================
"""
-- File Name : send_mail.py
-- Purpose : 发邮件模块
-- Date : 2020/01
-- Author:陈晴阳
Vervisons:
-- 20200106 1.0，陈晴阳，邮件发送文本和附件的方法封装为模块
"""
# =========================================================================

import smtplib
import check
import settings
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
from email.header import Header

def GetMaillist(maillist='mail_list_dba'):
    checkobj = check.CheckMy(settings.my_db,settings.my_usr,settings.my_pass,settings.my_ip,settings.my_port,settings.my_db)
    # db_name,dbausername,dbapassword,ip,port,servicename
    maillist_return = checkobj.QuerySQL(maillist)
    checkobj.finish_check()
    list_return_detail = []
    if maillist_return:
        for i1 in maillist_return[maillist]:
            list_return_detail.append(i1[0])
    return list_return_detail

class Mails():
    def __init__(self,mail_host,mail_user,mail_pass,mail_port):
        self.smtpObj = smtplib.SMTP()
        self.smtpObj.connect(mail_host,mail_port)
        self.smtpObj.login(mail_user,mail_pass)
        #获取收件人列表
        self.mailsender = mail_user
        self.list_receivers = GetMaillist(maillist='mail_list_dba')
        self.str_receivers = ",".join(str(i) for i in self.list_receivers)
    def SendMail(self,mail_title,msgs,cc_list=None,msgfile=None,attach_files=None):
        """
        1、邮件标题['Subject']
        2、发件人['From'] 收件人['To'] 抄送['Cc']
        3、邮件内容MIMEText，可以读取html文本
        4、附件，excel、mp3、pdf
        :return:
        """
        mailmsg = MIMEMultipart()
        mailmsg['Subject'] = Header(mail_title, 'utf-8')
        mailmsg['From'] = Header(self.mailsender, 'utf-8')
        mailmsg['To'] = Header(self.str_receivers, 'utf-8')
        if cc_list != None:
            mailmsg['Cc'] = Header(cc_list, 'utf-8')
        #处理邮件正文内容
        puretext = MIMEText('<h8><br/>'+msgs+'</h8>','html','utf-8')  # 正文支持html格式 '<h1>没有收集的表如下: <br/>' + 邮件内容 + '</h1>', 'html', 'utf-8'
        mailmsg.attach(puretext)
        if msgfile != None:
            fp = open(msgfile,'rb') #只支持读取html格式
            msghtml = MIMEText(fp.read(),'html','utf-8')
            fp.close()
            mailmsg.attach(msghtml)
        if attach_files != None:
            listfiles = attach_files.split(',')
            for f1 in listfiles:
                fpart = MIMEApplication(open(f1, 'rb').read())
                fpart.add_header('Content-Disposition', 'attachment', filename=f1)
                mailmsg.attach(fpart)
        #发送邮件
        try:
            if self.list_receivers:
                pass
            else:
                print('收件人不存在')
            self.smtpObj.sendmail(self.mailsender, self.list_receivers, mailmsg.as_string())
            print("邮件发送成功")
        except smtplib.SMTPException as err:
            print("Error: 无法发送邮件", err)
    
if __name__ == '__main__':
    myemail = Mails(mail_host = settings.mail_host,mail_user = settings.mail_user,mail_pass = settings.mail_pass,mail_port = settings.mail_port) #初始化
    #SendMail(self,mail_title,msgs,cc_list=None,msgfile=None,attach_files=None)
    txt_title = '我的邮件测试'
    txt_msgs = '陈某的邮件正文:'
    txt_cc = 'chenask@163.com,123456@qq.com'
    myemail.SendMail(mail_title = txt_title,msgs=txt_msgs,cc_list=txt_cc,msgfile='storage_report_HtmlResult.html',attach_files='storage_report_HtmlResult.html,storage_report_ImageResult.png')
