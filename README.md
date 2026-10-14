# Kilo CLI in Docker

Run Kilo CLI inside Docker while keeping your source code on your local
computer. This setup builds a custom Docker image with Kilo installed
**once**, mounts your local project directory into the container, and
persists Kilo's configuration in Docker named volumes.

## What this setup provides

- Kilo CLI preinstalled in a reusable Docker image.
- No `npm install` every time you launch Kilo.
- Your project files mounted from your host into `/workspace`.
- Persistent Kilo configuration and authentication data in named
  volumes.
- An interactive terminal for using Kilo.
- No need to install Node.js or Kilo CLI directly on your host.

> **Safety:** Kilo is an agentic coding tool. It can modify files and
> run commands. Use Git or backups, review changes, and mount only
> directories you want it to access.

## 1. Prerequisites

Install Docker Desktop on Windows/macOS, or Docker Engine and the Docker
Compose plugin on Linux.

Verify the installation:

```bash
docker --version
docker compose version
```

## 2. Create the directory structure

Create a folder named `kilo-docker` with a `workspace` subdirectory:

```text
kilo-docker/
├── Dockerfile
├── docker-compose.yml
├── README.md
└── workspace/
    └── .gitkeep
```

### Windows PowerShell

```powershell
mkdir kilo-docker
cd kilo-docker
mkdir workspace
New-Item workspace/.gitkeep -ItemType File
```

### macOS/Linux

```bash
mkdir -p kilo-docker/workspace
cd kilo-docker
touch workspace/.gitkeep
```

Create `Dockerfile` and `docker-compose.yml` in the `kilo-docker`
directory using the contents below.

If you already have a project, copy its files into `workspace/`.
Alternatively, change the volume mapping in Compose to mount your
existing project path directly.

Examples:

```yaml
# Windows: replace with your actual directory
- "C:/Users/your-user/source/my-project:/workspace"

# Linux/macOS: replace with your actual directory
- "/home/your-user/source/my-project:/workspace"
```

Use forward slashes in Windows Compose paths. Ensure Docker Desktop is
allowed to access the selected folder or drive.

## 3. Create the Dockerfile

Save this as `Dockerfile` (with no file extension) in `kilo-docker/`:

```dockerfile
FROM node:22-bookworm

RUN npm install -g @kilocode/cli

WORKDIR /workspace

CMD ["kilo"]
```

### Why use a Dockerfile?

The `RUN npm install -g @kilocode/cli` command runs **when the image is
built**, not each time you start a CLI session. Docker caches the
resulting image layer and reuses it for later launches. You only need to
rebuild when you intentionally want to update the image or when its
build inputs change.

## 4. Create `docker-compose.yml`

Save this file next to the Dockerfile:

```yaml
services:
  kilo:
    build: .
    image: local/kilo-cli:latest
    working_dir: /workspace
    stdin_open: true
    tty: true
    init: true
    volumes:
      - ./workspace:/workspace
      - kilo-config:/root/.config/kilo
      - kilo-data:/root/.local/share/kilo

volumes:
  kilo-config:
  kilo-data:
```

### What the settings mean

---

Setting Purpose

---

`build: .` Builds the image using the
Dockerfile in this directory.

`image: local/kilo-cli:latest` Gives the locally built image a
stable name.

`working_dir: /workspace` Opens Kilo in the mounted project
directory.

`stdin_open` and `tty` Keep an interactive terminal
available.

`init: true` Adds a small init process to handle
signals and child processes more
cleanly.

`./workspace:/workspace` Makes host project files available
inside the container.

`kilo-config` Persists files under
`/root/.config/kilo`.

`kilo-data` Persists files under
`/root/.local/share/kilo`, if the
CLI uses this location.

---

The sample container runs as root, so Kilo's home directory is `/root`.
The named volumes are managed by Docker and survive normal container
removal.

## 5. Build the image once

Run these commands from the `kilo-docker/` directory:

```bash
docker compose build
```

This downloads the base Node image if needed and installs Kilo in the
custom image. The first build requires internet access and can take a
little time.

To see the locally available images:

```bash
docker image ls
```

You should see `local/kilo-cli` in the output.

## 6. Launch Kilo

Start an interactive session:

```bash
docker compose run --rm kilo
```

Docker creates a temporary container from the existing
`local/kilo-cli:latest` image. It does **not** run `npm install` again.
When you exit, the temporary container is removed, while the image, your
host files, and the named volumes remain.

The next session uses the same command:

```bash
docker compose run --rm kilo
```

You do not need to run `docker compose build` before every session.

### Verify the CLI

```bash
docker compose run --rm kilo kilo --version
docker compose run --rm kilo kilo --help
```

These commands create temporary containers too, but use the
already-built image.

## 7. Authenticate Kilo and choose a model

The exact providers and authentication options depend on the installed
Kilo CLI version. Refer to the [official Kilo CLI
guide](https://kilo.ai/docs/code-with-ai/platforms/cli).

### Interactive setup (recommended)

1.  Launch Kilo:

    ```bash
    docker compose run --rm kilo
    ```

2.  At the Kilo prompt, enter:

    ```text
    /connect
    ```

3.  Choose a provider from the options displayed.

4.  Follow the prompts to sign in or supply the provider's API key.

5.  If a browser login is offered, complete it in your host browser.
    Follow any URL or device-code instructions printed by the CLI.

6.  Choose a model if prompted. Use `/models` if supported by your
    current version to change models.

7.  Test with a small task, such as asking Kilo to summarize the project
    structure.

### Check CLI authentication commands

The CLI also provides authentication commands in supported versions.
Check the installed version's help:

```bash
docker compose run --rm kilo kilo auth --help
docker compose run --rm kilo kilo auth list
```

If supported by your installed version, you can start a login flow with:

```bash
docker compose run --rm kilo kilo auth login
```

If a command differs or is unavailable, use `/connect` inside the
interactive CLI and follow the current documentation.

### Where authentication is saved

This Compose file mounts:

- `/root/.config/kilo` to the Docker named volume `kilo-config`
- `/root/.local/share/kilo` to the Docker named volume `kilo-data`

Kilo's global configuration is documented under `~/.config/kilo/`; with
this container's root user, that path is `/root/.config/kilo/`. The
named volumes persist across `docker compose run --rm` sessions.

To inspect the volumes:

```bash
docker volume ls
```

Compose generally prefixes volume names with the project name, for
example `kilo-docker_kilo-config`. Run Compose from the same project
directory and with the same project name to reuse them.

**Keep credentials private.** Do not put API keys in this README, source
code, or version control. Anyone with sufficient access to your Docker
host may be able to access the Docker volumes.

## 8. Work on your local project

Place project files under `workspace/`:

```text
kilo-docker/
├── Dockerfile
├── docker-compose.yml
├── README.md
└── workspace/
    ├── app.py
    ├── requirements.txt
    └── ...
```

Launch Kilo:

```bash
docker compose run --rm kilo
```

Try a review-first prompt:

```text
Inspect this project, summarize its structure, and identify likely bugs.
Do not modify any files until you explain the proposed changes.
```

Files Kilo creates or edits inside `/workspace` are reflected in your
local `workspace/` directory immediately.

### Mount a different project directory

Change:

```yaml
- ./workspace:/workspace
```

to an absolute path for your project. For example:

```yaml
- "C:/Users/your-user/source/my-project:/workspace"
```

or:

```yaml
- "/home/your-user/source/my-project:/workspace"
```

Replace the sample path with your actual path. After changing Compose
configuration, run `docker compose config` to validate it.

## 9. Common commands

Run these from the folder containing `docker-compose.yml`:

```bash
# Build or rebuild the image
docker compose build

# Start an interactive Kilo session
docker compose run --rm kilo

# Check version
docker compose run --rm kilo kilo --version

# View help
docker compose run --rm kilo kilo --help

# Validate the resolved Compose configuration
docker compose config

# List local Docker images
docker image ls

# List Docker volumes
docker volume ls
```

Kilo subcommands may change between versions. Check `kilo --help` for
the syntax supported by your installed version.

## 10. Updating Kilo

The installed Kilo version is baked into the image. To update to the
latest package version, rebuild the image:

```bash
docker compose build --no-cache
```

Then start Kilo normally:

```bash
docker compose run --rm kilo
```

This is when `npm install -g @kilocode/cli` runs again: during the image
rebuild, not during every CLI session. Note that rebuilding without a
version pin may install a newer package version. For reproducible
builds, pin a tested package version in the Dockerfile.

## 11. Troubleshooting

### It still installs Kilo on every launch

Check that your `docker-compose.yml` uses:

```yaml
build: .
image: local/kilo-cli:latest
```

and that the Dockerfile contains the npm installation under `RUN`.
Remove the old startup command that installs Kilo, such as:

```yaml
command: >
  sh -lc "npm install -g @kilocode/cli &&
          exec kilo"
```

Then rebuild once:

```bash
docker compose build
```

### Kilo asks me to authenticate again

- Run Compose from the same project directory and with the same
  project name.
- Verify both named volumes are present in the Compose file.
- Avoid `docker compose down -v`, which deletes the project's named
  volumes.
- If you changed the project name, Compose may create a new set of
  volumes.

### The workspace appears empty

- Put files in `workspace/`, or correct the host path in the volume
  mapping.
- Run `docker compose config` and verify the mount.
- On Windows/macOS, verify Docker Desktop can access the directory.

### File ownership problems on Linux

The sample runs as root inside the container. Files created by Kilo may
therefore have ownership that differs from your host user. Review
ownership before using recursive permission or ownership changes.

### Clean up

The `docker compose run --rm kilo` workflow removes the temporary
container when it exits. It does not remove the image or named volumes.

To remove ordinary Compose-managed containers and networks:

```bash
docker compose down
```

To delete named volumes too, use this only if you intentionally want to
erase persisted Kilo configuration/data:

```bash
docker compose down -v
```

Removing the image is separate:

```bash
docker image rm local/kilo-cli:latest
```

## 12. Official references

- Kilo CLI guide: https://kilo.ai/docs/code-with-ai/platforms/cli
- Kilo CLI repository: https://github.com/Kilo-Org/kilocode
- Kilo CLI npm package: https://www.npmjs.com/package/@kilocode/cli

---

## Quick start

1.  Create `kilo-docker/` and `kilo-docker/workspace/`.
2.  Save the `Dockerfile` and `docker-compose.yml` above.
3.  Put your project files into `workspace/`.
4.  Build once: `docker compose build`.
5.  Launch: `docker compose run --rm kilo`.
6.  Authenticate with `/connect` and select your provider/model.
7.  Next time, run `docker compose run --rm kilo` again; Kilo is already
    in the image.
