
---Various commands for interacting with compute pools & services in SQL, follow

USE ROLE ACCOUNTADMIN;
USE DATABASE CONTAINER_HOL_DB;

SHOW COMPUTE POOLS;

CALL SYSTEM$REGISTRY_LIST_IMAGES('/CONTAINER_HOL_DB/PUBLIC/IMAGE_REPO');

SHOW SERVICES;

DESCRIBE COMPUTE POOL PR_GPU_7;

ALTER COMPUTE POOL PR_GPU_7 RESUME;

SHOW SERVICES;
-- need to set database first to see related services

 USE ROLE CONTAINER_USER_ROLE;

CALL SYSTEM$REGISTRY_LIST_IMAGES('/CONTAINER_HOL_DB/PUBLIC/IMAGE_REPO');

SHOW COMPUTE POOLS;

---GPU compute pool we want to use is not available, so we need to update the grants

USE ROLE ACCOUNTADMIN;
SHOW COMPUTE POOLS;

GRANT USAGE ON COMPUTE POOL PR_GPU_7 TO ROLE CONTAINER_USER_ROLE;
GRANT OPERATE ON COMPUTE POOL PR_GPU_7 TO ROLE CONTAINER_USER_ROLE;

GRANT MONITOR, MODIFY ON COMPUTE POOL PR_GPU_7 TO ROLE CONTAINER_USER_ROLE;

USE ROLE CONTAINER_USER_ROLE;

SHOW COMPUTE POOLS;

CREATE SERVICE CONTAINER_HOL_DB.PUBLIC.CODE_SERVER_GPU
IN COMPUTE POOL PR_GPU_7
from @specs
specification_file='code-server.yaml'
external_access_integrations = (ALLOW_ALL_EAI);

DESCRIBE SERVICE code_server_gpu;

SHOW SERVICES;

CALL SYSTEM$GET_SERVICE_STATUS('CONTAINER_HOL_DB.PUBLIC.CODE_SERVER_GPU');

---observed that we haven't specified GPU usage in the service spec (from logs)
---"status":"READY","message":"Running. WARN: missing 'nvidia.com/gpu' as part of the container specification."

---let's fix this

DESCRIBE COMPUTE POOL PR_GPU_7;
---using GPU_NV_M instance_family ref: https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-compute-pool#creating-a-compute-pool
--- GPU_NV_M has 4 Nvidia A10G GPUs available, per node

---update the service spec to provide access to these services
---ref: https://docs.snowflake.com/en/developer-guide/snowpark-container-services/specification-reference#containers-resources-field
ALTER SERVICE CODE_SERVER_GPU SUSPEND;

---see updates in src/code-server-gpu/code-server-gpu.yaml
---pushed this new service spec to @specs stage of specified schema in my database

DROP SERVICE CODE_SERVER_GPU;
---create new service spec that includes GPU requests & limits
CREATE SERVICE CONTAINER_HOL_DB.PUBLIC.CODE_SERVER_GPU
IN COMPUTE POOL PR_GPU_7
from @specs
specification_file='code-server-gpu.yaml'
external_access_integrations = (ALLOW_ALL_EAI);

SHOW SERVICES;

CALL SYSTEM$GET_SERVICE_LOGS('CONTAINER_HOL_DB.PUBLIC.CODE_SERVER_GPU', '0', 'code-server-gpu',100);

SHOW ENDPOINTS IN SERVICE CODE_SERVER_GPU;


---8/13 updates - with conda

---ALTER COMPUTE POOL CONTAINER_HOL_POOL SET MAX_NODES = 2;

SHOW SERVICES;



CALL SYSTEM$GET_SERVICE_LOGS('CONTAINER_HOL_DB.PUBLIC.CODE_SERVER_2', '0', 'code-server-2',100);

ALTER SERVICE CODE_SERVER_GPU SUSPEND;

ALTER SERVICE CODE_SERVER_2 SUSPEND;


ALTER COMPUTE POOL PR_GPU_7 SUSPEND;

ALTER COMPUTE POOL PR_GPU_7 RESUME;

SHOW SERVICES;

ALTER SERVICE CODE_SERVER_GPU SUSPEND;

ALTER COMPUTE POOL PR_GPU_7 SUSPEND;


SHOW SERVICES;

SHOW COMPUTE POOLS;



