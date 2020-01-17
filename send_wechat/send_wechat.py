#!/usr/bin/env python
# -*- coding: utf-8 -*-
# =========================================================================
"""
-- File Name : send_wechat.py
-- Purpose : 发微信模块
-- Date : 2020/01
-- Author:陈晴阳
Vervisons:
-- 20200106 1.0，陈晴阳，微信发送图片和文本的方法封装为模块
"""
# =========================================================================
import urllib.request
import json
import sys
import requests
import os
import settings

class WeChat():
    def __init__(self,agentid,corpid,secret,party = '1'):
        gettoken_url = 'https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid='+corpid+'&corpsecret='+secret
        self.token = self.gettoken(gettoken_url)
        self.post_url = 'https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=' + self.token+"&agentid="+agentid
        self.img_url = 'https://qyapi.weixin.qq.com/cgi-bin/media/upload'
        self.party = party
        if self.party == '1':
            self.message = {
                    "touser":"@all", #所有用户
                    #"totag":"1",       #标签ID  1
                    "msgtype":"text",
                    "agentid":agentid,  
                    "text":{"content":'NONE'},
                    "safe":0
                    }
            self.image = {
                    "touser":"@all", #所有用户
                    "msgtype":"image",
                    "agentid":agentid,  
                    "image": {"media_id":0},
                    "safe":0
                    }
        else:
            self.message = {
                    "toparty":self.party, #指定部门id的用户
                    #"totag":"1",       #标签ID  1
                    "msgtype":"text",
                    "agentid":agentid,  
                    "text":{"content":'NONE'},
                    "safe":0
                    }
            self.image = {
                    "toparty":self.party, #指定部门id的用户
                    "msgtype":"image",
                    "agentid":agentid,  
                    "image": {"media_id":0},
                    "safe":0
                    }

    def gettoken(self,gettoken_url):
        try:
            tokenresponse = urllib.request.urlopen(gettoken_url).read().decode()
        except  urllib.error.URLError as e:
            print("获取token错误",e)
        token = json.loads(tokenresponse)['access_token']
        return token

    def get_media_ID(self,path):
        payload_img={
                        'access_token':self.token,
                        'type':'image'
        }
        try:
        	data ={'media':open(path,'rb')}
        except Exception as err:
        	print('open file error ',err)
        
        try:
        	r=requests.post(url=self.img_url,params=payload_img,files=data)
        	#print 'get imageid  ok'
        except Exception as err:
        	print('get image id error ',err)
        dict =r.json()
                #print "=====",dict
        return dict['media_id']

    def send_messages(self,content):
        self.message['text']['content'] = content
        try:
            message_json = bytes(json.dumps(self.message), 'utf-8') #change to json bytes
            msg_response = urllib.request.urlopen(urllib.request.Request(url=self.post_url, data=message_json)).read()
            x = json.loads(msg_response.decode())['errcode']
            if x == 0:
                print('Send_Messages Succesfully')
            else:
                print('Send_Messages Failed')
        except Exception as e:
            print(e)
        return msg_response

    def send_images(self,media_id):
        self.image['image']['media_id'] = media_id
        try:
            main_messages = bytes(json.dumps(self.image),'utf-8')
            request = urllib.request.Request(self.post_url, main_messages)
            response = urllib.request.urlopen(request)
            msg = response.read()
        except Exception as e:
            logFile = open('send_wechat_pic.log','a')
            print(logFile,e)
            logFile.close()
            sys.exit()
        return msg

if __name__ == '__main__':
     # logFile1 = open('send_wechat_txt.log','a')
     # logFile2 = open('send_wechat_pic.log','a')
     GRAPH_PATH = "/tools/scripts/pic/"
     FileNames=os.listdir(GRAPH_PATH)
     wechat_sender = WeChat(settings.def_agentid,settings.def_corpid,settings.def_secret)#初始化对象
     try:
         content='测试'
         wechat_sender.send_messages(content)#调用方法发送信息 并返回信息
     except Exception as e1:
         print(e1)

     for i in range(len(FileNames)):#调用方法发送图片，并返回异常信息
        try:
             pic_path=GRAPH_PATH+FileNames[i]
             media_id = wechat_sender.get_media_ID(pic_path)
             wechat_sender.send_images(media_id)
        except Exception as e2:
          print(e2)



