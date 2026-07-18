# Step 0 — Provision the box (Oracle Cloud Always Free ARM)

**Goal:** a running Ubuntu 24.04 ARM virtual machine you can SSH into.
**Primary path:** Oracle Cloud Infrastructure (OCI) Always Free, Ampere A1 (ARM). **Free, permanently.**
**Alternative:** Hetzner Cloud, a few euros a month, no capacity lottery — jump to the bottom.

> Agent: read this whole file before guiding. The single most important thing to set expectations about is the **"Out of host capacity"** error in Step 0.6 — it is normal, it is not the user's fault, and there are three real workarounds. Do not let the user think they misconfigured something.

---

## What OCI gives you free

Oracle's Always Free tier includes Ampere A1 (ARM) compute for the life of the account. As of mid-2026 the free allocation is **2 OCPUs and 12 GB of RAM** total across your A1 instances (it was 4/24 before June 2026; existing instances provisioned under the old limit were grandfathered). Two cores and twelve gigs is plenty for this build.

- Free Tier overview: https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier.htm
- Always Free resources (current limits): https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm
- Details of Always Free compute (how OCPU/RAM are allocated): https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Details_of_the_Always_Free_compute_instances.htm

---

## 0.1 Create an account

Sign up at https://www.oracle.com/cloud/free/ . You'll need a phone number and a credit card for identity verification. **The card is not charged** on the free tier unless you deliberately upgrade to Pay As You Go.

**The home-region trap:** during signup you pick a *home region*, and Always Free A1 instances can only live there — you cannot change it later. Pick a large region with three availability domains (for example US East Ashburn, UK South London, Frankfurt). Larger regions tend to have better ARM availability.

- Getting started / sign-up: https://docs.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm

## 0.2 Create a Virtual Cloud Network (VCN)

In the Console, open the menu (hamburger, top left) → **Networking → Virtual Cloud Networks**. Use the **"Start VCN Wizard" → "Create VCN with Internet Connectivity"**. Accept the default CIDR (`10.0.0.0/16`) and let it create a public subnet. This gives the box a network with a route to the internet *outbound*.

- VCN overview: https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingVCNs.htm
- VCN wizard: https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm

## 0.3 Generate an SSH key pair (on your own machine)

You need an SSH key to log in. On your laptop:

```
ssh-keygen -t ed25519 -C "own-the-house" -f ~/.ssh/own_the_house
```

This creates `~/.ssh/own_the_house` (private — never share) and `~/.ssh/own_the_house.pub` (public — you'll paste this into OCI). On Windows, run the same command in PowerShell or Git Bash; the keys land in `C:\Users\<you>\.ssh\`.

- Managing key pairs on OCI: https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/managingkeypairs.htm

## 0.4 Create the compute instance

Menu → **Compute → Instances → Create instance**.

1. **Name** it (e.g. `house`).
2. **Placement:** leave the default availability domain (you can try others if capacity fails).
3. **Image and shape → Edit:**
   - **Image:** *Change image* → **Canonical Ubuntu** → **24.04**. Pick the **aarch64** build (ARM). The "Minimal aarch64" image is fine and lean.
   - **Shape:** *Change shape* → **Ampere** → **VM.Standard.A1.Flex**. Set **2 OCPUs** and **12 GB** memory (the free maximum). Confirm it shows the **Always Free-eligible** label.
4. **Networking:** select the VCN and public subnet from Step 0.2. **Assign a public IPv4 address** (yes, for now — we'll lock it down in Step 1).
5. **Add SSH keys:** choose **Paste public keys** and paste the contents of `~/.ssh/own_the_house.pub`.
6. **Boot volume:** default (47 GB minimum) is fine; you may raise it toward the 200 GB free block-storage limit.

- Creating an instance (full reference): https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/launchinginstance.htm
- Ubuntu on OCI images: https://documentation.ubuntu.com/oci/

## 0.5 Click Create — and watch for capacity

If it provisions, skip to 0.7. If you see **"Out of host capacity"**, that's Step 0.6.

## 0.6 If you hit "Out of host capacity" (very common)

The free ARM pool is heavily used. This error means Oracle has no free A1 hardware in that availability domain *right now*. It is not a mistake on your end. Three real fixes, in order of effort:

1. **Retry, and rotate availability domains.** Re-submit every few minutes; switch AD-1 / AD-2 / AD-3 in the placement step. Capacity frees up constantly.
2. **Try a quieter region** — but remember the home-region trap: you can only use your *home* region for free A1. If you haven't committed to workloads yet and picked a busy home region, a fresh account in a quieter region (Frankfurt, Singapore) is an option.
3. **Upgrade to Pay As You Go.** This does **not** charge you for staying within Always Free limits, but it moves you to a larger capacity pool and usually provisions immediately. This is the reliable fix if you keep failing.

A common automation trick: on the create screen choose **"Save as stack"** instead of Create, which saves a Terraform config you can re-apply on a loop until capacity appears.

- Free tier capacity notes: https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm

## 0.7 Connect over SSH

Once the instance shows **Running**, copy its **public IP** from the instance page. Default Ubuntu user on OCI is `ubuntu`:

```
ssh -i ~/.ssh/own_the_house ubuntu@<PUBLIC_IP>
```

- Connecting to an instance: https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/accessinginstance.htm

## 0.8 Update the system

```
sudo apt update && sudo apt -y upgrade
```

---

## ✅ Verification (must pass before Step 1)

Run on the box:

```
uname -m          # expect: aarch64
lsb_release -a    # expect: Ubuntu 24.04
nproc             # expect: 2  (or 4 if grandfathered)
free -h           # expect: ~12Gi total (or ~24Gi if grandfathered)
```

If you can SSH in and those match, Step 0 is done. **Do not install anything else yet** — the very next thing we do (Step 1) is close the public door you just opened.

---

## Alternative path: Hetzner Cloud (rent, no lottery)

If the OCI capacity dance isn't worth it, rent. Hetzner's **CAX21** is 4 ARM cores / 8 GB / 80 GB disk for about €8/month, provisioned in minutes.

1. Create an account: https://console.hetzner.cloud/
2. **New Server** → Location (EU or US) → **Image: Ubuntu 24.04** → **Type: Arm64 (Ampere) → CAX21** → add your SSH public key → Create.
3. SSH in as `root@<IP>` with your key, then `apt update && apt -y upgrade`.

- Creating a server: https://docs.hetzner.com/cloud/servers/getting-started/creating-a-server/
- Server types (CAX ARM line): https://docs.hetzner.com/cloud/servers/overview/

Then rejoin at **Step 1**. Everything downstream is identical.
