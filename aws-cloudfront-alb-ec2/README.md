🚀 AWS CloudFront → ALB → EC2 Web Hosting (Secure Architecture)

This project demonstrates how to deploy a **secure, scalable, production-grade web hosting architecture** on AWS using:

* **Amazon EC2** (Web server)
* **Application Load Balancer (ALB)**
* **Amazon CloudFront** (CDN + security layer)
* **Security Groups + AWS Prefix Lists**
* **Automatic EC2 web page deployment via User Data**

This setup ensures:

✔ Traffic flows **only**: CloudFront → ALB → EC2
✔ ALB is **not directly accessible from the internet**
✔ EC2 is protected and can receive traffic only from ALB
✔ CloudFront provides caching, global distribution, and HTTPS

---

## 📂 Project Overview

```
User → CloudFront → ALB → EC2 → Web Page
```

The EC2 instance automatically creates a web page using a **User Data script** and is placed behind an Application Load Balancer.
CloudFront sits in front of the ALB and becomes the **only public entry point**.

---

# 🛠 1. Launch EC2 Instance

### Settings

* AMI: **Amazon Linux 2 / ubuntu** (recommended)
* Instance type: **t2.micro** (free-tier)
* Subnet: Public subnet
* Auto-assign Public IP: Enabled
* Security Group:

  ```
  SSH 22  → your IP only
  HTTP 80 → (temporary) 0.0.0.0/0
  ```

---

# 📝 2. Add User Data (Auto-create Web Page)

Create and serve a simple webpage at boot:

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head><title>Welcome to My EC2 Web Page</title></head>
<body style="font-family: Arial; text-align:center; margin-top: 70px;">
<h1>🚀 Welcome to My EC2 Web Page</h1>
<p>This content was created using EC2 User Data.</p>
</body>
</html>
EOF
```

---

# 🎯 3. Create Target Group

1. Go to **EC2 → Target Groups → Create**
2. Target type: **Instances**
3. Protocol: **HTTP**
4. Port: **80**
5. Register the EC2 instance
6. Wait until status = **healthy**

---

# ⚙️ 4. Create Application Load Balancer (ALB)

1. Go to **EC2 → Load Balancers → Create Load Balancer**
2. Type: **Application Load Balancer**
3. Scheme: **Internet-facing**
4. Select **2 public subnets in different AZs**
5. Create listener:

   ```
   HTTP : 80 → Target Group (created above)
   ```

Test ALB:

```
http://app-alb-879811614.ap-south-1.elb.amazonaws.com/
```

---

# 🌍 5. Create CloudFront Distribution

### Origin Settings

* **Origin Domain**: `app-alb-879811614.ap-south-1.elb.amazonaws.com-mi3bkafwn84`
* **Origin Protocol Policy**: HTTP Only
* **Origin Port**: 80

### Behavior Settings

* Viewer protocol policy: **Redirect HTTP to HTTPS**
* Allowed methods: GET, HEAD

Wait until **Status = Deployed**

Test:

```
https://d3fgrfvnigq6ss.cloudfront.net/
```

---

# 🔒 6. Restrict ALB to CloudFront Only

By default ALB accepts public traffic. We tighten it:

## Step A — Create ALB Security Group

Inbound:

```
HTTP 80
Source: Prefix List → com.amazonaws.global.cloudfront.origin-facing
```

## Step B — Attach to ALB

1. ALB → **Security** → Edit
2. Attach the new SG
3. Remove old SG with 0.0.0.0/0

Result:

* ALB cannot be accessed directly from the internet
* CloudFront can access ALB (allowed by prefix list)

---

# 🔒 7. Restrict EC2 to ALB Only

Edit EC2 security group:

Remove:

```
HTTP 80 → 0.0.0.0/0
```

Add:

```
HTTP 80
Source: ALB Security Group
```

Now:

```
Internet ❌→ ALB
Internet ❌→ EC2
CloudFront ✔→ ALB ✔→ EC2
```

---

# 🧪 8. Testing

### Test allowed:

```
https://d3fgrfvnigq6ss.cloudfront.net/
```

### Test blocked:

```
http://app-alb-879811614.ap-south-1.elb.amazonaws.com/
http://43.205.126.210/
```

Both should fail (expected).

---

# 📦 9. Repository Structure

```
aws-cloudfront-alb-ec2/
│
├── README.md
├── architecture.png

```

---

# 🧾 10. Summary

This project demonstrates:

✔ Secure AWS web hosting
✔ EC2 automation using User Data
✔ Load balancing with ALB
✔ Global content distribution with CloudFront
✔ CloudFront-only access to ALB using prefix lists
✔ Proper security group isolation
✔ Production-grade architecture

