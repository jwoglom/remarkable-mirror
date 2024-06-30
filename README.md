# remarkable-mirror

Syncs a local folder to the reMarkable tablet.

## How to run

You can run either via Docker or locally with Python + pipenv.

### Docker
With `docker run`, use an invocation such as the following. Update the version number to the latest release.

```bash
docker run -v ~/.rmapi:/home/appuser/.rmapi -v ~/.config/remarkable-mirror:/home/appuser/.config/remarkable-mirror  --rm -it ghcr.io/jwoglom/remarkable-mirror/remarkable-mirror
```

Note the volume-mounted `.rmapi` folder from your home directory which is used to store the long-running remarkable session token.

### Pipenv
```bash
git clone https://github.com/jwoglom/remarkable-mirror
cd remarkable-mirror
pipenv install
pipenv run python3.py
```


## First-time setup
The first time you run remarkable-mirror, you need to authenticate with the ReMarkable Cloud.

### Authenticating with ReMarkable

Go to https://my.remarkable.com/device/desktop/connect and log in with your existing account.
You will be provided a verification code on this page.
Run the application with the additional argument `--remarkable-login-token=XXXXX`, substituting the token from this page.

For the examples above, this would look like either:
```
docker run -v ~/.rmapi:/home/appuser/.rmapi -v ~/.config/remarkable-mirror:/home/appuser/.config/remarkable-mirror  --rm -it ghcr.io/jwoglom/remarkable-mirror/remarkable-mirror:v0.2.3 --remarkable-login-token=XXXXX
pipenv run python3.py --remarkable-login-token=XXXXX
```


## Configuration
You can tweak these additional parameters:

```
usage: main.py [-h] [--max-save-count MAX_SAVE_COUNT] [--delete-already-read]
               [--delete-unread-after-hours DELETE_UNREAD_AFTER_HOURS]
               [--remarkable-folder REMARKABLE_FOLDER] [--glob GLOB]
               [--remarkable-auth-token REMARKABLE_AUTH_TOKEN]
               [--config-folder CONFIG_FOLDER] [--tmp-folder TMP_FOLDER]
               [--remarkable-relogin-command REMARKABLE_RELOGIN_COMMAND]

Writes pdfs from folder to reMarkable cloud

options:
  -h, --help            show this help message and exit
  --max-save-count MAX_SAVE_COUNT
                        Maximum number of articles to save on device
  --delete-already-read
                        Delete articles in reMarkable cloud which are already
                        read
  --delete-unread-after-hours DELETE_UNREAD_AFTER_HOURS
                        If an article has not been opened for this many hours
                        on the device and there are new articles to add, will
                        delete. Set to -1 to disable, or 0 to always replace
                        old articles.
  --remarkable-folder REMARKABLE_FOLDER
                        Folder title to write to on Remarkable
  --glob GLOB           Local glob for files to upload
  --remarkable-auth-token REMARKABLE_AUTH_TOKEN
                        For initial authentication with reMarkable: device
                        token
  --config-folder CONFIG_FOLDER
                        Configuration folder for remarkable-mirror
  --tmp-folder TMP_FOLDER
                        Temporary storage folder for remarkable-mirror
  --remarkable-relogin-command REMARKABLE_RELOGIN_COMMAND
                        Command to run when relogin is required to remarkable
                        (e.g. send a notification)

```
