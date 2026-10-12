# unofficiallinux APT repository

This repository publishes Debian 13 (**trixie**) packages through GitHub Pages.

## Add a package

Place one or more Debian packages in [`packages/`](packages/) and push them to `main`:

```text
packages/linux_7.2.9_amd64.deb
```

The workflow builds `Packages.gz`, `Release`, `Release.gpg`, and `InRelease`, then deploys them to GitHub Pages.

## Configure signing

The publishing workflow requires a GitHub Actions repository secret named `APT_GPG_PRIVATE_KEY`. Set it to the ASCII-armored private key used to sign the repository. Publish the corresponding public key separately so clients can trust it:

```bash
gpg --armor --export YOUR_KEY_ID > unofficiallinux-archive-keyring.asc
```

Never commit the private key.

## Configure GitHub Pages

In the repository settings, set **Pages → Build and deployment → Source** to **GitHub Actions**. The first workflow run will deploy the site at:

```text
https://windows10fan648.github.io/unofficiallinux/
```

## Client configuration

After downloading and installing the public archive key into `/etc/apt/keyrings/unofficiallinux.gpg`:

```bash
echo 'deb [signed-by=/etc/apt/keyrings/unofficiallinux.gpg] https://windows10fan648.github.io/unofficiallinux trixie main' \
  | sudo tee /etc/apt/sources.list.d/unofficiallinux.list
sudo apt update
```

The repository targets Debian 13 and publishes `amd64` and `all` indexes.
