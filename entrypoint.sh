#!/usr/bin/env bash
set -euo pipefail

yaml_escape() {
  local value="${1-}"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  printf '%s' "$value"
}

wait_for_tcp() {
  local host="$1"
  local port="$2"
  local label="$3"
  local attempts="${4:-30}"
  local i

  for ((i = 1; i <= attempts; i++)); do
    if : >"/dev/tcp/${host}/${port}" 2>/dev/null; then
      return 0
    fi
    sleep 2
  done

  printf '等待%s超时: %s:%s\n' "$label" "$host" "$port" >&2
  return 1
}

has_runtime_env=false
for name in MYSQLHOST MYSQLPORT MYSQLUSER MYSQLPASSWORD MYSQLDATABASE REDISHOST REDISPORT APP_FILE_DOMAIN PUBLIC_URL JWT_SECRET; do
  if [[ -n "${!name-}" ]]; then
    has_runtime_env=true
    break
  fi
done

if [[ "$has_runtime_env" == true ]]; then
  cat > /app/config.yaml <<EOF
database:
  default:
    type: "mysql"
    host: "$(yaml_escape "${MYSQLHOST:-mysql}")"
    port: "$(yaml_escape "${MYSQLPORT:-3306}")"
    user: "$(yaml_escape "${MYSQLUSER:-root}")"
    pass: "$(yaml_escape "${MYSQLPASSWORD:-123456}")"
    name: "$(yaml_escape "${MYSQLDATABASE:-cool}")"
    charset: "utf8mb4"
    timezone: "Asia/Shanghai"
    createdAt: "createTime"
    updatedAt: "updateTime"

redis:
  cool:
    address: "$(yaml_escape "${REDISHOST:-redis}:${REDISPORT:-6379}")"
    db: 0

cool:
  autoMigrate: true
  eps: true
  file:
    mode: "local"
    domain: "$(yaml_escape "${APP_FILE_DOMAIN:-${PUBLIC_URL:-http://127.0.0.1:8300}}")"

modules:
  base:
    jwt:
      sso: false
      secret: "$(yaml_escape "${JWT_SECRET:-cool-admin-go}")"
      token:
        expire: 7200
        refreshExpire: 1296000
    middleware:
      authority:
        enable: 1
      log:
        enable: 1
EOF
fi

if [[ -n "${MYSQLHOST-}" ]]; then
  wait_for_tcp "${MYSQLHOST}" "${MYSQLPORT:-3306}" "数据库"
fi

if [[ -n "${REDISHOST-}" ]]; then
  wait_for_tcp "${REDISHOST}" "${REDISPORT:-6379}" "缓存"
fi

exec "$@"
