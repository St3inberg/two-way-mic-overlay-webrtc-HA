# WebRTC 2-Way Audio Test Environment

This repository provides an isolated, dockerized environment to test and debug 2-way audio (WebRTC backchannel) for smart cameras (like UniFi) typically used in Home Assistant. 

Since debugging 2-way audio directly inside Home Assistant can be difficult due to SSL requirements, integration quirks, and routing issues, this repository simulates the backend and provides a clean standalone frontend to test microphone access and WebRTC signaling.

## Architecture

This stack spins up two Docker containers:
1. **`mock-webrtc-camera` (go2rtc):** The industry standard WebRTC media server used by Home Assistant. It is configured to generate a mock stream (`mock_unifi`) with test video and audio (sine wave) using `ffmpeg`. It listens for incoming WebRTC connections and reverse-audio channels (your microphone).
2. **`mock-webrtc-frontend` (nginx):** A lightweight web server that hosts our custom `index.html`. This page contains a push-to-talk button that captures your local microphone and sends it to the `go2rtc` container over WebRTC.

## Prerequisites

* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/install/)

## Quick Start

1. **Build and start the containers:**
   ```bash
   docker-compose up --build -d
   ```

2. **Open the Test UI:**
   Navigate to [http://localhost:8080](http://localhost:8080) in your web browser. 
   *(Note: You must use `localhost` so the browser permits microphone access without HTTPS).*

3. **Test 2-Way Audio:**
   * When the page loads, allow browser permissions to use your microphone.
   * You should see a test pattern video.
   * Click and hold the **Push and Hold to Talk** button. Your microphone audio is now being streamed directly into the WebRTC session!

4. **Debugging Backend (go2rtc):**
   Navigate to the go2rtc web interface at [http://localhost:1984](http://localhost:1984).
   From here, you can view the active `mock_unifi` stream, check connected clients, and view configuration payloads.

## Translating this to Home Assistant

Once you verify that your browser can successfully capture and send audio via WebRTC in this test environment, you can port this knowledge to your Home Assistant setup.

### The Home Assistant Native Way
Instead of this custom frontend, you usually rely on AlexxIT's **WebRTC Camera** custom Lovelace card inside Home Assistant. 

1. Ensure the **go2rtc** add-on is running in Home Assistant (or use the built-in HA WebRTC).
2. Ensure port `8562` (TCP and UDP) is open on your Home Assistant server instance for WebRTC traffic.
3. Add the camera to your Lovelace dashboard:
   ```yaml
   type: custom:webrtc-camera
   entity: camera.your_unifi_camera
   ui: true # This enables the native 2-way audio microphone button in HA
   ```

### Troubleshooting Real Cameras
If it works here but not with your real camera:
* Check your Home Assistant's external URL. Browsers **will block microphone access** if you are accessing HA over standard `http://` (unless it's exactly `http://localhost`). You must use a valid SSL certificate (`https://`).
* Check the integration documentation (e.g., UniFi Protect) to ensure your specific camera model supports 2-way audio via the HA integration api. 

## Stopping the Environment

To stop and clean up the containers, run:
```bash
docker-compose down
```
