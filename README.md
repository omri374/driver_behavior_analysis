# Driver behavior analysis
This code repository holds the jupyter notebooks for estimating driver safety on Pointer's dataset. 
It contains a sample of the dataset as well as Python (pandas) and PySpark implementations of the process.

It's best first to go over the python notebook as it contains more details, and then to the pyspark notebook to see the same implementation on pyspark.

### Notebooks:
- Python: https://github.com/omri374/driver_behavior_analysis/blob/master/Driver%20safety%20estimation%20-%20pandas.ipynb

- PySpark: https://github.com/omri374/driver_behavior_analysis/blob/master/Driver%20safety%20estimation%20-%20pyspark.ipynb

### Requirements
- For the python notebook:
  - Python > 3.5
  - **packages**: numpy (1.14.0 and above), scipy, pandas, seaborn, matplotlib

- For PySpark:
  - Python > 3.5
  - **packages**: numpy (1.14.0 and above), scipy, pandas, seaborn, matplotlib, pyspark

A code story presenting the entire flow will be uploaded to https://www.microsoft.com/developerblog

### Deployment
When deploying this sample solution you should take note of a few resources provided in this repository:

- databricks/deploy
  - 0_azure - an interactive, one-time script that configures your local environment and azure resources to run this solution. In will create a Databricks cluster on azure, install its cli locally on your machine and guide you through the initial configuration.
  - 1_configure - Databricks job deployment script and sample job definition file. These resources are intended to be used multiple times, possible in an automated way, i.e. in a continues deployment pipeline (see more below).
    - The shell script can be used interactively and in batch. 
    It requires the job definition location or pattern (to iterate over). It can also use parameters for the Databricks region and access token - these are most likely required in most CD situations as those need to be configured on every run.
    - The json file holds the specific setting for creating a new job on Databricks. Things like: name, cluster, notebook location, library dependencies, schedule, etc.
- databricks/notebooks - a sample python notebook to be run on a Databricks cluster
- .travis.yml - an example of how to configure a CI/CD pipeline on [Travis-CI](https://www.travis-ci.org)

#### How to use Travis-CI
The example travis.yml file is simple and performs the following actions:
- Install the Databricks CLI
- Deploy on the master branch (by default) by running the deploy_job.sh script described above.
This action is using a special environment variable $DATABRICKS_TOKEN that is injected from Travis-CI where it's saved securely. 
The following image shows where and how this is defined on the configuration screen:
<img src="assets/travis-env-vars.jpg" alt="Travis Environment Variables" width="600px"/>
Note: currently the "test" phase isn't doing much since this can be very specific to the notebook code, Databricks and additional resources related (file storage, event sources, etc.). 


### License
MIT
