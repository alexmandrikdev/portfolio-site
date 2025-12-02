#!/usr/bin/env bash
set -euo pipefail

# Get the first running WordPress container from the portfolio stack
CONTAINER_NAME=$(
    docker ps \
        --filter "label=com.docker.stack.namespace=portfolio" \
        --filter "name=wordpress" \
        --format "{{.Names}}" \
    | head -n1
)

if [[ -z "$CONTAINER_NAME" ]]; then
    # Fallback to label-based discovery (Docker Swarm)
    CONTAINER_NAME=$(
        docker ps \
            --filter "label=com.docker.swarm.service.name=portfolio_wordpress" \
            --format "{{.Names}}" \
        | head -n1
    )
    if [[ -z "$CONTAINER_NAME" ]]; then
        # Fallback to name filter for compatibility
        CONTAINER_NAME=$(
            docker ps \
                --filter "name=portfolio_wordpress" \
                --format "{{.Names}}" \
            | head -n1
        )
        if [[ -z "$CONTAINER_NAME" ]]; then
            echo "Error: No running WordPress container found." >&2
            exit 1
        fi
    fi
fi

# Retrieve database connection details from container environment
DB_HOST=$(docker exec "$CONTAINER_NAME" printenv WORDPRESS_DB_HOST 2>/dev/null | tr -d '\r\n')
DB_USER=$(docker exec "$CONTAINER_NAME" printenv WORDPRESS_DB_USER 2>/dev/null | tr -d '\r\n')
DB_NAME=$(docker exec "$CONTAINER_NAME" printenv WORDPRESS_DB_NAME 2>/dev/null | tr -d '\r\n')
PASSWORD_FILE=$(docker exec "$CONTAINER_NAME" printenv WORDPRESS_DB_PASSWORD_FILE 2>/dev/null | tr -d '\r\n')

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_NAME" || -z "$PASSWORD_FILE" ]]; then
    echo "Error: Could not retrieve database credentials from container $CONTAINER_NAME." >&2
    exit 1
fi

# Retrieve the database password from the secret file inside the container
PASSWORD=$(docker exec "$CONTAINER_NAME" cat "$PASSWORD_FILE" 2>/dev/null || {
    echo "Error: Failed to retrieve password from $PASSWORD_FILE in container $CONTAINER_NAME." >&2
    exit 1
})

# Trim newline and carriage return
PASSWORD=$(echo "$PASSWORD" | tr -d '\r\n')

# Determine the network the container is attached to
NETWORK_NAME=$(
    docker inspect "$CONTAINER_NAME" \
        --format '{{range $key, $value := .NetworkSettings.Networks}}{{$key}}{{end}}' \
    2>/dev/null | head -n1
)
if [[ -z "$NETWORK_NAME" ]]; then
    echo "Error: Could not determine network for container $CONTAINER_NAME." >&2
    exit 1
fi

# If no arguments provided, show usage
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <wp-cli-command> [args...]"
    echo "Example: $0 plugin list --status=active"
    exit 0
fi

# Run the WP CLI container with the same volumes and network, injecting the password
docker run -it --rm \
    --volumes-from "$CONTAINER_NAME" \
    --network "$NETWORK_NAME" \
    -e "WORDPRESS_DB_HOST=$DB_HOST" \
    -e "WORDPRESS_DB_NAME=$DB_NAME" \
    -e "WORDPRESS_DB_USER=$DB_USER" \
    -e "WORDPRESS_DB_PASSWORD=$PASSWORD" \
    wordpress:cli-2.12.0-php8.4 "$@"