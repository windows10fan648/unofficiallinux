# unofficiallinux APT repository

This repository publishes unofficiallinux packages for **Debian 13 (trixie)** through GitHub Pages.

- Repository: <https://github.com/windows10fan648/unofficiallinux>
- APT base URL: <https://windows10fan648.github.io/unofficiallinux/>
- Supported client architecture: `amd64`
- Distribution: `trixie`
- Component: `main`

## Install on Debian 13

Run the following commands on a Debian 13 `amd64` system.

### 1. Install the required tools

```bash
sudo apt update
sudo apt install --yes ca-certificates curl gnupg
```

### 2. Install the repository signing key

APT keyrings belong in `/etc/apt/keyrings`:

```bash
sudo install -d -m 0755 /etc/apt/keyrings

curl --fail --silent --show-error --location \
  https://raw.githubusercontent.com/windows10fan648/unofficiallinux/main/unofficiallinux-archive-keyring.asc \
  | sudo gpg --dearmor --yes \
      --output /etc/apt/keyrings/unofficiallinux.gpg

sudo chmod 0644 /etc/apt/keyrings/unofficiallinux.gpg
```

The published archive key has this fingerprint. Check it if you want to verify the key before trusting it:

```text
F59A C92E 458F 9594 6460 527F F814 767B 5EAD CA94
```

To display the installed key fingerprint:

```bash
gpg --show-keys --with-fingerprint /etc/apt/keyrings/unofficiallinux.gpg
```

### 3. Add the APT source

```bash
echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/unofficiallinux.gpg] https://windows10fan648.github.io/unofficiallinux trixie main' \
  | sudo tee /etc/apt/sources.list.d/unofficiallinux.list
```

### 4. Refresh package metadata

```bash
sudo apt update
```

APT should report the `unofficiallinux` repository without a missing-key or unsigned-Release error.

### 5. Search and install packages

List packages provided by this repository:

```bash
apt-cache search unofficiallinux
apt-cache policy linux-image-7.2.9 linux-headers-7.2.9 linux-libc-dev
```

Install the published kernel packages:

```bash
sudo apt install linux-image-7.2.9 linux-headers-7.2.9 linux-libc-dev
```

Review the packages before installation with:

```bash
apt show linux-image-7.2.9 linux-headers-7.2.9 linux-libc-dev
```

After installing a kernel, reboot only when you are ready:

```bash
sudo reboot
```

Check the running kernel after reboot:

```bash
uname -r
```

## Remove the repository

To stop using this repository:

```bash
sudo rm -f /etc/apt/sources.list.d/unofficiallinux.list
sudo rm -f /etc/apt/keyrings/unofficiallinux.gpg
sudo apt update
```

Removing the source does not remove packages already installed from it. To remove a package, use the normal Debian package tools, for example:

```bash
sudo apt remove linux-image-7.2.9 linux-headers-7.2.9 linux-libc-dev
```

Check the package list before removing kernel packages and keep a known-good bootable kernel installed.

## Troubleshooting

### `NO_PUBKEY`, `The following signatures couldn't be verified`, or an unsigned repository

Re-download the key and ensure the source entry refers to the same file:

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl --fail --silent --show-error --location \
  https://raw.githubusercontent.com/windows10fan648/unofficiallinux/main/unofficiallinux-archive-keyring.asc \
  | sudo gpg --dearmor --yes \
      --output /etc/apt/keyrings/unofficiallinux.gpg
sudo apt update
```

### `404 Not Found` or packages are not listed

Make sure the source uses Debian 13’s codename exactly:

```text
deb [arch=amd64 signed-by=/etc/apt/keyrings/unofficiallinux.gpg] https://windows10fan648.github.io/unofficiallinux trixie main
```

Then run:

```bash
sudo apt update
```

### Architecture mismatch

This repository currently publishes `amd64` packages. Check your architecture with:

```bash
dpkg --print-architecture
```

The result should be `amd64`.

## Publish a package

GitHub’s web file editor limits individual files to 25 MB, so upload large `.deb` files as **assets on a GitHub Release** instead of committing them to the repository:

1. Open [Releases](https://github.com/windows10fan648/unofficiallinux/releases/new).
2. Create a tag, such as `v7.2.9`.
3. Attach the `.deb` files to the release.
4. Publish the release.

Publishing a release automatically starts the Pages workflow. It downloads all `*.deb` assets from every published non-draft, non-prerelease release, so packages from older kernel releases remain available. It then rebuilds the APT metadata, signs it, and deploys the result. The workflow can also be started manually to rebuild the repository after changing release assets.

## Repository maintainer setup

GitHub Pages must use **Settings → Pages → Build and deployment → GitHub Actions**.

The publishing workflow requires these GitHub Actions repository secrets:

- `APT_GPG_PRIVATE_KEY`: ASCII-armored private archive-signing key.
- `APT_GPG_PASSPHRASE`: passphrase for the private key, if it is protected by a passphrase.

Never commit or upload either secret as a normal repository file. The public key is safe to publish as [`unofficiallinux-archive-keyring.asc`](unofficiallinux-archive-keyring.asc).
