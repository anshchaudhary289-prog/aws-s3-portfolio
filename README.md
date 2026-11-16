# AWS S3 Static Portfolio Website

A personal portfolio website hosted on **AWS S3** using static website hosting — built and deployed by hand through the AWS Console during the AWS Academy Cloud Architecting course, then re-deployable in one command with the script in this repo.

**The site itself:** a single self-contained `index.html` (214 lines, inline CSS, no build step, no dependencies) with a dark GitHub-style theme — hero, about, skills grid, projects, hackathons and contact sections.

> **Live URL:** _Not recorded — the original deployment ran in an AWS Academy lab environment, which is temporary, so no live link is claimed here._
> When the site is re-deployed to a personal AWS account, paste the S3 website endpoint here:
> `http://<your-bucket-name>.s3-website.<region>.amazonaws.com`

---

## Architecture

```text
Visitor's browser
       |
       |  HTTP request
       v
S3 bucket (static website hosting enabled)
  - index.html served as the index document
  - Block Public Access: OFF (for this public site only)
  - Bucket policy: public s3:GetObject on bucket objects
       |
       v
index.html  (single file — HTML + inline CSS)
```

There is no server, no database and nothing to patch — S3 stores the file and serves it directly. That is exactly why static hosting is the right tool for a portfolio page.

## What the site contains

| Section | What is in it |
|---|---|
| Hero | Name, "B.Tech CSE Student · AWS Cloud Enthusiast · MIET Meerut", open-to-opportunities badge (2027 batch) |
| About | Education (MIET Meerut, AKTU, 2023–2027), focus area, AWS Academy learning, interests |
| Skills | AWS S3, AWS EC2, Cloud Architecting (VPC / IAM / Load Balancing), Python, Cybersecurity basics, Gen AI APIs |
| Projects | This S3 portfolio + the EC2 web server deployment, each linked to its GitHub repo |
| Hackathons | HackerRank Orchestrate Hackathon (June 2026) — multi-modal AI claim-verification system using the Gemini API |
| Contact | Email and GitHub links |

## Deployment — step by step (Console)

1. **Create the bucket** — S3 → Create bucket, pick a globally unique name (e.g. `ansh-portfolio-<unique-suffix>`) and a region close to your audience (e.g. `ap-south-1`, Mumbai). Keep "Block all public access" **checked for now**.
2. **Upload the site** — open the bucket → Upload → add `index.html` from this repo.
3. **Enable static website hosting** — bucket → Properties → Static website hosting → Enable → Hosting type: *Host a static website* → Index document: `index.html`.
4. **Make it public (this step is deliberate)** — bucket → Permissions → Block public access → uncheck all four options and confirm. Do this **only** because this bucket holds a public website and nothing private — never do this for a bucket with personal files.
5. **Attach the bucket policy** — Permissions → Bucket policy → paste the policy from [`bucket-policy.json`](bucket-policy.json) in this repo, replacing `YOUR-BUCKET-NAME` with your bucket name, and save.
6. **Open the site** — Properties → Static website hosting shows your website endpoint. Open it in a browser and check the page loads.

## Deployment — one command (AWS CLI)

After steps 1, 3, 4 and 5 above are done once, every update is a single sync:

```bash
# one-time: configure the bucket name
export S3_BUCKET="your-bucket-name"

# every update:
./deploy.sh
# — or directly:
aws s3 sync . s3://$S3_BUCKET --exclude ".git/*" --exclude "README.md" --delete
```

`deploy.sh` in this repo wraps that sync, prints the website endpoint afterwards, and fails loudly if `S3_BUCKET` is not set.

## Run it locally

```bash
python3 -m http.server 8000
# open http://localhost:8000
```

## Screenshots

See [`docs/screenshots.md`](docs/screenshots.md) — a screenshot of the deployed page (hero + skills sections) belongs in `docs/` and should be linked here once the site is re-deployed and the screenshot is taken from that live deployment.

## Tech stack

- **AWS S3** — static website hosting, bucket policies, public-access configuration
- **HTML / CSS** — single file, inline styles, responsive layout, no framework
- **AWS CLI** — `aws s3 sync` deployments via `deploy.sh`

## What I learned

- How S3 static website hosting actually works end to end: index document, website endpoint vs REST endpoint, and why both are different.
- Bucket policies are JSON IAM-style documents — a single wrong `Resource` ARN silently means "access denied" for everyone.
- "Block Public Access" is a safety rail, not a bug: turning it off is a conscious, scoped decision for a public website bucket only.
- A static site needs no server at all — the cheapest and most reliable hosting is the one with nothing running.

## Author

**Ansh Chaudhary** — Final Year B.Tech CSE, MIET Meerut · Cloud & DevOps
LinkedIn: https://www.linkedin.com/in/ansh-chaudhary-cse
GitHub: https://github.com/anshchaudhary289-prog
