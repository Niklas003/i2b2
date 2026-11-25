INSER INTO i2b2demodata.qt_analysis_plugin (
     plugin_id,
     plugin_name,
     version_cd,
     command_line,
     working_folder,
     status_cd) VALUES (
        '9002',
        'PYTHON_DOUBLE',
        '1.0',
        '/opt/jboss/wildfly/i2b2-core-server/edu.harvard.i2b2.crc/analysis-commons-launcher/bin/run_python_analysis.sh',
        '/opt/jboss/wildfly/i2b2-core-server/edu.harvard.i2b2.crc/analysis-commons-launcher/bin',
        'A'
     )