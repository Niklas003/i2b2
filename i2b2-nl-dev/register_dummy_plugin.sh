#!/bin/bash

docker exec -e PGPASSWORD=demouser i2b2-data-pgsql \
  psql -U i2b2 -d i2b2 -v ON_ERROR_STOP=1 -c "
INSERT INTO i2b2demodata.qt_analysis_plugin (
    plugin_id, plugin_name, description, version_cd,
    parameter_info, parameter_info_xsd, command_line,
    working_folder, commandoption_cd, plugin_icon,
    status_cd, user_id, group_id, create_date, update_date
)
SELECT
    9001,
    'TEST_ANALYSIS',
    'Dummy Python analysis',
    '1.0',
    NULL,
    NULL,
    '/opt/jboss/wildfly/i2b2-core-server/edu.harvard.i2b2.crc/analysis-commons-launcher/bin/run_python_analysis.sh',
    '/opt/jboss/wildfly/i2b2-core-server/edu.harvard.i2b2.crc/analysis-commons-launcher/bin',
    'N',
    NULL,
    'A',
    'admin',
    '@',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1
    FROM i2b2demodata.qt_analysis_plugin
    WHERE plugin_name = 'TEST_ANALYSIS'
      AND version_cd = '1.0'
);
UPDATE i2b2demodata.qt_analysis_plugin
SET command_line = '/opt/jboss/wildfly/i2b2-core-server/edu.harvard.i2b2.crc/analysis-commons-launcher/bin/run_python_analysis.sh',
    working_folder = '/opt/jboss/wildfly/i2b2-core-server/edu.harvard.i2b2.crc/analysis-commons-launcher/bin',
    update_date = CURRENT_TIMESTAMP
WHERE plugin_name = 'TEST_ANALYSIS' AND version_cd = '1.0';

INSERT INTO i2b2demodata.qt_privilege (
    plugin_id, protection_label_cd, dataprot_cd, hivemgmt_cd
)
SELECT
    9001,
    '@',
    'DATA_AGG',
    'USER'
WHERE NOT EXISTS (
    SELECT 1
    FROM i2b2demodata.qt_privilege
    WHERE plugin_id = 9001
      AND protection_label_cd = '@'
);
"