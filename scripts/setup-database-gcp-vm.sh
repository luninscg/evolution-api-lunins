#!/bin/bash
# Install PostgreSQL or MySQL on Ubuntu and create evolution_db + user.
# Run: bash scripts/setup-database-gcp-vm.sh [postgresql|mysql]
# Or: AUTO_INSTALL_DATABASE=postgresql bash scripts/setup-gcp-vm.sh (calls this script)
# Outputs DATABASE_PROVIDER and DATABASE_CONNECTION_URI to paste into .env

set -e

DB_TYPE="${1:-$AUTO_INSTALL_DATABASE}"
DB_TYPE="${DB_TYPE:-postgresql}"

if [ "$DB_TYPE" != "postgresql" ] && [ "$DB_TYPE" != "mysql" ]; then
  echo "Usage: bash scripts/setup-database-gcp-vm.sh [postgresql|mysql]"
  exit 1
fi

# Random password for the evolution user (safe for connection URI)
gen_pass() {
  openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 24
}

echo "=== Installing $DB_TYPE and creating database for Evolution API ==="

if [ "$DB_TYPE" = "postgresql" ]; then
  sudo apt-get update
  sudo apt-get install -y postgresql postgresql-contrib

  DB_USER="evolution"
  DB_NAME="evolution_db"
  DB_PASS="$(gen_pass)"

  sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';" 2>/dev/null || true
  sudo -u postgres psql -c "ALTER USER $DB_USER WITH PASSWORD '$DB_PASS';" 2>/dev/null || true
  sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" 2>/dev/null || true
  sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

  # Escape for URI (only & and : and @ and / need care; password is alphanumeric)
  CONN_URI="postgresql://$DB_USER:$DB_PASS@localhost:5432/$DB_NAME"
  echo ""
  echo ">>> PostgreSQL ready. Add these lines to your .env file:"
  echo ""
  echo "DATABASE_PROVIDER=postgresql"
  echo "DATABASE_CONNECTION_URI=$CONN_URI"
  echo ""
  echo ">>> Save this password (not stored elsewhere): $DB_PASS"
  echo ""

  # If called from setup-gcp-vm.sh with AUTO_INSTALL_DATABASE, write to .env
  if [ -n "$AUTO_INSTALL_DATABASE" ] && [ -f .env ]; then
    sed -i.bak "s|^DATABASE_PROVIDER=.*|DATABASE_PROVIDER=postgresql|" .env 2>/dev/null || true
    grep -q "^DATABASE_CONNECTION_URI=" .env && sed -i.bak "s|^DATABASE_CONNECTION_URI=.*|DATABASE_CONNECTION_URI=$CONN_URI|" .env || echo "DATABASE_CONNECTION_URI=$CONN_URI" >> .env
    echo ">>> Written DATABASE_PROVIDER and DATABASE_CONNECTION_URI to .env"
  fi
fi

if [ "$DB_TYPE" = "mysql" ]; then
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

  DB_USER="evolution"
  DB_NAME="evolution_db"
  DB_PASS="$(gen_pass)"

  sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS'; CREATE DATABASE IF NOT EXISTS $DB_NAME; GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost'; FLUSH PRIVILEGES;"

  # MySQL URI: encode password if it has special chars (here it's alphanumeric)
  CONN_URI="mysql://$DB_USER:$DB_PASS@localhost:3306/$DB_NAME"
  echo ""
  echo ">>> MySQL ready. Add these lines to your .env file:"
  echo ""
  echo "DATABASE_PROVIDER=mysql"
  echo "DATABASE_CONNECTION_URI=$CONN_URI"
  echo ""
  echo ">>> Save this password (not stored elsewhere): $DB_PASS"
  echo ""

  if [ -n "$AUTO_INSTALL_DATABASE" ] && [ -f .env ]; then
    sed -i.bak "s|^DATABASE_PROVIDER=.*|DATABASE_PROVIDER=mysql|" .env 2>/dev/null || true
    grep -q "^DATABASE_CONNECTION_URI=" .env && sed -i.bak "s|^DATABASE_CONNECTION_URI=.*|DATABASE_CONNECTION_URI=$CONN_URI|" .env || echo "DATABASE_CONNECTION_URI=$CONN_URI" >> .env
    echo ">>> Written DATABASE_PROVIDER and DATABASE_CONNECTION_URI to .env"
  fi
fi
