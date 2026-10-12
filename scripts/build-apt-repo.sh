#!/usr/bin/env bash
set -euo pipefail

output_dir="${1:-site}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
packages_dir="$repo_root/packages"

mapfile -t debs < <(find "$packages_dir" -type f -name '*.deb' -print | sort)
if ((${#debs[@]} == 0)); then
  echo "No .deb files found under packages/. Add the Debian 13 package before publishing." >&2
  exit 1
fi

rm -rf "$output_dir"
mkdir -p "$output_dir/pool/main" "$output_dir/dists/trixie/main/binary-amd64" "$output_dir/dists/trixie/main/binary-all"
cp "${debs[@]}" "$output_dir/pool/main/"

dpkg-scanpackages --multiversion "$output_dir/pool/main" /dev/null \
  | gzip -9n > "$output_dir/dists/trixie/main/binary-amd64/Packages.gz"
cp "$output_dir/dists/trixie/main/binary-amd64/Packages.gz" \
  "$output_dir/dists/trixie/main/binary-all/Packages.gz"

cat > "$output_dir/dists/trixie/Release" <<'RELEASE'
Origin: unofficiallinux
Label: unofficiallinux
Suite: trixie
Codename: trixie
Architectures: amd64 all
Components: main
Description: unofficiallinux packages for Debian 13
RELEASE
apt-ftparchive release "$output_dir/dists/trixie" \
  | sed -e '1,/^Date:/d' >> "$output_dir/dists/trixie/Release"

if [[ -z "${APT_GPG_PRIVATE_KEY:-}" ]]; then
  echo "APT_GPG_PRIVATE_KEY is required to sign the repository Release file." >&2
  exit 1
fi

tmp_home="$(mktemp -d)"
trap 'rm -rf "$tmp_home"' EXIT
chmod 700 "$tmp_home"
printf '%s\n' "$APT_GPG_PRIVATE_KEY" | gpg --batch --homedir "$tmp_home" --import
key_id="$(gpg --batch --homedir "$tmp_home" --with-colons --list-secret-keys | awk -F: '$1 == "sec" {print $5; exit}')"
if [[ -z "$key_id" ]]; then
  echo "No secret key was found in APT_GPG_PRIVATE_KEY." >&2
  exit 1
fi

sign_args=(--batch --yes --pinentry-mode loopback --homedir "$tmp_home" --local-user "$key_id")
if [[ -n "${APT_GPG_PASSPHRASE:-}" ]]; then
  sign_args+=(--passphrase "$APT_GPG_PASSPHRASE")
fi

gpg "${sign_args[@]}" --armor \
  --detach-sign --output "$output_dir/dists/trixie/Release.gpg" "$output_dir/dists/trixie/Release"
gpg "${sign_args[@]}" --clearsign \
  --output "$output_dir/dists/trixie/InRelease" "$output_dir/dists/trixie/Release"

cat > "$output_dir/index.html" <<'HTML'
<!doctype html>
<meta charset="utf-8">
<title>unofficiallinux APT repository</title>
<h1>unofficiallinux APT repository</h1>
<p>Debian 13 (trixie) packages.</p>
HTML

echo "Built signed Debian 13 repository in $output_dir"
