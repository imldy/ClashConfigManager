#!/bin/bash

yq="bin/yq"
UA="ClashConfigManager"

# 定义函数
readConfig(){
  # 读取配置
  SubURL=`$yq '.URL' umConfig.yaml`
  ConfigFile=`$yq '.FilePath' umConfig.yaml`
}
download(){
  # 下载订阅作为配置文件
  curl -A ${UA} ${1} -o ${2}
}
merge(){
  # 合并配置
  $yq -i '. += load("mixin/general.yaml")' ${1}
  # 使用自定义的DNS配置项对原有配置项进行覆盖
  $yq -i '.dns += load("mixin/dns.yaml")' ${1}
  # 使用自定义的tun配置项对原有配置项进行覆盖
  $yq -i '.tun += load("mixin/tun.yaml")' ${1}
  # 插入多个rule到rules列表头部
  $yq -i '.rules = load("mixin/rules.yaml") + .rules' ${1}
}
# 执行
readConfig
download ${SubURL} ${ConfigFile}
merge ${ConfigFile}
