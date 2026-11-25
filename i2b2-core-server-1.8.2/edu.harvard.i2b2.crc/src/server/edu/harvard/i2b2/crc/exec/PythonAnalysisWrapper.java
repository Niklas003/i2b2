package edu.harvard.i2b2.crc.exec;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

public class PythonAnalysisWrapper {
    public static void main(String[] args) throws Exception {
        PythonAnalysisWrapper main1 = new PythonAnalysisWrapper();
        // read command line params[domain, project, user and analysis
		// instance id
		String arg = "", domainId = "", projectId = "", userId = "", patientSetId = "", instanceId = "";
		int i = 0;
		while (i < args.length) {
			arg = args[i++];
			if (arg.startsWith("-domain_id")) {
				domainId = arg.substring(arg.indexOf('=') + 1);
			} else if (arg.startsWith("-project_id")) {
				projectId = arg.substring(arg.indexOf('=') + 1);
			} else if (arg.startsWith("-user_id")) {
				userId = arg.substring(arg.indexOf('=') + 1);
			} else if (arg.startsWith("-instance_id")) {
				instanceId = arg.substring(arg.indexOf('=') + 1);
			}
		}

        main1.runPython(projectId, userId, domainId,
				patientSetId, instanceId);
    }

 private String runPython(String instanceId, String projectId, String userId, String domainId, String patientSetId) throws Exception {
    ProcessBuilder processBuilder = new ProcessBuilder(
        "/usr/bin/python3",
        "/opt/jboss/wildfly/i2b2-core-server/analysis-scripts/test_analisys.py"
    );

    processBuilder.redirectError(ProcessBuilder.Redirect.INHERIT);

    Process process = processBuilder.start();

    StringBuilder output = new StringBuilder();
    try (BufferedReader reader = new BufferedReader(
            new InputStreamReader(process.getInputStream(),
                    StandardCharsets.UTF_8))) {
        String line;
        while ((line = reader.readLine()) != null) {
            output.append(line).append('\n');
        }
    }

    int exitCode = process.waitFor();

    if (exitCode != 0) {
        throw new IllegalStateException(
            "Python analysis failed with exit code " + exitCode
        );
    }

    return output.toString().trim();
}
    }
