
# Snowpark Container Services - Remote VSCode (code-server)
## Now Including R Kernel
---
This repository contains code that builds upon the quickstart [Intro to Snowpark Container Services Quickstart](https://quickstarts.snowflake.com/guide/intro_to_snowpark_container_services/index.html). 

This specific branch includes details on how to update your dockerfile to include the R kernel and corresponding dependencies, for a mixed Python & R development environment running on Linuxserver.io's code-server project, aka, containerized VSCode. 

---
Please refer to the quickstart for a complete set of instructions for getting started with spcs, including configuring roles required for use of SPCS, creating and managing compute pools, and configuring corresponding network configurations for services deployed in SPCS. 

## Topics
1. Configure Snowflake Roles & Resources for SPCS
2. Configure dockerfile for code-server. This includes steps for non-root miniconda access, for python environment management
3. Configure SPCS spec / service file
4. Push service file to @specs stage
5. Create service from staged spec file
6. Best practices for SPCS & VSCode/code-server

### Topics 1-5: Configuring SPCS & code-server service
- Please see the quickstart, linked above, and the included notebook, code-server-conda-setup.ipynb, which details several code-server specific implementation steps 
- [spcs_configuration_management.sql](spcs_configuration_management.sql) also contains several useful snippets for interacting with SPCS services & underlying compute pool via Snowflake SQL commands.

### Topic 6: Best practices for SPCS-based code-server

1. **Managing Python environments**: While miniconda is pre-installed via dockerfile steps 2-4, additional steps must be taken to **initialize conda & expose created conda environments to your workspace** (e.g., for the purpose of leveraging conda environments within a notebook)
  a. **Upon login, open a new terminal and type 'conda init'.** Close/restart that terminal. You will now see (base) prefix in your shell. 
  b. **Use pip or conda to install 'ipykernel'** in each conda environment you would like to expose for use.
  c. **Install Extension 'Jupyter'**: A Visual Studio Code extension that provides basic notebook support for language kernels that are supported in Jupyter Notebooks today, and allows any Python environment to be used as a Jupyter kernel. This is NOT a Jupyter kernel--you must have Python environment in which you've installed the Jupyter package, though many language kernels will work with no modification. To enable advanced features, modifications may be needed in the VS Code language extensions. The Author of this extension is ms-toolsai, and the latest version as of writing this readme is v2024.6.0.  
    
2. **Ensure read & write access to/from Snowflake stage**. 
  a. To ensure read & write operations to & from a stage volume, one needs to set the UID & GID in the container to match the _default UID/GID of the deployed service_. 
  b. SPCS services do not allow root access within the container, so this must be set within the service spec (yaml). _For code-server, this UID/GID is 911._ 
  
3. **Git integration**: In VSCode, there are a wide variety of means to interact with Git. Please refer to corresponding documentation for .ssh or PAT-based authentication with a publically hosted (but private) repo. 
    a. code-server recommends using .ssh, and demonstrates how to configure your username and email with the git command line. Ref: (https://docs.linuxserver.io/images/docker-code-server/#application-setup)
    b. PAT-based authentication is the most common method when working with 2FA-enabled git servers. Ref: (https://code.visualstudio.com/docs/sourcecontrol/github)
    c. There is also a VSCode Extension "Github Pull Requests" that is quite popular, for a VSCode/UI-integrated option. 
  
4. **To Configure a Snowpark connection from code-server**: We can take advantage of the Snowflake plugin. 
  -  **Install the Snowflake plugin** in your code-server instance. This plugin enables you to connect to Snowflake, write and execute sql queries, and view results without leaving VS Code. 
  -  To configure your connection(s) open the extension, and click the pencil icon in the upper right corner. This will open up your config.toml file, where you can configure one or more connections to be used from within this workspace. By default, this file is in the /config/.snowflake directory of your workspace.  Reference: (https://docs.snowflake.com/en/developer-guide/snowflake-cli-v2/connecting/specify-credentials)
  c. Once you've configured this connection and signed in via the Snowflake Extension, one can use the following method to authenticate using your existing session details. Note that there is a wide variety of methods to configure a Snowflake session within a notebook. This approach reduces the number of places one has to manage & configure connection details: as long as your Snowflake session remains active in the Extension, you will not have to re-enter your credentials to creat a new session within a notebook. 
```
from snowflake.snowpark import Session
from snowflake.ml.utils import connection_params
session = Session.builder.configs(connection_params.SnowflakeLoginOptions()).create()   
```

---

### Topic 7: Adding R functionality

1. **Add R-specific dockerfile layers**: Additional dockerfile layers are included in this branch, to add the R kernel, underlying compilers, prerequisite libraries for the R VSCode plugin, and a common GAM modeling library. 
3. **Upon logging into your service, install the R VSCode Plugin** This extension provides general support for R within VSCode. This includes syntax highlighting, the use of R terminals, and viewing data & plots. Note that the package 'languageserver', which we installed in the dockerfile, is a pre-requisite for this extension.

That's it! Once you've installed the R plugin, you can open a terminal from the VSCode command bar, or you can open the included R_test.rmd file and execute the chunks. Each chunk can be executed individually, or you can highlight all text within the .Rmd file and use the hotkey command-enter. 
