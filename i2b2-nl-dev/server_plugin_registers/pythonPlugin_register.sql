INSERT INTO i2b2demodata.qt_analysis_plugin (
    plugin_id,
    plugin_name,
    description,
    version_cd,
    command_line,
    working_folder,
    status_cd,
    user_id,
    group_id,
    create_date,
    update_date
)
SELECT
    '9002',
    'PYTHON_DOUBLE',
    'Python plugin that doubles an analysis value',
    '1.0',
    '/opt/i2b2-plugin/venv/bin/python /opt/jboss/wildfly/i2b2-core-server/analysis-scripts/test.py',
    '/opt/jboss/wildfly/i2b2-core-server/analysis-scripts',
    'A',
    'admin',
    '@',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1
    FROM i2b2demodata.qt_analysis_plugin
    WHERE plugin_name = 'PYTHON_DOUBLE'
      AND version_cd = '1.0'
);

UPDATE i2b2demodata.qt_analysis_plugin
SET plugin_id = '9002',
    description = 'Python plugin that doubles an analysis value',
    command_line = '/opt/i2b2-plugin/venv/bin/python /opt/jboss/wildfly/i2b2-core-server/analysis-scripts/test.py',
    working_folder = '/opt/jboss/wildfly/i2b2-core-server/analysis-scripts',
    status_cd = 'A',
    user_id = 'admin',
    group_id = '@',
    update_date = CURRENT_TIMESTAMP
WHERE plugin_name = 'PYTHON_DOUBLE'
  AND version_cd = '1.0';

INSERT INTO i2b2demodata.qt_privilege (
    plugin_id,
    protection_label_cd,
    dataprot_cd,
    hivemgmt_cd
)
SELECT
    '9002',
    '@',
    'DATA_AGG',
    'USER'
WHERE NOT EXISTS (
    SELECT 1
    FROM i2b2demodata.qt_privilege
    WHERE plugin_id = '9002'
      AND protection_label_cd = '@'
);