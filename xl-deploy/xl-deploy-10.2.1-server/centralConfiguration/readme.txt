This directory contains files for Digital.ai Deploy central configuration.

To refresh configuration values without restarting server, invoke the refresh Spring Boot Actuator endpoint manually
in order to force the client to refresh and draw in the new value.

$ curl localhost:4516/actuator/refresh -d {} -H "Content-Type: application/json"