## Deployment

1. Deploy the stack

```bash
make
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
