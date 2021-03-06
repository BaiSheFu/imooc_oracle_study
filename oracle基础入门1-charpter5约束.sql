--charpter5   约束

--主要约束的类型：（5个）
--非空约束
--主键约束
--外键约束
--唯一约束
--检查约束

--约束的作用：
--（1）定义规则
--（2）确保完整性


--1.非空约束
--在创建表时设置非空约束
--语法：
create table table_name(
    column_name datatype NOT NULL,
    ……
);
--实例：
create table userinfo_1(
    id number(6),
    username varchar2(20) not null,
    userpwd varchar2(20) not null
);
--此时如果插入数据的时候不给username和userpwd赋值，就会报错。

--修改表的时候添加非空约束
--语法：
alter table table_name modify column_name datatype NOT NULL;
--实例：
alter table userinfo modify username varchar2(20) not null;
--因为表里已经有数据且username字段有空值，所以会报错
--因此使用这条语句的时候最好是表里没有数据
--现在是实验的时候，可以先用delete from table清空表，再运行一遍

--在修改表的时候去除非空约束
--语法：
alter table table_name modify column_name datatype NULL;
--实例：
alter table userinfo modify username varchar2(20) null;


--2.主键约束
--作用：确保表当中每一行数据的唯一性
--设置为主键的字段必须非空切值唯一
--一张表只能设计一个主键约束
--主键约束可以由多个字段构成（联合主键或复合主键）

--在创建表的时候设置主键约束
--语法：
--第一种，直接在字段名后面添加primary key实现
create table table_name(
    column_name datatype PRIMARY KEY,
    ……
    ）
--实例：
create table userinfo_p(
    id number(6) primary key,
    username varchar2(20),
    userpwd varchar2(2)
);

--第二种，定义完所有字段后，通过constraint语句实现。--->表级约束
--联合主键/复合主键只能通过这种方式设置
create table table_name(
    column_name datatype,
    ……，
    constraint constraint_name primary key(column1,……）
        ）；
--实例：
create table userinfo_p1(
    id number(6),
    username varchar2(20),
    userpwd varchar2(20),
    constraint pk_id_username primary key(id,username)
);
--如果忘记了设置的约束的名称，或者没有设置约束名（oracle会自己帮我们创建）现在想知道这个主键的名称
--需要查看user_constraints表
desc user_constraints
select constraint_name from user_constraints where table_name='USERINFO_P1'; --PK_ID_USERNAME
select constraint_name from user_constraints where table_name='USERINFO_P';--SYS_C007334,换个地方执行就变了

--在修改表的时候添加主键
--语法：
--对于要设置为主键的字段，有值的话需要唯一。最好是还没有往表里面插入过值，
alter table table_name add constraint constraint_name primary key(column_name1,……）;
--实例：
alter table userinfo add constraint pk_id primary key(id);
--查看添加的约束
select constraint_name from user_constraints where table_name='USERINFO';--->PK_ID

--更改约束名
--语法：
alter table table_name rename constraint old_name to new_name;
--实例：
alter table userinfo rename constraint pk_id to new_pk_id;
--查看修改的约束名--
select constraint_name from user_constraints where table_name='USERINFO'; --->NEW_PK_ID

--删除约束
--暂时不想用，今后可能还会用
--语法：
alter table table_name disable|enable constraint constraint_name;
--实例：
alter table userinfo disable constraint new_pk_id;
--查看约束的状态信息，依然通过user_constraints查看
select constraint_name,status from user_constraints where table_name='USERINFO';

--这个约束就是不想要了，删掉
--语法：
alter table table_name drop constraint constraint_name;
--实例：
alter table userinfo drop constraint new_pk_id;
--由于每张表里只有一个主键约束，所以，如果删除的是主键约束，可以直接使用下面的语法
alter table table_name drop primary key[cascade];--cascade表示级联删除，在有外键约束的时候有用


--3.外键约束
--在创建表的时候设置外键约束
--语法
--第一种,创建表的时候直接在字段后使用references
create table table1(
    column_name datatype references table2(column_name),
    ……
)；
    --table1是从表，table2是主表
--设置外键约束时，references后面的table2的字段必须是table2的主键
--主从表中相应的字段必须是同一个数据类型
--从表中外键字段的值必须来自主表中相应字段的值，或者为null值。

--实例
--创建主表
create table typeinfo(
    typeid varchar2(10) primary key,
    typename varchar2(20)
);
--创建从表
create table userinfo_f (
    id varchar2(10) primary key,
    username varchar2(20),
    typeid_new varchar2(10) references typeinfo(typeid)
);
--插入数据实验
insert into typeinfo values(1,1);
insert into userinfo_f(id, typeid_new) values(1,2) --报错,ORA-02291: 违反完整约束条件 (SYSTEM.SYS_C007339) - 未找到父项关键字
--可以插入的值
insert into userinfo_f(id, typeid_new) values(1,null);
insert into userinfo_f(id, typeid_new) values(2,1);


--第二种,在定义玩所有字段后,接着使用constraint语句
create table table1(
    column_name datatype,
    ......
    constraint constraint_name foreign key(column_name) references table2(column_name)[on delete cascade]
)
--实例(续上面第二步)
create table userinfo_f2(
    id varchar2(10) primary key,
    username varchar2(20),
    typeid_new varchar2(10),
    constraint fk_typeid_new foreign key(typeid_new) references typeinfo(typeid) on delete cascade
);


--在修改表时添加外键约束
--语法
alter table table_name add constraint constraint_name foreign key(column_name references table_name(column_name) [on delete cascade];
--实例
create table userinfo_f4(
    id varchar2(10) primary key,
    username varchar2(20),
    typeid_new varchar2(20)
);

alter table userinfo_f4 
add constraint fk_typeid_alter foreign key(typeid_new) references typeinfo(typeid) on delete cascade;

--删除外键约束
--第一种,禁用外键约束
--语法:
alter table table_name disable|enable constraint constraint_name;
(通过user_constraints数据字典可以查看数据表中约束的名字,类型,状态等信息,
select constraint_name, constraint_type, status from user_constraints where table_name='USERINFO_F4';)  
--实例
alter table userinfo_f4 disable constraint FK_TYPEID_ALTER;
alter table userinfo_f4 enable constraint FK_TYPEID_ALTER;

--第二种,删除外键
--语法
alter table table_name drop constraint constraint_name;
--实例
alter table userinfo_f4 drop constraint FK_TYPEID_ALTER;
