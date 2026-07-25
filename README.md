# remarkable-mirror

Syncs a local folder to the reMarkable tablet.

## How to run

You can run either via Docker or locally with Python + pipenv.

### Docker
With `docker run`, use an invocation such as the following. Update the version number to the latest release.

```bash
docker run -v ~/.config/rmapi-js:/home/appuser/.config/rmapi-js -v ~/.config/remarkable-mirror:/home/appuser/.config/remarkable-mirror  --rm -it ghcr.io/jwoglom/remarkable-mirror/remarkable-mirror
```

Note the volume-mounted `.config/rmapi-js` directory from your home directory, which stores the long-lived reMarkable device token and the hash cache.

### Pipenv
```bash
git clone https://github.com/jwoglom/remarkable-mirror
cd remarkable-mirror
pipenv install
pipenv run python main.py
```

Running locally also needs the [rmapi-js](https://github.com/jwoglom/rmapi-js) CLI (v12+) on `PATH`, which requires Node 22 or newer:

```bash
npm install -g https://github.com/jwoglom/rmapi-js/releases/download/v12.0.0/jwoglom-rmapi-js-12.0.0.tgz
rmapi-js --version
```

This project invokes `rmapi-js` rather than `rmapi`, because the Go clients (`ddvk/rmapi`, `juruen/rmapi`) also install a binary named `rmapi` and the two are not flag-compatible. Set `RMAPI_BIN` to override the binary name.

## First-time setup
The first time you run remarkable-mirror, you need to authenticate with the ReMarkable Cloud.

### Authenticating with ReMarkable

Go to https://my.remarkable.com/device/browser/connect and log in with your existing account.
You will be provided an 8-letter verification code on this page.
Run the application with the additional argument `--remarkable-auth-token=XXXXXXXX`, substituting the code from this page.

For the examples above, this would look like either:
```
docker run -v ~/.config/rmapi-js:/home/appuser/.config/rmapi-js -v ~/.config/remarkable-mirror:/home/appuser/.config/remarkable-mirror  --rm -it ghcr.io/jwoglom/remarkable-mirror/remarkable-mirror:v0.2.3 --remarkable-auth-token=XXXXXXXX
pipenv run python main.py --remarkable-auth-token=XXXXXXXX
```

That code is exchanged once for a device token, which does not expire and is stored mode 0600 in the config directory (`$RMAPI_CONFIG_DIR`, else `~/.config/rmapi-js`). A session token is cached alongside it and refreshed automatically, so `--remarkable-auth-token` is only needed once.

### Running headless

Instead of registering interactively, supply an existing device token:

```bash
export RMAPI_DEVICE_TOKEN="<token>"   # from `rmapi-js auth token --print-token`
```

The device token is a long-lived credential — keep it in a secret store or an environment variable, never committed and never baked into an image.

The config directory still has to be **writable** even when `RMAPI_DEVICE_TOKEN` is set, because the session token and hash cache are written there. Losing it is not fatal when the token comes from the environment.


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
                        For initial authentication with reMarkable: the
                        8-letter code from
                        https://my.remarkable.com/device/browser/connect
  --config-folder CONFIG_FOLDER
                        Configuration folder for remarkable-mirror
  --tmp-folder TMP_FOLDER
                        Temporary storage folder for remarkable-mirror
  --remarkable-relogin-command REMARKABLE_RELOGIN_COMMAND
                        Command to run when relogin is required to remarkable
                        (e.g. send a notification)

```

## Notes

* `--delete-already-read` decides what to delete from the document's last-read page (`lastOpenedPage`). That field has not yet been verified end-to-end against rmapi-js on a real device, so confirm it tracks your reading position before enabling the flag. It is off by default.
* Unlike the Go client, which reported page 0 both for "never opened" and for "opened to the first page", rmapi-js omits the field entirely when a document has never been opened. `--delete-already-read` will not delete a document with no recorded page.
* Deletion moves documents to the reMarkable **trash**, which has to be emptied from a device or from my.remarkable.com.
* Documents are deleted by id, resolved from a listing of `--remarkable-folder`, so nothing outside that folder is reachable.
