# 🛡️ **AWS PrivateLink (VPC Endpoint Service) — Cross-VPC Private Service Sharing**

This repository documents the implementation of **AWS PrivateLink** (VPC Endpoint Service) to securely expose an application running inside a **Service Provider VPC** to a **Service Consumer VPC**, *without using the public internet, VPC peering, or a VPN*.

PrivateLink ensures that all traffic remains inside the **AWS internal network** and provides secure, controlled, and scalable connectivity between VPCs or AWS accounts.

---

# 📘 **1. Project Goal & Overview**

The goal of this project is to simulate a real-world enterprise scenario where:

* A **Provider VPC** hosts a private service (HTTP application).
* A **Consumer VPC** wants to securely access that private service.
* The communication must be **private**, **secure**, and **isolated**.
* The service should *not* be exposed on the Internet.

To achieve this, we used **AWS PrivateLink**, **Network Load Balancer (NLB)**, and **Interface VPC Endpoints**.

---

# 🏗️ **2. Architecture Diagram**

```
Service Consumer VPC (21.0.0.0/16)
-------------------------------------------------------
Private EC2 (21.0.3.200)
        |
        |--> Interface VPC Endpoint
        |
        v
AWS PrivateLink
-------------------------------------------------------
        |
        |--> Endpoint Service (Provider)
        |
Service Provider VPC (11.0.0.0/16)
-------------------------------------------------------
NLB (Internal)
        |
        v
Target Group (TCP 80)
        |
        v
Private EC2 (11.0.3.209) — Apache Web Server
```

Add your diagram here once uploaded:

```markdown
![Architecture](diagrams/vpc-privatelink-architecture.png)
```

---

# 🗂️ **3. Actual Resources Used (Your Setup)**

### 🟩 **Service Provider VPC (11.0.0.0/16)**

| Resource                     | Purpose                         | IP Address                                           |
| ---------------------------- | ------------------------------- | ---------------------------------------------------- |
| service-provider-public-ec2  | Jumpbox/Public EC2              | **13.126.7.171** (public) / **11.0.1.103** (private) |
| service-provider-private-ec2 | Apache Server (Private Subnet)  | **11.0.3.209**                                       |
| NLB (Internal)               | Forwards TCP 80 to Private EC2  | —                                                    |
| Target Group                 | TCP Target: 11.0.3.209:80       | —                                                    |
| Endpoint Service             | Exposes service via PrivateLink | —                                                    |

---

### 🟦 **Service Consumer VPC (21.0.0.0/16)**

| Resource                     | Purpose                          | IP Address                                 |
| ---------------------------- | -------------------------------- | ------------------------------------------ |
| service-consumer-public-ec2  | Jumpbox                          | **13.127.49.65** (public) / **21.0.1.202** |
| service-consumer-private-ec2 | Client EC2 to access service     | **21.0.3.200**                             |
| Interface VPC Endpoint       | Connects to Provider PrivateLink | Auto-created IPs                           |

---

### 🔗 **VPC Endpoint DNS Name (Your Actual DNS)**

```
vpce-0aa87ebfac87f2f58-qlrfjj0h.vpce-svc-05e411f29dec771d1.ap-south-1.vpce.amazonaws.com
```

This DNS is used by the **consumer EC2** to reach the **provider EC2** privately.

---

# 💡 **4. Components & Roles**

### **A) Service Provider VPC Components**

* Private EC2 runs Apache/HTTPD
* NLB (Internal only) forwards requests
* Target group registers the private EC2
* Endpoint Service connects NLB to PrivateLink
* Allowed Principals used to control consumer access

### **B) Service Consumer VPC Components**

* Private EC2 to perform test requests
* Public EC2 as bastion (jumpbox)
* Interface VPC Endpoint to connect to Provider Endpoint Service

---

# ⚙️ **5. Step-by-Step Setup Summary**

## **🟩 Provider VPC**

### ✔ Create VPC: `11.0.0.0/16`

✔ Create public + private subnets
✔ Attach Internet Gateway
✔ Create route tables

### ✔ Launch Private EC2 (Apache Web Server)

SSH through provider public EC2:

```bash
ssh -i key.pem ec2-user@13.126.7.171
ssh -i key.pem ec2-user@11.0.3.209
```

Install Apache:

```bash
sudo yum install -y httpd
sudo systemctl enable --now httpd
echo "demo for AWS private link / service provider ec2" | sudo tee /var/www/html/index.html
```

### ✔ Create Target Group (TCP 80 → Private EC2)

### ✔ Create Internal NLB

* Type: **Internal**
* Listener: **TCP:80**
* Forward to Target Group

### ✔ Create VPC Endpoint Service

* Choose the NLB
* Enable **Require Acceptance**
* Add consumer account as **Allowed Principal**

---

## **🟦 Consumer VPC**

### ✔ Create VPC: `21.0.0.0/16`

✔ Create public + private subnets
✔ Launch public jumpbox EC2
✔ Launch private EC2 (client)

### ✔ Create Interface VPC Endpoint

Paste provider service name:

```
com.amazonaws.vpce.ap-south-1.vpce-svc-05e411f29dec771d1
```

✔ Choose private subnet
✔ Attach security group allowing outbound TCP 80

### ✔ Provider accepts endpoint request

---

# 🧪 **6. Verification / Testing (Using Your Real IPs)**

### **Step 1 — SSH into Consumer Public EC2**

```bash
ssh -i key.pem ec2-user@13.127.49.65
```

### **Step 2 — SSH into Consumer Private EC2**

```bash
ssh -i key.pem ec2-user@21.0.3.200
```

### **Step 3 — Curl the Endpoint DNS**

```bash
curl http://vpce-0aa87ebfac87f2f58-qlrfjj0h.vpce-svc-05e411f29dec771d1.ap-south-1.vpce.amazonaws.com
```

### **Expected Output**

```
demo for AWS private link / service provider ec2
```

🎉 **Success — PrivateLink is working end-to-end!**

---

# 🔐 **7. Security Architecture**

* Provider EC2 has **no public IP**
* Provider EC2 only accepts traffic from **NLB**
* Consumer EC2 has **private access only**
* Endpoint Service requires **manual acceptance**
* NAT Gateway temporarily used to install packages (deleted afterward)
* No VPC peering required
* No public exposure of application

---

# 📁 **8. Repository Structure**

```
├── diagrams/
│   └── vpc-privatelink-architecture.png
│
├── provider-vpc/
│   ├── httpd-install.sh
│   ├── nlb-config.md
│   └── endpoint-service-config.md
│
├── consumer-vpc/
│   ├── endpoint-creation.md
│   ├── test-commands.sh
│   └── ssh-instructions.md
│
└── README.md
```

---

# 📝 **9. Useful Commands**

### Change key permissions

```bash
chmod 400 key.pem
```

### Apache setup

```bash
sudo yum install -y httpd
sudo systemctl enable --now httpd
```

### Test PrivateLink directly

```bash
curl http://<your-endpoint-dns>
```

---

# 🧠 **10. Learnings & Takeaways**

* How AWS PrivateLink enables *secure private connectivity*
* Why NLB is required for VPC Endpoint Services
* Isolating workloads using private subnets
* Cross-VPC/cross-account service sharing
* Using NAT Gateway temporarily for provisioning
* Using Interface Endpoints for private consumption

---

# 🚀 **11. Future Enhancements**

* Replace EC2 with **RDS MySQL + PrivateLink**
* Automate complete infra using **Terraform**
* Add **AWS WAF**
* Add **Private DNS** for seamless resolution
* Configure CloudWatch monitoring & dashboards

---

