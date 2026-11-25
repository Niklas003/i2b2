#!/bin/bash

docker exec -e PGPASSWORD=demouser i2b2-data-pgsql \
  psql -U i2b2 -d i2b2 -c "
SELECT plugin_id, plugin_name, version_cd, command_line,
       working_folder, status_cd
FROM i2b2demodata.qt_analysis_plugin
WHERE plugin_name = 'TEST_ANALYSIS';

SELECT * FROM i2b2demodata.qt_privilege
WHERE plugin_id = 9001;
"