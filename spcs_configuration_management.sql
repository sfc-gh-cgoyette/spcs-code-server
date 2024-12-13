USE ROLE ACCOUNTADMIN;

---role grants
GRANT USAGE ON COMPUTE POOL CONTAINER_HOL_POOL TO ROLE CONTAINER_USER_ROLE;
GRANT OPERATE ON COMPUTE POOL CONTAINER_HOL_POOL TO ROLE CONTAINER_USER_ROLE;
GRANT MONITOR, MODIFY ON COMPUTE POOL CONTAINER_HOL_POOL TO ROLE CONTAINER_USER_ROLE;
USE ROLE CONTAINER_USER_ROLE;
SHOW COMPUTE POOLS;

---Various commands for interacting with compute pools & services in SQL, follow
USE ROLE CONTAINER_USER_ROLE;
USE DATABASE CONTAINER_HOL_DB;

---observe available compute pools, and status/details therein
SHOW COMPUTE POOLS;
DESCRIBE COMPUTE POOL CONTAINER_HOL_POOL;

---if suspended, resume compute pool
ALTER COMPUTE POOL CONTAINER_HOL_POOL RESUME;


---observe image names in registry
CALL SYSTEM$REGISTRY_LIST_IMAGES('/CONTAINER_HOL_DB/PUBLIC/IMAGE_REPO');

---observe existing services and statuses
-- Note: if you expect to see existing services and do not, ensure you have set correct database
---Note, for awareness: if the compute pool you want to use is not visible, you may need to update the grants.
SHOW SERVICES;

--- example of altering scaling policies for nodes in compute pool
ALTER COMPUTE POOL CONTAINER_HOL_POOL SET MAX_NODES = 3;

---Create a new service from spec. 
---Prior to creating a service from a spec file, make sure you have uploaded the spec file to yoru @specs stage
CREATE SERVICE CONTAINER_HOL_DB.PUBLIC.CODE_SERVER_R
IN COMPUTE POOL CONTAINER_HOL_POOL
from @specs
specification_file='code-server-r.yaml'
external_access_integrations = (ALLOW_ALL_EAI);

DESCRIBE SERVICE code_server_r;

SHOW SERVICES;

---get service status
CALL SYSTEM$GET_SERVICE_STATUS('CONTAINER_HOL_DB.PUBLIC.CODE_SERVER_R');

---retrieve logs, if you have the need
CALL SYSTEM$GET_SERVICE_LOGS('CONTAINER_HOL_DB.PUBLIC.CODE_SERVER_R', '0', 'code-server-r',100);

---show endpoint; use for browser-based ingress to this long-running interactive service
SHOW ENDPOINTS IN SERVICE CODE_SERVER_R;

---shut down/clean up
ALTER SERVICE CODE_SERVER_R_PY_DEPS_BE SUSPEND;
SHOW SERVICES;

ALTER COMPUTE POOL CONTAINER_HOL_POOL SUSPEND;

