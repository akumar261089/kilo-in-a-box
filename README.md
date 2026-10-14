# Kilo in a Box

Run [Kilo CLI](https://kilo.ai/docs/code-with-ai/platforms/cli) inside
Docker without installing Node.js or Kilo directly on your host. Clone
this repository, build the image once, authenticate, and start coding.

Repository: `git@github.com:akumar261089/kilo-in-a-box.git`

## What you get

- Kilo CLI installed in a reusable Docker image.
- No `npm install` every time you start a session.
- A local project directory mounted into the container.
- Persistent Kilo configuration/authentication data in Docker named
  volumes.
- An interactive terminal for Kilo CLI.
- A repeatable setup for Windows, macOS, and Linux.

> **Safety:** Kilo is an agentic coding tool. It can edit files and run
> commands. Use Git or backups, review its changes, and only mount
> directories you want it to access.

## 1. Prerequisites

Install:

- **Git**
- **Docker Desktop** on Windows/macOS, or Docker Engine and the Docker
  Compose plugin on Linux.
- Access to this repository. For SSH cloning, your GitHub SSH key must
  be configured with GitHub. If you do not use SSH, clone using the
  repository's HTTPS URL instead.

Verify the tools:

```bash
git --version
docker --version
docker compose version
```

## 2. Clone the repository

Clone the repository; you do not need to create the Dockerfile or
Compose file manually.

```bash
git clone git@github.com:akumar261089/kilo-in-a-box.git
cd kilo-in-a-box
```

If SSH authentication is not configured, use HTTPS:

```bash
git clone https://github.com/akumar261089/kilo-in-a-box.git
cd kilo-in-a-box
```

The repository should include the Dockerfile and Compose configuration.
The expected layout is:

```text
kilo-in-a-box/
├── Dockerfile
├── docker-compose.yml
├── README.md
└── workspace/
```

The `workspace/` directory is the project folder mounted into Kilo. If
it is not present in your clone, create it:

```bash
mkdir workspace
```

PowerShell alternative:

```powershell
New-Item -ItemType Directory -Force workspace
```

## 3. Put your project files in `workspace/`

Copy or clone the code you want Kilo to work on into the repository's
`workspace/` directory.

Example:

```text
kilo-in-a-box/
├── Dockerfile
├── docker-compose.yml
├── README.md
└── workspace/
    ├── app.py
    ├── requirements.txt
    └── ...
```

Files inside `workspace/` are mounted at `/workspace` inside the
container. Edits made by Kilo are reflected on your host computer.

### Use an existing project directory instead

You can change the volume mapping in `docker-compose.yml` from:

```yaml
- ./workspace:/workspace
```

to the absolute path of your existing project. For example:

```yaml
# Windows (replace with your real path)
- "C:/Users/your-user/source/my-project:/workspace"

# Linux/macOS (replace with your real path)
- "/home/your-user/source/my-project:/workspace"
```

Use forward slashes in Windows Compose paths and ensure Docker Desktop
can access the selected folder.

## 4. Build the Docker image (first time only)

From the `kilo-in-a-box/` directory, run:

```bash
docker compose build
```

This builds the custom image and installs Kilo CLI in it. The first
build downloads the Node.js base image if needed and requires an
internet connection.

Confirm the image exists:

```bash
docker image ls
```

## 5. Start Kilo CLI

Run:

```bash
docker compose run --rm kilo
```

The Kilo interactive terminal should open in `/workspace`.

On the first launch, authenticate by following the next section. On
later launches, run the same command again:

```bash
docker compose run --rm kilo
```

**You do not need to rebuild the image for every session.** Docker
creates a temporary container from the existing image; `--rm` removes
that container when you exit. The image, workspace files, and named
volumes remain.

## 6. Authenticate and select a model

Provider options and authentication steps may vary with the installed
Kilo CLI version. Refer to the [official Kilo CLI
guide](https://kilo.ai/docs/code-with-ai/platforms/cli).

### Interactive authentication

1.  Start Kilo:

    ```bash
    docker compose run --rm kilo
    ```

2.  At the Kilo prompt, enter:

    ```text
    /connect
    ```

3.  Select a provider from the choices displayed.

4.  Follow the prompts to sign in or provide the provider's API key.

5.  If browser-based authentication is offered, complete it in your host
    browser and follow any URL or device-code instructions printed in
    the terminal.

6.  Select a model if prompted. Use `/models` if supported by your
    current version to change models.

7.  Test the setup with a small request, such as asking Kilo to
    summarize the project structure.

If `/connect` or a command differs in your installed version, check
`kilo --help` and the official CLI documentation.

### Where authentication is stored

The Compose configuration should persist Kilo's configuration with
Docker named volumes, typically mapping:

- `/root/.config/kilo` to `kilo-config`
- `/root/.local/share/kilo` to `kilo-data`

The container in the provided setup runs as root, so its home directory
is `/root`. Named volumes persist across normal
`docker compose run --rm` sessions.

Run this to list Docker volumes:

```bash
docker volume ls
```

Run Compose from the same repository directory and with the same project
name so it reuses the same volumes.

**Keep credentials private.** Do not commit API keys or authentication
files to Git. Anyone with sufficient access to your Docker host may be
able to access Docker volumes.

## 7. Use Kilo safely

Start with a review-only task, for example:

```text
Inspect this project, summarize its structure, and identify likely bugs.
Do not modify files until you explain the proposed changes.
```

Kilo can read and edit the mounted `workspace/` directory and run
commands inside the container. Avoid mounting private host directories
unless they are necessary.

## 8. Common commands

Run these from the repository root (`kilo-in-a-box/`):

```bash
# Build or rebuild the image
docker compose build

# Start an interactive Kilo session
docker compose run --rm kilo

# Check Kilo version
docker compose run --rm kilo kilo --version

# Show CLI help
docker compose run --rm kilo kilo --help

# Validate Compose configuration
docker compose config

# List local Docker images
docker image ls

# List Docker volumes
docker volume ls
```

## 9. Update Kilo or update this repository

### Update the repository files

```bash
git pull
```

Review any changes to `Dockerfile` or `docker-compose.yml`. If the
Dockerfile or installed CLI version needs to be refreshed, rebuild the
image.

### Update the installed Kilo CLI

The CLI is installed during image build, not at container startup. To
rebuild and fetch the current package version:

```bash
docker compose build --no-cache
```

Then start Kilo normally:

```bash
docker compose run --rm kilo
```

For reproducible builds, the Dockerfile can pin a tested Kilo package
version rather than always installing the latest release.

## 10. Troubleshooting

### `git clone` reports permission denied

If using the SSH URL, make sure your SSH key is added to your GitHub
account. Alternatively, clone with HTTPS:

```bash
git clone https://github.com/akumar261089/kilo-in-a-box.git
```

If the repository is private, HTTPS also requires an authorized sign-in
method.

### Kilo appears to install every time

Check that the Compose service uses a prebuilt image (`build: .`) and
that the Dockerfile installs Kilo with a
`RUN npm install -g @kilocode/cli` instruction. Remove any Compose
startup command that runs `npm install` before launching Kilo, then
rebuild once:

```bash
docker compose build
```

### Kilo asks you to authenticate every time

- Run Compose from the same repository directory and with the same
  project name.
- Confirm the Kilo configuration volume is present in
  `docker-compose.yml`.
- Avoid `docker compose down -v`; it deletes project named volumes.
- Changing the Compose project name can create a different set of
  volumes.

### The workspace appears empty

- Confirm your files are in `workspace/`.
- Run `docker compose config` and verify the volume mapping.
- If you mounted an absolute path, verify that it exists and Docker
  can access it.

### Linux file permissions

The sample container runs as root. Files created by Kilo may have
ownership that differs from your host user. Check ownership before
making recursive permission or ownership changes.

## 11. Cleanup

The `docker compose run --rm kilo` command removes its temporary
container on exit. It does not remove the image or named volumes.

To stop/remove ordinary Compose-managed containers and networks:

```bash
docker compose down
```

To also delete named volumes, including persisted Kilo configuration and
data, run this **only if you intend to erase that data**:

```bash
docker compose down -v
```

Remove the local image separately if desired:

```bash
docker image rm local/kilo-cli:latest
```

## Official references

- Kilo CLI guide: https://kilo.ai/docs/code-with-ai/platforms/cli
- Kilo CLI repository: https://github.com/Kilo-Org/kilocode
- Kilo CLI npm package: https://www.npmjs.com/package/@kilocode/cli

---

## Quick start

```bash
git clone git@github.com:akumar261089/kilo-in-a-box.git
cd kilo-in-a-box
mkdir workspace
docker compose build
docker compose run --rm kilo
```

Inside Kilo, use `/connect` to authenticate and select a provider/model.
For future sessions, return to the repository directory and run:

```bash
docker compose run --rm kilo
```
