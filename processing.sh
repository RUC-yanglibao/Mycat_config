#!/bin/sh
# author yanglibao

database=postgres
user=gaussdb
password=Enmo@123

# 增加主机
add_master(){
    master_position=${1}
	string="\\\t\t<writeHost host=\"hostM${2}_1\" url=\"jdbc:postgresql://${4}:${5}/$database\" user=\"$user\" password=\"$password\">"
    sed -i "${master_position}a${string}" ./schema.xml
	let master_position++
	sed -i "${master_position}a\\\t\t</writeHost>" ./schema.xml
    #echo "host($IP) is added successfully."
    let position++
}
# 增加备机
add_slave(){
    slave_position=${1}
    string="\\\t\t\t<readHost host=\"hostS${2}_${3}\" url=\"jdbc:postgresql://${5}:${6}/$database\" user=\"$user\" password=\"$password\"/>"
    sed -i "${slave_position}a${string}" ./schema.xml
	#echo "hostS$slave_sequence($IP) is added successfully."
    let position++
}
# 增加talbe
add_table(){
    string="\\\t\t\t<table name=\"${2}\" dataNode=\"${3}\" fetchStoreNodeByJdbc=\"true\"/>"
    sed -i "${1}a${string}" ./schema.xml
}

# 创建schema.xml
cp schema.xml.backup schema.xml

table_position=$(sed -n '/randomDataNode/=' ./schema.xml)
# 增加table标签
cat $2 | while IFS='\n' read line; 
do 
    add_table $table_position $line;
    let table_position++ 
done; 

# 增加dataNode标签
dataNode_number=$(head -n 1 $1)
position=$(sed -n '/<\/schema>/=' ./schema.xml)
for ((i=1;i<=$dataNode_number;i++));
do
    let position++
    string="\\\t<dataNode name=\"dn$i\" dataHost=\"jdbchost$i\" database=\"gaussdb\"/>"
    sed -i "${position}a${string}" ./schema.xml
done
let position++
let position++

# 传入配置文件的游标
config_position=2
# dataNode标签第一行游标
dataNode_position=$position

# 添加主机数量
i=0
# 添加备机数量
j=0

while ((i<=$dataNode_number))
do
    mark=$(awk 'NR=='$config_position'{print $1}' $1)
    if [ "$mark" = "1" ];
    then
        let i++
        j=0
        # 添加dataHost标签
        string1="\\\t<dataHost name=\"jdbchost$i\" maxCon=\"1000\" minCon=\"10\" balance=\"3\" writeType=\"0\" dbType=\"postgresql\" dbDriver=\"jdbc\" switchType=\"1\"  slaveThreshold=\"100\">"
        string2="\\\t\t<heartbeat>select user</heartbeat>"
        string3="\\\t</dataHost>"
        sed -i "${position}a${string1}" ./schema.xml
        let position++
        sed -i "${position}a${string2}" ./schema.xml
        let position++
        sed -i "${position}a${string3}" ./schema.xml
        let position+=2

        dataNode_position=$(sed -n '/<dataHost name="jdbchost'$i'"/=' ./schema.xml)
        let dataNode_position++
        add_master $dataNode_position $i $(sed -n ''${config_position}'p' $1)
        let dataNode_position++
    elif [ "$mark" = "2" ];
    then
        let j++
        add_slave $dataNode_position $i $j $(sed -n ''${config_position}'p' $1)
        let dataNode_position++
    else 
        break
    fi
    let config_position++
done


