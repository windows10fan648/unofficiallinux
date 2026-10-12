# unofficiallinux APT repository

This repository publishes Debian 13 (**trixie**) packages through GitHub Pages.

## Publish a package

GitHub’s web file editor limits individual files to 25 MB, so upload large `.deb` files as **assets on a GitHub Release** instead of committing them to the repository:

1. Open [Releases](https://github.com/windows10fan648/unofficiallinux/releases/new).
2. Create a tag such as `v7.2.9`.
3. Attach the `.deb` file(s) to the release.
4. Publish the release.

Publishing a release automatically starts the Pages workflow. It downloads all `*.deb` release assets, builds the APT metadata, and deploys the result. You can also run the workflow manually and provide an existing release tag.

## Configure signing

The publishing workflow requires a GitHub Actions repository secret named `APT_GPG_PRIVATE_KEY`. Set it to the ASCII-armored private key used to sign the repository. Publish the corresponding public key separately so clients can trust it:

```bash
gpg --armor --export YOUR_KEY_ID > unofficiallinux-archive-keyring.asc
```

Never commit the private key.

## Configure GitHub Pages

In the repository settings, set **Pages → Build and deployment → Source** to **GitHub Actions**. The site will be deployed at:

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
