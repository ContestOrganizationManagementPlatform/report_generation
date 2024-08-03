# Run

```
./generate_certificates.nu
```

# Get Doc ID's from Google Drive

Follow instructions here: https://developers.google.com/drive/api/quickstart/python.

You can find the folder id in the url `https://drive.google.com/drive/folders/$FOLDER_ID`.

```
bash -c 'source .venv/bin/activate; python3 list_drive.py "$FOLDER_ID"'
```
