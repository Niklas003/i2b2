BEGIN;

INSERT INTO i2b2demodata.qt_analysis_plugin (
    plugin_id, plugin_name, description, version_cd,
    command_line, working_folder, commandoption_cd,
    status_cd, user_id, group_id, create_date, update_date
)
SELECT
    9003, 'JAVA_TEST', 'Test Java Analysis Script', '1.0',
    '/usr/bin/java --class-path ../edu.harvard.i2b2.server-common/lib/jdbc/postgresql-42.7.8.jar testJava.java',
    '/opt/jboss/wildfly/i2b2-core-server/analysis-scripts',
    'N', 'A', 'admin', 'Demo', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1
    FROM i2b2demodata.qt_analysis_plugin
    WHERE plugin_name = 'JAVA_TEST'
      AND version_cd = '1.0'
);

UPDATE i2b2demodata.qt_analysis_plugin
SET plugin_id = 9003,
    description = 'Test Java Analysis Script',
    command_line = '/usr/bin/java --class-path ../edu.harvard.i2b2.server-common/lib/jdbc/postgresql-42.7.8.jar testJava.java',
    working_folder = '/opt/jboss/wildfly/i2b2-core-server/analysis-scripts',
    commandoption_cd = 'N',
    status_cd = 'A',
    user_id = 'admin',
    group_id = 'Demo',
    update_date = CURRENT_TIMESTAMP
WHERE plugin_name = 'JAVA_TEST'
  AND version_cd = '1.0';

INSERT INTO i2b2demodata.qt_privilege (
    plugin_id, protection_label_cd, dataprot_cd, hivemgmt_cd
)
SELECT 9003, 'JAVA_TEST', 'DATA_AGG', 'USER'
WHERE NOT EXISTS (
    SELECT 1
    FROM i2b2demodata.qt_privilege
    WHERE protection_label_cd = 'JAVA_TEST'
);

COMMIT;
