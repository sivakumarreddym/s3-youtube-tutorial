# 🔐 S3 IAM and Bucket Policies

Amazon S3 access control can be managed through two primary methods:

1. **IAM Policies** 🛠️ – Used to provide access to users and roles.
2. **S3 Bucket Policies** 📂 – Resource-based policies applied at the bucket level.

To ensure **security** 🔒 and proper **access control**, it is important to combine both IAM and bucket policies effectively.

IAM Full Course(Telugu): https://www.youtube.com/playlist?list=PL1jY4BuFJn1fqijDbvsNOobBj5zOb_jvt
---

## ⚙️ Setup
* I am using **GitBash** as the command line on my laptop.
* I am using **2 AWS accounts**. Replace with your accounts.
    * **ACC-A** 🏢 `315069654700` → I will create **user sivakumar** in this account.
    * **ACC-B** 🏢 `752692907119` → I will create **user ramesh** in this account.

---

## 📌 IAM Policies
IAM policies define what **users and roles** can do with S3, such as **ListBucket, GetObject, PutObject, DeleteObject**, etc.

### **🔹 Scenario: Restrict a User to Read, List, and Upload Objects in an S3 Bucket**
#### **📌 Steps:**
1. **Create an IAM user** (`sivakumar`)
2. **Attach an IAM policy** to grant **read, list, and upload** access to a specific bucket.
3. **Login with the IAM user** and attempt to list and upload an object.
4. **Try deleting an object** – it should fail ❌.

**📝 NOTE:** Replace my bucket `s3-tutorial-part2-policies` with your bucket name.

### **✅ Example IAM Policy:**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::s3-tutorial-part2-policies",
                "arn:aws:s3:::s3-tutorial-part2-policies/*"
            ]
        }
    ]
}
```
You can configure this user in your laptop using the below command:

```bash
aws configure --profile sivakumar
```

Provide the **access-key** and **secret-key** created while creating the user.

✅ **Effect**: Grants the user permission to **list, read, and upload** objects but **not delete** them.

---

## 📌 Why Use S3 Bucket Policies? 📜
S3 bucket policies provide **extra security** 🔒 and help in **fine-grained access control** 🎯. These policies are applied directly to an S3 bucket to enforce security measures like:

1. **Cross-account access** 🔄 (Allowing users from another AWS account to access your bucket)
2. **Public access control** 🌎 (Allowing public read for static website hosting or blocking public access)
3. **Forcing secure uploads** using **HTTPS** 🔐
4. **Requiring MFA for object deletion** 🛡️ (In case of credential leaks, this adds extra protection)

---

## **🔹 Bucket Policy Use Cases**

### **1️⃣ Public Read Access for Static Website Hosting** 🌐
* Remove **Block Public Access** setting before applying this policy.
Allow **public read access** to all objects.
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::s3-tutorial-part2-policies/*"
        }
    ]
}
```
✅ **Effect**: Anyone on the internet can view objects.
⚠️ **Warning**: Ensure this is intended before applying.

### **2️⃣ Enforce Secure Uploads (HTTPS Only) 🔒**
Deny all requests that **don’t use HTTPS**.

Use the below command to see if AWS CLI is using an **HTTPS endpoint**:
```bash
aws s3 ls s3://s3-tutorial-part2-policies/ --debug --profile sivakumar
```

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::s3-tutorial-part2-policies",
                "arn:aws:s3:::s3-tutorial-part2-policies/*"
            ],
            "Condition": {
                "Bool": { "aws:SecureTransport": "false" }
            }
        }
    ]
}
```
✅ **Effect**: Blocks HTTP-based uploads, ensuring all requests use **HTTPS**.

# **🔐 Secure S3 Access with IAM & Bucket Policies**

## **3️⃣ Require MFA for Object Deletion**
🚫 Deny **deletion** unless the request includes an MFA token.

✅ **Key Rules:**
- Users **cannot delete objects** from the console.
- MFA **must be enabled** for the user.
- Users must obtain **temporary session credentials** before deleting an object.

### **IAM Policy**
```json
{
    "Effect": "Allow",
    "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetBucketVersioning"
    ],
    "Resource": [
        "arn:aws:s3:::s3-tutorial-part2-policies",
        "arn:aws:s3:::s3-tutorial-part2-policies/*"
    ]
}
```

### **S3 Bucket Policy**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": {
                "AWS": "arn:aws:iam::315069654700:user/sivakumar"
            },
            "Action": "s3:DeleteObject",
            "Resource": "arn:aws:s3:::s3-tutorial-part2-policies/*",
            "Condition": {
                "Bool": {
                    "aws:MultiFactorAuthPresent": "false"
                }
            }
        }
    ]
}
```

### **🛠 Steps to Implement MFA Delete**
1️⃣ Run AWS CLI configuration:
```bash
aws configure --profile sivakumar
```
2️⃣ Obtain **temporary session credentials** using MFA:
```bash
aws sts get-session-token \
    --serial-number arn:aws:iam::315069654700:mfa/sivakumar-android \
    --token-code 303858 \
    --profile sivakumar
```
📌 **Sample Output:**
```json
{
    "Credentials": {
        "AccessKeyId": "<access-key>",
        "SecretAccessKey": "<secret-access-key>",
        "SessionToken": "<token>",
        "Expiration": "2025-02-02T17:59:55+00:00"
    }
}
```
3️⃣ Use temporary credentials to authenticate:
```bash
aws configure --profile sivakumar-mfa-session set aws_access_key_id <access-key>
aws configure --profile sivakumar-mfa-session set aws_secret_access_key <secret-access-key>
aws configure --profile sivakumar-mfa-session set aws_session_token <token>
```
4️⃣ Now delete the object using the **MFA session**:
```bash
aws s3 rm s3://s3-tutorial-part2-policies/terraform-modules.mp4 --profile sivakumar-mfa-session
```
✅ **Effect:** Even if credentials are leaked, **objects cannot be deleted without MFA authentication**.

---

## **4️⃣ Cross-Account Access**
🔄 **Scenario:**
- **ACC-A**: Contains the S3 bucket 📦
- **ACC-B**: External vendor account 🏢
- Users in **ACC-B** need **read/write** access to `logistics` folder in `s3-tutorial-part2-policies` bucket (ACC-A)

### **👨‍💻 IAM Policy for User in ACC-B**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::s3-tutorial-part2-policies/logistics/*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::s3-tutorial-part2-policies",
            "Condition": {
                "StringLike": {
                    "s3:prefix": ["logistics/*"]
                }
            }
        }
    ]
}
```

### **📜 S3 Bucket Policy**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::752692907119:user/ramesh"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::s3-tutorial-part2-policies/logistics/*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::752692907119:user/ramesh"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::s3-tutorial-part2-policies",
            "Condition": {
                "StringLike": {
                    "s3:prefix": ["logistics/*"]
                }
            }
        }
    ]
}
```
### **🛠 Steps to Configure Cross-Account Access**
1️⃣ Create **user `ramesh` in ACC-B** 🏢
2️⃣ Configure `ramesh` user credentials in AWS CLI:
```bash
aws configure --profile ramesh
```
✅ **Effect:** Users from **ACC-B** can access only the `logistics` folder inside the S3 bucket of **ACC-A** 🎯

---

## **🚀 Best Practices for Secure S3 Access**
🔹 **Use IAM policies** for user-specific permissions.
🔹 **Use S3 bucket policies** for additional security measures.
🔹 **Block public access** unless absolutely necessary 🚧.
🔹 **Enable MFA Delete** for sensitive objects 🔑.
🔹 **Use AWS KMS** for server-side encryption 🔐.
🔹 **Monitor S3 access logs** with AWS CloudTrail 📊.

---

## **📌 Conclusion**
IAM policies and S3 bucket policies work **together** to ensure **secure and controlled access** to Amazon S3 🎯. 
- **IAM Policies** manage access **at the user level** 👥
- **S3 Bucket Policies** provide **fine-grained access control at the bucket level** 🏗️

🚀 **By implementing these policies, you can build a more secure and scalable AWS environment!** 🔥

