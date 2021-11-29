# Mycat_config

## 文件结构

- processing.sh  --  执行脚本
- schema.xml.backup  --  源配置文件
- schema.xml  --  生成后配置文件

## 执行步骤

1. 运行脚本

   ```shell
   [root@s Mycat_config] ./processing.sh  opengauss配置文件  table配置文件 
   ```

   opengauss配置文件，格式如下：

   - 第一行：主机的个数

   - 其他行：顺序配置每对主备机（备机数量随意）

     - 第一个参数：1添加主机，2添加备机
     - 第二个参数：opengauss IP
     - 第三个参数：opengauss Port

   - 例如

   - ```txt
     2
     1 127.0.0.1 4321 
     2 127.0.0.2 4321
     2 127.0.0.3 4321
     2 127.0.0.4 4321
     1 127.0.0.11 4321 
     2 127.0.0.12 4321
     2 127.0.0.13 4321
     ```

   table配置文件：表名+节点

   例如

- ```shell
  table1 dn1
  table2 dn1
  table3 dn2
  ```

2. 生成的schema.xml挂载到mycat容器 /usr/local/mycat/conf/schema.xml

   /usr/local/mycat/conf/下还有其他配置文件，使用subpath指定子路径

   

3. 启动或者重启mycat

   ```shell
   docker exec -it $DOCKER_ID /bin/bash -c 'mycat start'
   docker exec -it $DOCKER_ID /bin/bash -c 'mycat restart'
   ```

   