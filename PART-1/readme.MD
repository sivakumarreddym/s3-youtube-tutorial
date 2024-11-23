# S3 - Simple Storage Service

## Agenda
* Storage Options in AWS
* How data is stored in AWS?
* EBS vs EFS vs S3
* What is Object Storage?
* Preference of storages
* S3 features
* S3 Bucket creation

### Storage Options in AWS
* EBS
    * Block Storage
* EFS
    * File System
* S3
    * Object Storage

**We often say S3 is object storage, What is object storage?**

### EBS

![alt text](s3-ebs.svg)

* **Data Storage:** Data is stored as blocks, and EBS provides block-level storage volumes.
* **File Creation:** When you create a file, the file system handles dividing the file into smaller pieces (blocks) and organizing them on the EBS volume.
* **File Retrieval:** When retrieving a file, the file system gathers all the corresponding blocks from the EBS volume and reconstructs the file for use.
* **Access Requirement:** EBS cannot be accessed directly; it must be formatted with a file system (e.g., ext4, xfs, etc.) before mounting.
* **File System:** Before mounting an EBS volume to an EC2 instance, you must select and configure a file system. Popular options include ext4 and xfs.
* **Instance Attachment:** EBS volumes must be attached to an EC2 instance for use. A single EBS volume can be attached to only one EC2 instance at a time, unless using multi-attach with specific volume types.
* **Availability Zone (AZ) Dependency:** Both the EC2 instance and the EBS volume must reside in the same Availability Zone to ensure low-latency connectivity.

### EFS

![alt text](s3-efs.svg)

* **File Organization:** Data is stored and accessed as a normal filesystem hierarchy (files and directories).
* **Access Requirement:** EFS cannot be accessed directly; it must be mounted to an EC2 instance or an on-premises server via the NFS protocol.
* **File System:** The file system used is NFS (Network File System), and this cannot be changed.
* **Network Location:** EFS can be accessed from anywhere within the same AWS region over the network, including multiple Availability Zones.
* **Concurrent Access:** Multiple EC2 instances can read from and write to the same EFS volume simultaneously.
* **Underlying Storage:** The underlying storage infrastructure is completely abstracted from the user. It is likely implemented using distributed block storage (e.g., EBS or similar technologies).

### S3

![alt text](s3.svg)

**Data Storage:** Data is stored as objects, which consist of three main components:

    1. The object data itself (e.g., the file being stored).
    2. Metadata, which provides information about the object, such as file type, size, and other attributes.
    3. A unique identifier, typically the key, which acts as the file name or a path-like structure for accessing the object.

**Access:** Unlike block or file storage, S3 does not require mounting. Objects can be accessed directly via:
* AWS Management Console (User Interface)
* AWS CLI
* SDKs and APIs

**Global Accessibility:** S3 is not bound by Availability Zones (AZs) or regions for access. Data can be retrieved from anywhere in the world, provided the necessary permissions and internet access.

**Concurrent Access:** The same objects can be accessed simultaneously from multiple locations without conflict.

### How to select Storage type

### EBS Usecases

* **High Performance and Low Latency Workloads:**
EBS is ideal for databases that require fast, consistent performance and high IOPS. It supports both relational (e.g., MySQL, PostgreSQL) and NoSQL (e.g., MongoDB, Cassandra) databases.

* **Root Volumes for EC2 Instances:**
Every EC2 instance requires a root volume to host the operating system (OS). EBS volumes are commonly used as root volumes, enabling persistent storage and easy snapshots for backup and recovery.

* **Media Workflows:**
For tasks like video editing or real-time processing, EBS provides high-throughput, low-latency storage to ensure smooth and efficient performance. This is critical for rendering animations or processing large video files.


### EFS Usecases

EBS volumes cannot scale automatically; their size must be manually adjusted. In contrast, EFS automatically scales up or down based on the storage demand, making it a better choice for applications that require dynamic storage expansion without manual intervention.

* **Shared Application Logs:**
EFS is perfect for storing logs that need to be written to and read frequently by multiple application instances. For example, in distributed systems, logs are centralized in EFS to ensure all instances can access them in real-time.

* **Application Configuration Files:**
When multiple EC2 instances run the same application, EFS can store shared configuration files (e.g., .env, config.yaml), allowing consistent configuration across all instances.

* **User Home Directories:**
In environments where users log in to different EC2 instances, EFS can serve as a central storage location for their home directories, ensuring their files are accessible regardless of the instance they log in to.

* **Web Hosting:**
EFS is useful for hosting shared assets (e.g., images, stylesheets, scripts) or dynamic content in a multi-instance web server setup, ensuring all servers access the same files.

### S3 Use cases

* **Static Website Hosting:**
S3 can host static websites, serving HTML, CSS, JavaScript, and other static files directly to users without requiring a web server.

* **Media Storage and Distribution:**
S3 is perfect for storing and delivering large media files like images, videos, and audio, especially when integrated with Amazon CloudFront for global content delivery.

* **Log Storage and Analysis:**
S3 is a great place to store logs from applications, services, or AWS resources (e.g., ALB, CloudTrail). These logs can then be processed for analysis using services like AWS Lambda or Amazon Athena.

* **Application Data Storage:**
Applications that handle file uploads (e.g., documents, images, videos) can use S3 to store user-generated content reliably and accessibly.

* **Remote state storage:**
Terraform stores the remote state in S3 with DynamoDB locking.

* **Backups storage:**
S3 is popular service for storing database backups, server snapshots, application artifacts and configuration backups, log backups, etc.


# AWS Storage Comparison: EBS vs EFS vs S3

| **Feature**               | **EBS**                                                                                                                                                                                                 | **EFS**                                                                                                                           | **S3**                                                                                                                            |
|---------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| **Type of Storage**        | Block Storage                                                                                                                                                                                          | File Storage                                                                                                                     | Object Storage                                                                                                                   |
| **Use Cases**              | Databases, operating systems, video editing, and applications requiring high performance and low latency.                                                                                              | Shared folders, application logs, configuration files, machine learning frameworks, and big data analytics requiring multi-EC2 access. | Backup, archiving, media storage, content distribution, data lakes, and static website hosting.                                 |
| **Access Method**          | Must be attached to an EC2 instance and mounted.                                                                                                                | Must be mounted as a file system on EC2 instances via NFS.                                                                      | Directly accessible via APIs, SDKs, CLI, and AWS Console. No mounting required.                                                 |
| **File System**            | User-defined (e.g., ext4, xfs, NTFS).                                                                                                                           | Default NFS (v4.0 or v4.1).                                                                                                     | No file system—data is managed as objects.                                                                                      |
| **Scalability**            | Manual resizing required.                                                                                                                                       | Automatically scales up and down based on demand.                                                                               | Automatically scales without limits.                                                                                            |
| **Performance**            | Low latency and high IOPS, with provisioned performance for specific needs.                                                                                     | Lower latency than S3, but higher than EBS.                                                                                     | Low latency for retrieval, but generally higher than EBS/EFS.                                                                  |
| **Availability Zone (AZ)** | EBS volumes are tied to a specific AZ and must be in the same AZ as the EC2 instance it is attached to.                                                          | Accessible from multiple AZs within the same region.                                                                            | Accessible globally across regions without AZ restrictions.                                                                     |
| **Cost**                   | Charges are based on provisioned capacity, even if not used.                                                                                                   | Pay-per-use based on storage consumed.                                                                                          | Tiered pricing: Pay for the amount of data stored and requests made.                                                            |
| **Durability**             | Durable within a single AZ, but not automatically replicated across AZs.                                                                                        | Automatically replicates data across multiple AZs.                                                                              | Provides 99.999999999% (11 nines) durability through multi-AZ replication.                                                      |
| **Concurrent Access**      | Only one EC2 instance can access a single EBS volume at a time.                                                                                                 | Multiple EC2 instances can read/write simultaneously.                                                                           | Data can be accessed simultaneously from multiple locations.                                                                    |      |

### S3 Features
* Scalable
* Highly available 99.9999999 11 9's durable and highly available.
* Access from Anywhere. HTTP/HTTPS access. usually AWS CLI, Console and SDK.
* Static Website Hosting
* Versioning
* Cost-Effective Storage Tiers. Standard, IA, IA Single zone, Glacier, etc.
* Automatic Lifecycle Management
* Cross region replication
* Security and Compliance. 
    * Encryption at rest and transit
    * Bucket Policies, ACL, IAM roles.
* Event Notifications. It can trigger Lambda, SQS, SNS when object is created or deleted.

### S3 Bucket creation

**Name Selection:**
Buckets names are unique in all AWS accounts. just like domains are unique in the world S3 bucket names also should be unique across all AWS accounts. why?

It avoids conflicts when accessing S3 buckets via public URLs like https://<bucket-name>.s3.amazonaws.com

**Naming Rules:**
Although bucket names are globally unique, the bucket data is stored regionally, and you must specify a region when creating a bucket.

Bucket names must:
* Be between 3 and 63 characters long.
* Consist only of lowercase letters, numbers, hyphens (-), and periods (.).
* Begin and end with a letter or number.

**Tips:**
While naming bucket, use elements such as company name, project name, component name, environment, timestamp, etc.

For example:
* **joindevops-roboshop-catalogue-dev**
* **projectname-app-logs-2024**