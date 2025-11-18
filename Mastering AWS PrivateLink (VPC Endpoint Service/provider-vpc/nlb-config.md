# Network Load Balancer (NLB) Configuration

This file outlines the exact configuration used for the **internal** Network Load Balancer (NLB) in the Service Provider VPC.

---

## 1. Create a Target Group

**Target Type:** Instance  
**Protocol:** TCP  
**Port:** 80  
**VPC:** 11.0.0.0/16  

### Add Targets:
- Private EC2 instance  
  - IP: `11.0.3.209`  
  - Port: `80`

---

## 2. Create Internal NLB

### Basic Settings:
- **Load Balancer Type:** Network Load Balancer  
- **Scheme:** Internal  
- **VPC:** Service Provider VPC (11.0.0.0/16)  

### Subnets:
Select **private subnet(s)** for high availability.

---

## 3. Listener Configuration

Add listener:
- **Protocol:** TCP  
- **Port:** 80  
- **Default Action:** Forward to the Target Group created earlier

---

## 4. Security Notes

- NLB does **not use security groups**, but the **backend EC2 security group must allow inbound TCP:80 from the NLB**.
- Ensure Provider EC2 allows traffic on:
  - `PORT 80`
  - `SOURCE: Target Group Health Checks + NLB`

---

## 5. Health Checks

**Health Check Protocol:** TCP  
**Port:** 80  
A healthy target must return TCP success (connection accepted).

---

## 6. Final Verification

Run:

