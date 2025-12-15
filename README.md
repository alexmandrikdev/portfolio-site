## Deployment

1. Deploy the stack

```bash
make
```

## reCAPTCHA Configuration

To use reCAPTCHA, you need to:

1. Visit the Google reCAPTCHA Admin Console (https://www.google.com/recaptcha/admin)
2. Register your site and get Site Key and Secret Key
3. Create Docker secrets for the Site Key and Secret Key:
   ```bash
   echo "your-site-key" | docker secret create portfolio_recaptcha_site_key -
   echo "your-secret-key" | docker secret create portfolio_recaptcha_secret_key -
   ```

## Zoho API Configuration

To use Zoho Mail API, you need to:

1. Visit the Zoho API Console (https://api-console.zoho.com/)
2. Create a new OAuth client for Zoho Mail
3. Set the redirect URL to: `https://alexmandrik.dev/wp-json/portfolio/v1/zoho-auth/callback`
4. Create Docker secrets for the Client ID and Client Secret:
   ```bash
   echo "your-client-id" | docker secret create portfolio_zoho_client_id -
   echo "your-client-secret" | docker secret create portfolio_zoho_client_secret -
   ```

## Crypto Key Configuration

To use cryptographic functions, you need to generate a secure key and create a Docker secret:

Generate a secure key and create the secret in one command:

```bash
openssl rand -base64 32 | docker secret create portfolio_crypto_key -
```

Alternatively, you can generate the key first and then create the secret separately:

```bash
# Generate key
openssl rand -base64 32
# Then create secret (replace generated-key with the output)
echo "generated-key" | docker secret create portfolio_crypto_key -
```

## WP CLI

A convenience script `wp-cli.sh` is provided to dynamically retrieve the database password and run WP CLI commands.

```bash
./wp-cli.sh &lt;command&gt; [args...]
```

Examples:

```bash
./wp-cli.sh plugin list --status=active
./wp-cli.sh option get siteurl
```

The script automatically:

- Finds the running WordPress container
- Retrieves the database password from the Docker secret
- Runs the WP CLI container with the correct environment
