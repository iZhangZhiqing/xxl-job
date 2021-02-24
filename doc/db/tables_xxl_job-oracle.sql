-- 1. create table
-- drop table XXL_JOB_INFO;
-- drop table XXL_JOB_LOG;
-- drop table XXL_JOB_LOG_REPORT;
-- drop table XXL_JOB_LOGGLUE;
-- drop table XXL_JOB_REGISTRY;
-- drop table XXL_JOB_GROUP;
-- drop table XXL_JOB_USER;
-- drop table XXL_JOB_LOCK;

CREATE TABLE xxl_job_info
(
    id                        NUMBER(20, 0)                       NOT NULL,
    job_group                 NUMBER(20, 0)                       NOT NULL,
    job_desc                  VARCHAR2(510)                       NOT NULL,
    add_time                  DATE           DEFAULT NULL         NULL,
    update_time               DATE           DEFAULT NULL         NULL,
    author                    VARCHAR2(64)   DEFAULT NULL         NULL,
    alarm_email               VARCHAR2(255)  DEFAULT NULL         NULL,
    schedule_type             VARCHAR2(100)  DEFAULT 'NONE'       NOT NULL,
    schedule_conf             VARCHAR2(256)  DEFAULT NULL         NULL,
    misfire_strategy          VARCHAR2(100)  DEFAULT 'DO_NOTHING' NOT NULL,
    executor_route_strategy   VARCHAR2(100)  DEFAULT NULL         NULL,
    executor_handler          VARCHAR2(510)  DEFAULT NULL         NULL,
    executor_param            VARCHAR2(1024) DEFAULT NULL         NULL,
    executor_block_strategy   VARCHAR2(100)  DEFAULT NULL         NULL,
    executor_timeout          NUMBER(11, 0)  DEFAULT 0            NOT NULL,
    executor_fail_retry_count NUMBER(11, 0)  DEFAULT 0            NOT NULL,
    glue_type                 VARCHAR2(100)                       NOT NULL,
    glue_source               CLOB           DEFAULT NULL         NULL,
    glue_remark               VARCHAR2(256)  DEFAULT NULL         NULL,
    glue_updatetime           DATE           DEFAULT NULL         NULL,
    child_jobid               VARCHAR2(255)  DEFAULT NULL         NULL,
    trigger_status            NUMBER(4, 0)   DEFAULT 0            NOT NULL,
    trigger_last_time         NUMBER(20, 0)  DEFAULT 0            NOT NULL,
    trigger_next_time         NUMBER(20, 0)  DEFAULT 0            NOT NULL,
    PRIMARY KEY (id)
)
    NOCOMPRESS
    NOPARALLEL;
COMMENT ON COLUMN xxl_job_info.job_group IS '执行器主键ID';
COMMENT ON COLUMN xxl_job_info.author IS '作者';
COMMENT ON COLUMN xxl_job_info.alarm_email IS '报警邮件';
COMMENT ON COLUMN xxl_job_info.schedule_type IS '调度类型';
COMMENT ON COLUMN xxl_job_info.schedule_conf IS '调度配置，值含义取决于调度类型';
COMMENT ON COLUMN xxl_job_info.misfire_strategy IS '调度过期策略';
COMMENT ON COLUMN xxl_job_info.executor_route_strategy IS '执行器路由策略';
COMMENT ON COLUMN xxl_job_info.executor_handler IS '执行器任务handler';
COMMENT ON COLUMN xxl_job_info.executor_param IS '执行器任务参数';
COMMENT ON COLUMN xxl_job_info.executor_block_strategy IS '阻塞处理策略';
COMMENT ON COLUMN xxl_job_info.executor_timeout IS '任务执行超时时间，单位秒';
COMMENT ON COLUMN xxl_job_info.executor_fail_retry_count IS '失败重试次数';
COMMENT ON COLUMN xxl_job_info.glue_type IS 'GLUE类型';
COMMENT ON COLUMN xxl_job_info.glue_source IS 'GLUE源代码';
COMMENT ON COLUMN xxl_job_info.glue_remark IS 'GLUE备注';
COMMENT ON COLUMN xxl_job_info.glue_updatetime IS 'GLUE更新时间';
COMMENT ON COLUMN xxl_job_info.child_jobid IS '子任务ID，多个逗号分隔';
COMMENT ON COLUMN xxl_job_info.trigger_status IS '调度状态：0-停止，1-运行';
COMMENT ON COLUMN xxl_job_info.trigger_last_time IS '上次调度时间';
COMMENT ON COLUMN xxl_job_info.trigger_next_time IS '下次调度时间';

CREATE TABLE xxl_job_log
(
    id                        NUMBER(20, 0)               NOT NULL,
    job_group                 NUMBER(20, 0)               NOT NULL,
    job_id                    NUMBER(20, 0)               NOT NULL,
    executor_address          VARCHAR2(255)  DEFAULT NULL NULL,
    executor_handler          VARCHAR2(255)  DEFAULT NULL NULL,
    executor_param            VARCHAR2(1024) DEFAULT NULL NULL,
    executor_sharding_param   VARCHAR2(40)   DEFAULT NULL NULL,
    executor_fail_retry_count NUMBER(11, 0)  DEFAULT 0    NOT NULL,
    trigger_time              DATE           DEFAULT NULL NULL,
    trigger_code              NUMBER(11, 0)               NOT NULL,
    trigger_msg               CLOB           DEFAULT NULL NULL,
    handle_time               DATE           DEFAULT NULL NULL,
    handle_code               NUMBER(11, 0)               NOT NULL,
    handle_msg                CLOB           DEFAULT NULL NULL,
    alarm_status              NUMBER(4, 0)   DEFAULT 0    NOT NULL,
    PRIMARY KEY (id)
)
    NOCOMPRESS
    NOPARALLEL;
CREATE INDEX I_trigger_time ON xxl_job_log (trigger_time);
CREATE INDEX I_handle_code ON xxl_job_log (handle_code);
COMMENT ON COLUMN xxl_job_log.job_group IS '执行器主键ID';
COMMENT ON COLUMN xxl_job_log.job_id IS '任务，主键ID';
COMMENT ON COLUMN xxl_job_log.executor_address IS '执行器地址，本次执行的地址';
COMMENT ON COLUMN xxl_job_log.executor_handler IS '执行器任务handler';
COMMENT ON COLUMN xxl_job_log.executor_param IS '执行器任务参数';
COMMENT ON COLUMN xxl_job_log.executor_sharding_param IS '执行器任务分片参数，格式如 1/2';
COMMENT ON COLUMN xxl_job_log.executor_fail_retry_count IS '失败重试次数';
COMMENT ON COLUMN xxl_job_log.trigger_time IS '调度-时间';
COMMENT ON COLUMN xxl_job_log.trigger_code IS '调度-结果';
COMMENT ON COLUMN xxl_job_log.trigger_msg IS '调度-日志';
COMMENT ON COLUMN xxl_job_log.handle_time IS '执行-时间';
COMMENT ON COLUMN xxl_job_log.handle_code IS '执行-状态';
COMMENT ON COLUMN xxl_job_log.handle_msg IS '执行-日志';
COMMENT ON COLUMN xxl_job_log.alarm_status IS '告警状态：0-默认、1-无需告警、2-告警成功、3-告警失败';

CREATE TABLE xxl_job_log_report
(
    id            NUMBER(20, 0)              NOT NULL,
    trigger_day   DATE          DEFAULT NULL NULL,
    running_count NUMBER(11, 0) DEFAULT 0    NOT NULL,
    suc_count     NUMBER(11, 0) DEFAULT 0    NOT NULL,
    fail_count    NUMBER(11, 0) DEFAULT 0    NOT NULL,
    update_time   DATE          DEFAULT NULL NULL,
    PRIMARY KEY (id)
)
    NOCOMPRESS
    NOPARALLEL;
CREATE UNIQUE INDEX i_trigger_day ON xxl_job_log_report (trigger_day);
COMMENT ON COLUMN xxl_job_log_report.trigger_day IS '调度-时间';
COMMENT ON COLUMN xxl_job_log_report.running_count IS '运行中-日志数量';
COMMENT ON COLUMN xxl_job_log_report.suc_count IS '执行成功-日志数量';
COMMENT ON COLUMN xxl_job_log_report.fail_count IS '执行失败-日志数量';

CREATE TABLE xxl_job_logglue
(
    id          NUMBER(20, 0)              NOT NULL,
    job_id      NUMBER(20, 0)              NOT NULL,
    glue_type   VARCHAR2(100) DEFAULT NULL NULL,
    glue_source CLOB          DEFAULT NULL NULL,
    glue_remark VARCHAR2(256)              NOT NULL,
    add_time    DATE          DEFAULT NULL NULL,
    update_time DATE          DEFAULT NULL NULL,
    PRIMARY KEY (id)
)
    NOCOMPRESS
    NOPARALLEL;
COMMENT ON COLUMN xxl_job_logglue.job_id IS '任务，主键ID';
COMMENT ON COLUMN xxl_job_logglue.glue_type IS 'GLUE类型';
COMMENT ON COLUMN xxl_job_logglue.glue_source IS 'GLUE源代码';
COMMENT ON COLUMN xxl_job_logglue.glue_remark IS 'GLUE备注';

CREATE TABLE xxl_job_registry
(
    id             NUMBER(20, 0)     NOT NULL,
    registry_group VARCHAR2(50)      NOT NULL,
    registry_key   VARCHAR2(510)     NOT NULL,
    registry_value VARCHAR2(510)     NOT NULL,
    update_time    DATE DEFAULT NULL NULL,
    PRIMARY KEY (id)
)
    NOCOMPRESS
    NOPARALLEL;
CREATE INDEX i_g_k_v ON xxl_job_registry (registry_group, registry_key, registry_value);

CREATE TABLE xxl_job_group
(
    id           NUMBER(20, 0)             NOT NULL,
    app_name     VARCHAR2(128)             NOT NULL,
    title        VARCHAR2(24)              NOT NULL,
    address_type NUMBER(4, 0) DEFAULT 0    NOT NULL,
    address_list CLOB         DEFAULT NULL NULL,
    update_time  DATE         DEFAULT NULL NULL,
    PRIMARY KEY (id)
)
    NOCOMPRESS
    NOPARALLEL;
COMMENT ON COLUMN xxl_job_group.app_name IS '执行器AppName';
COMMENT ON COLUMN xxl_job_group.title IS '执行器名称';
COMMENT ON COLUMN xxl_job_group.address_type IS '执行器地址类型：0=自动注册、1=手动录入';
COMMENT ON COLUMN xxl_job_group.address_list IS '执行器地址列表，多地址逗号分隔';

CREATE TABLE xxl_job_user
(
    id         NUMBER(20, 0)              NOT NULL,
    username   VARCHAR2(50)               NOT NULL,
    password   VARCHAR2(50)               NOT NULL,
    role       NUMBER(4, 0)               NOT NULL,
    permission VARCHAR2(510) DEFAULT NULL NULL,
    PRIMARY KEY (id)
)
    NOCOMPRESS
    NOPARALLEL;
CREATE UNIQUE INDEX i_username ON xxl_job_user (username);
COMMENT ON COLUMN xxl_job_user.username IS '账号';
COMMENT ON COLUMN xxl_job_user.password IS '密码';
COMMENT ON COLUMN xxl_job_user.role IS '角色：0-普通用户、1-管理员';
COMMENT ON COLUMN xxl_job_user.permission IS '权限：执行器ID列表，多个逗号分割';

CREATE TABLE xxl_job_lock
(
    lock_name VARCHAR2(50) NOT NULL,
    PRIMARY KEY (lock_name)
)
    NOCOMPRESS
    NOPARALLEL;
COMMENT ON COLUMN xxl_job_lock.lock_name IS '锁名称';

-- 2. Create sequence
-- drop sequence XXL_JOB_INFO_ID;
-- drop sequence XXL_JOB_LOG_ID;
-- drop sequence XXL_JOB_LOG_REPORT_ID;
-- drop sequence XXL_JOB_LOGGLUE_ID;
-- drop sequence XXL_JOB_REGISTRY_ID;
-- drop sequence XXL_JOB_GROUP_ID;
-- drop sequence XXL_JOB_USER_ID;

CREATE SEQUENCE XXL_JOB_INFO_ID MINVALUE 1 MAXVALUE 99999999999999999999 INCREMENT BY 1 START WITH 1000 NOCACHE;
CREATE SEQUENCE XXL_JOB_LOG_ID MINVALUE 1 MAXVALUE 99999999999999999999 INCREMENT BY 1 START WITH 1000 NOCACHE;
CREATE SEQUENCE XXL_JOB_LOG_REPORT_ID MINVALUE 1 MAXVALUE 99999999999999999999 INCREMENT BY 1 START WITH 1000 NOCACHE;
CREATE SEQUENCE XXL_JOB_LOGGLUE_ID MINVALUE 1 MAXVALUE 99999999999999999999 INCREMENT BY 1 START WITH 1000 NOCACHE;
CREATE SEQUENCE XXL_JOB_REGISTRY_ID MINVALUE 1 MAXVALUE 99999999999999999999 INCREMENT BY 1 START WITH 1000 NOCACHE;
CREATE SEQUENCE XXL_JOB_GROUP_ID MINVALUE 1 MAXVALUE 99999999999999999999 INCREMENT BY 1 START WITH 1000 NOCACHE;
CREATE SEQUENCE XXL_JOB_USER_ID MINVALUE 1 MAXVALUE 99999999999999999999 INCREMENT BY 1 START WITH 1000 NOCACHE;

-- 3. initial data
INSERT INTO xxl_job_group(id, app_name, title, address_type, address_list, update_time)
VALUES (1, 'xxl-job-executor-sample', '示例执行器', 0, NULL, to_date('2018-11-03 22:21:31', 'yyyy-MM-dd hh24:mi:ss'));
INSERT INTO xxl_job_info(id, job_group, job_desc, add_time, update_time, author, alarm_email, schedule_type, schedule_conf, misfire_strategy,
                         executor_route_strategy, executor_handler, executor_param, executor_block_strategy, executor_timeout,
                         executor_fail_retry_count, glue_type, glue_source, glue_remark, glue_updatetime, child_jobid)
VALUES (1, 1, '测试任务1', to_date('2018-11-03 22:21:31', 'yyyy-MM-dd hh24:mi:ss'), to_date('2018-11-03 22:21:31', 'yyyy-MM-dd hh24:mi:ss'), 'XXL', '',
        'CRON', '0 0 0 * * ? *', 'DO_NOTHING', 'FIRST', 'demoJobHandler', '', 'SERIAL_EXECUTION', 0, 0, 'BEAN', '', 'GLUE代码初始化',
        to_date('2018-11-03 22:21:31', 'yyyy-MM-dd hh24:mi:ss'), '');
INSERT INTO xxl_job_user(id, username, password, role, permission)
VALUES (1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL);
INSERT INTO xxl_job_lock (lock_name)
VALUES ('schedule_lock');

commit;
