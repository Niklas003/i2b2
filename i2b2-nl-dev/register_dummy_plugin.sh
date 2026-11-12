#!/bin/bash

docker exec -it i2b2-data-pgsql `
  psql -U i2b2 -d i2b2 -c "
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
    '/usr/bin/python3 /opt/jboss/wildfly/i2b2-core-server/analysis-scripts/test_analisys.py',
    '/opt/jboss/wildfly/i2b2-core-server/analysis-scripts',
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
"