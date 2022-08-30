#!/bin/bash

# https://releases.hashicorp.com/envconsul
# https://releases.hashicorp.com/vault

set -euo pipefail

: "${VAULT_ADDR:="https://vault.sonar.build:8200"}"
repo_config_path="${CIRRUS_WORKING_DIR}/.cirrus/secrets/"

# shellcheck disable=SC2012
repo_config_count=$(ls -1 "${repo_config_path}" 2>/dev/null | wc -l)
[ "${repo_config_count}" -lt "1" ] && {
  echo "no secrets configured"
  exit 0
}

[ "${CIRRUS_USER_PERMISSION:=x}" != "write" ] && [ ${CIRRUS_USER_PERMISSION:=x} != "admin" ] && {
  echo "not enough permissions to retrieve secrets"
  exit 1
}
hash vault || {
  echo "vault executable not available on the PATH"
  exit 1
}
hash envconsul || {
  echo "envconsul executable not available on the PATH"
  exit 1
}

tmp_file=$(mktemp -t "envconsul-vault.XXXXXXXX.hcl")
tmp_env=$(mktemp -t "env.XXXXXXXX")
# shellcheck disable=SC2064
trap "rm -f ${tmp_file} ${tmp_env}" EXIT

cat << 'EOF' > "${tmp_file}"
vault {
    namespace = "development"
    ssl {
        enabled = true
        verify  = true
    }
    retry {
        enabled = false
    }
}

upcase   = true
pristine = true

exec {
    command = "env"
}
EOF

echo "CIRRUS_ENV_SENSITIVE=true" >> "${CIRRUS_ENV}"
export CIRRUS_ENV_SENSITIVE=true

#make the vault address available to multiple build steps
echo "VAULT_ADDR=${VAULT_ADDR}" >> "${CIRRUS_ENV}"
export VAULT_ADDR

role="cirrusci-${CIRRUS_REPO_OWNER,,}-${CIRRUS_REPO_NAME,,}"
VAULT_TOKEN=$(vault write -non-interactive -field=token auth/jwt-cirrusci/login role="${role}" jwt="${CIRRUS_OIDC_TOKEN}")
export VAULT_TOKEN

envconsul -once -config="${repo_config_path}" -config="${tmp_file}" >> "${CIRRUS_ENV}"

#remove garbage env vars on windows
sed -i '/^HOME/d;/^TERM=/d;/^SYSTEMROOT=/d' "${CIRRUS_ENV}"

if grep -q PGP_PASSPHRASE "${CIRRUS_ENV}"; then
  #In order to overcome the multiline secret issue, we create the sign key file
  mkdir -p ~/.m2
  vault kv get -field key development/kv/sign > ~/.m2/sign-key.asc
fi
