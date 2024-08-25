# file_uploader

1. Uploads a the user's recorded file to "user-uploaded-clips" bucket on Cloudflare.
2. POSTs the user's recorded file to Cartesia. Cartesia returns an custom voice embedding.

# Usage

There are no special environmental variables or setup. 
`flutter pub get` and then run on emulator. 

# Common issues

`Unhandled Exception: PlatformException(record, Recorder has not yet been created or has already been disposed., null, null)`
`PlatformException: Recorder has not yet been created or has already been disposed.`
Last one is a bit length problem which I am currently unable to reproduce.
