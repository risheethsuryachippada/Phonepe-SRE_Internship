# CI CD

>## Continuous Integration & Continuous Deployment

![CI/CD Patterns and Practices - CD Foundation](https://cd.foundation/wp-content/uploads/sites/78/2020/09/devops.png)

CI and CD stand for continuous integration and continuous delivery/continuous deployment.
 - CI is a modern software development practice in which incremental code changes are made frequently and reliably.
 - Automated build-and-test steps triggered by CI ensure that code changes being merged into the repository are reliable.
 - The code is then delivered quickly and seamlessly as a part of the CD process.
 - CI/CD pipeline refers to the automation that enables incremental code changes from developers’ desktops to be delivered quickly and reliably to production.

DevOps is a set of practices and tools designed to increase an organization’s ability to deliver applications and services faster than traditional software development processes. The increased speed of DevOps helps an organization serve its customers more successfully and be more competitive in the market.


**WHY ?**
CI/CD allows organizations to ship software quickly and efficiently. CI/CD facilitates an effective process for getting products to market faster than ever before, continuously delivering code into production, and ensuring an ongoing flow of new features and bug fixes via the most efficient delivery method.


 >CI CD Technology Stack

![CI/CD Continuous Integration &amp; Continuous Deployment Services](https://www.suntechnologies.com/wp-content/uploads/2020/06/Picture2.png)

## ARCHITECTURE OF FLOW

![Continuous Integration Architecture](https://d2908q01vomqb2.cloudfront.net/ca3512f4dfa95a03169c5a670a4c91a19b3077b4/2019/12/14/Architecture2.png)

-   Pulling code from version control and executing a build.
-   Executing any required infrastructure steps that are automated as code to stand up or tear down cloud infrastructure.
-   Moving code to the target computing environment.
-   Managing the environment variables and configuring them for the target environment.
-   Pushing application components to their appropriate services, such as web servers, API services, and database services.
-   Executing any steps required to restarts services or call service endpoints that are needed for new code pushes.
-   Executing continuous tests and rollback environments if tests fail.
-   Providing log data and alerts on the state of the delivery.