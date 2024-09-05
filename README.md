# file_uploader

2. **_generateSample** Takes in a voice id + transcript and uploads the generated audioclip to R2.
3. **_createVoice(file)** Sends a user's recorded audio file to Cartesia. 
4. Cartesia returns an custom voice embedding.

# Usage

If you are running against the production Cloudflare worker, make sure to change the URL's to
https://meandering.loganvaleski.workers.dev/create-voice
https://meandering.loganvaleski.workers.dev/generate-sample

Otherwise, the URL's should be http://localhost:8787/create-voice and
http://localhost:8787/generate-sample.
