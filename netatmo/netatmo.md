# Netatmo Weather API — Collecting and Displaying Your Own Data

The Netatmo Weather Station measures indoor and outdoor conditions — temperature, humidity, CO₂, noise, and barometric pressure. All data flows through the Netatmo cloud, and the official app works fine. But what if you want to keep a local archive, build your own dashboard, or just understand what the API offers?

This article walks through the practical steps: registering an app, handling OAuth2 tokens, fetching current and historical data, storing it in simple JSON files, and displaying it with minimal HTML.

> **What this is not:** a production deployment guide. Think of it as a skeleton — enough to get data flowing and understand the moving parts.

## Creating a Netatmo App

Before calling any API, you need an application registered on the Netatmo developer portal.

1. Go to [dev.netatmo.com](https://dev.netatmo.com/) and log in with your Netatmo account
2. Navigate to **My Apps** → **Create an App**
3. Fill in the app name and description (anything descriptive works)
4. Note down your **client_id** and **client_secret**
5. Set a **redirect URI** (e.g. `https://yourserver.example/callback` — or any URL you control)

The app gives you API access to your own station data. For weather data, you need the `read_station` scope — this is also the default if no scope is specified.

## OAuth2 Authorization

Netatmo uses the standard **OAuth 2.0 Authorization Code Grant**. The flow has three steps.

### Step 1 — Redirect the user

Open this URL in a browser (replace placeholders):

```
https://api.netatmo.com/oauth2/authorize
  ?client_id=YOUR_CLIENT_ID
  &redirect_uri=YOUR_REDIRECT_URI
  &scope=read_station
  &state=some-random-string
```

The user logs in and grants access to your app.

### Step 2 — Handle the callback

After approval, Netatmo redirects to your `redirect_uri` with an authorization code:

```
https://yourserver.example/callback?state=some-random-string&code=AUTHORIZATION_CODE
```

Verify the `state` matches what you sent. Extract the `code` parameter.

### Step 3 — Exchange code for tokens

```python
import requests

resp = requests.post("https://api.netatmo.com/oauth2/token", data={
    "grant_type": "authorization_code",
    "client_id": CLIENT_ID,
    "client_secret": CLIENT_SECRET,
    "code": AUTHORIZATION_CODE,
    "redirect_uri": REDIRECT_URI,
    "scope": "read_station",
})
tokens = resp.json()
# tokens = {"access_token": "...", "refresh_token": "...", "expires_in": 10800}
```

The response contains an `access_token` (valid for ~3 hours) and a `refresh_token`.

> **Shortcut for personal use:** If you only need access to your own station, you can generate tokens directly from the [My Apps](https://dev.netatmo.com/apps/) page on dev.netatmo.com — click your app and use the token generator. This skips the redirect flow entirely.

## Token Refresh

Access tokens expire after ~3 hours. To get a new one, use the refresh token:

```python
import requests, json, time

def refresh_tokens(creds):
    resp = requests.post("https://api.netatmo.com/oauth2/token", data={
        "grant_type": "refresh_token",
        "refresh_token": creds["refresh_token"],
        "client_id": creds["client_id"],
        "client_secret": creds["client_secret"],
    })
    data = resp.json()
    creds["access_token"] = data["access_token"]
    creds["refresh_token"] = data["refresh_token"]
    creds["expires_at"] = time.time() + data["expires_in"]
    return creds
```

**Critical detail:** Netatmo returns a **new refresh_token** on every refresh. The old one is immediately invalidated. You must save both tokens after each refresh — if you lose the new refresh_token, you'll need to re-authorize from scratch.

A safe pattern is to check before each API call:

```python
REFRESH_MARGIN = 600  # refresh 10 minutes early

if time.time() > creds["expires_at"] - REFRESH_MARGIN:
    creds = refresh_tokens(creds)
    save_credentials(creds)  # persist to disk immediately
```

## Fetching Current Data

The `/api/getstationsdata` endpoint returns the latest readings from all your modules.

```python
resp = requests.get("https://api.netatmo.com/api/getstationsdata", headers={
    "Authorization": f"Bearer {creds['access_token']}"
})
data = resp.json()["body"]["devices"][0]
```

The response is nested — here's what matters:

| Location | Path | Fields |
|----------|------|--------|
| Indoor (NAMain) | `data["dashboard_data"]` | Temperature, Humidity, CO2, Noise, Pressure, min/max_temp, temp_trend, pressure_trend |
| Outdoor (NAModule1) | `data["modules"][i]["dashboard_data"]` | Temperature, Humidity, min/max_temp, temp_trend |
| Rain (NAModule3) | `data["modules"][i]["dashboard_data"]` | Rain, sum_rain_1, sum_rain_24 |
| Wind (NAModule2) | `data["modules"][i]["dashboard_data"]` | WindStrength, WindAngle, GustStrength, GustAngle |

To find a specific module, filter by `type`:

```python
indoor = data["dashboard_data"]
outdoor = next(m["dashboard_data"] for m in data["modules"] if m["type"] == "NAModule1")

print(f"Indoor:  {indoor['Temperature']}°C, {indoor['CO2']} ppm")
print(f"Outdoor: {outdoor['Temperature']}°C, {outdoor['Humidity']}%")
```

The data is updated every ~10 minutes on the cloud side.

## Fetching Historical Data

The `/api/getmeasure` endpoint retrieves historical measurements. It requires more parameters:

| Parameter | Required | Description |
|-----------|----------|-------------|
| `device_id` | Yes | MAC address of the main station (NAMain) |
| `module_id` | No | MAC of specific module (omit for indoor data) |
| `scale` | Yes | Time granularity: `30min`, `1hour`, `3hours`, `1day`, `1week`, `1month` |
| `type` | Yes | Comma-separated metrics: `temperature`, `humidity`, `co2`, `pressure`, `noise` |
| `date_begin` | No | Start timestamp (Unix, local time). Default: oldest available |
| `date_end` | No | End timestamp (Unix, local time). Default: now |
| `limit` | No | Max measurements (default & max: 1024) |
| `optimize` | No | Compact format (default: true). Set `false` for easier parsing |

Example — fetch the last 24 hours of indoor temperature and CO₂:

```python
import time

resp = requests.get("https://api.netatmo.com/api/getmeasure", headers={
    "Authorization": f"Bearer {creds['access_token']}"
}, params={
    "device_id": DEVICE_MAC,
    "scale": "30min",
    "type": "temperature,co2",
    "date_begin": int(time.time()) - 86400,
    "optimize": "false",
})
body = resp.json()["body"]
for timestamp, values in body.items():
    print(f"{timestamp}: temp={values[0]}°C, co2={values[1]} ppm")
```

For outdoor data, add `module_id` pointing to the NAModule1 MAC address.

> **Note:** With `optimize=false`, the response is a dict keyed by Unix timestamp, each value being a list matching the `type` order. With `optimize=true` (default), consecutive identical values are omitted to save bandwidth — useful for mobile apps but harder to parse.

## Storing Data

Two complementary formats work well for simple setups.

### current.json — latest readings

Overwritten on every fetch. Human-readable, easy to display:

```json
{
  "time": "2026-04-03T14:30:00+02:00",
  "time_utc": 1775218200,
  "indoor": {
    "temperature": 21.3,
    "humidity": 48,
    "co2": 987,
    "noise": 38,
    "pressure": 1012.4,
    "min_temp": 19.8,
    "max_temp": 22.1,
    "temp_trend": "stable",
    "pressure_trend": "up"
  },
  "outdoor": {
    "temperature": 14.2,
    "humidity": 62,
    "min_temp": 8.5,
    "max_temp": 16.7,
    "temp_trend": "up",
    "battery": 78
  }
}
```

### history/YYYY-MM-DD.jsonl — daily archive

One JSON object per line, compact keys to save space:

```
{"t":1775218200,"ti":21.3,"hi":48,"co2":987,"n":38,"p":1012.4,"to":14.2,"ho":62,"bat":78}
{"t":1775218800,"ti":21.4,"hi":47,"co2":1002,"n":36,"p":1012.5,"to":14.5,"ho":61,"bat":78}
```

Key mapping: `t`=timestamp, `ti`=temp indoor, `to`=temp outdoor, `hi`/`ho`=humidity in/out, `co2`=CO₂, `n`=noise, `p`=pressure, `bat`=battery outdoor.

Saving is straightforward:

```python
import json
from datetime import datetime

def save_current(data, path="current.json"):
    with open(path, "w") as f:
        json.dump(data, f, indent=2)

def append_history(record, history_dir="history"):
    filename = datetime.now().strftime("%Y-%m-%d") + ".jsonl"
    with open(f"{history_dir}/{filename}", "a") as f:
        f.write(json.dumps(record) + "\n")
```

### Storage estimates

At one reading per 10 minutes:
- **~144 samples/day** × ~120 bytes = **~17 KB/day**
- **~500 KB/month**, **~6 MB/year**

Even years of data stay easily manageable as flat files.

## Simple Display

A minimal dashboard can load `current.json` and render it with vanilla JavaScript:

```html
<div id="weather"></div>
<script>
fetch('current.json')
  .then(r => r.json())
  .then(d => {
    document.getElementById('weather').innerHTML = `
      <h2>Indoor</h2>
      <p>${d.indoor.temperature}°C · ${d.indoor.humidity}% · CO₂ ${d.indoor.co2} ppm</p>
      <h2>Outdoor</h2>
      <p>${d.outdoor.temperature}°C · ${d.outdoor.humidity}%</p>
      <p style="color:#888">Updated: ${d.time}</p>
    `;
  });
</script>
```

From here, you can extend in many directions:
- **SVG line charts** from JSONL history files (today, week, month views)
- **Comfort zone bands** — color-code temperature (18–23°C green), CO₂ (<800 ppm green, >1500 red), humidity (40–60% green)
- **Auto-refresh** every 10 minutes to match the data update cycle
- **Trend arrows** using the `temp_trend` / `pressure_trend` fields

The JSONL format makes it easy to load a day's data, parse line by line, and plot with basic SVG `<polyline>` elements — no charting library needed.

## Automation with Cron

To collect data continuously, run the fetch script on a schedule:

```
*/10 * * * * /opt/netatmo/fetch.py > /opt/netatmo/last-fetch.log 2>&1
```

A clean directory layout separates credentials from data:

```
/opt/netatmo/                    # credentials (chmod 700)
  fetch.py                       # the collection script
  credentials.json               # OAuth tokens (chmod 600)
  last-fetch.log                 # latest cron output

/srv/netatmo/                    # data (readable by web server)
  current.json                   # latest readings
  history/
    2026-04-01.jsonl
    2026-04-02.jsonl
    ...
```

The key principle: **credentials never sit in a web-accessible directory**. The script reads from `/opt/netatmo/credentials.json` and writes data to `/srv/netatmo/`.

## Rate Limits and Constraints

A few things to keep in mind:

| Constraint | Detail |
|------------|--------|
| Rate limit | 50 requests per 10 seconds, 500 per hour |
| Data freshness | Cloud data updated every ~10 minutes |
| Communication | All via Netatmo cloud — no local/LAN API |
| Internet | Required for every data fetch |
| History depth | Up to ~3 years via `/getmeasure` |
| Token rotation | Both tokens change on every refresh — save immediately |

With a 10-minute cron interval, you'll make ~144 requests/day (6/hour) — well within limits.

## Summary

The building blocks are simple:
1. **Register an app** on dev.netatmo.com
2. **Authorize** via OAuth2 (or use the dev portal token generator)
3. **Refresh tokens** proactively — and always save the new refresh_token
4. **Fetch current data** via `/getstationsdata`
5. **Fetch history** via `/getmeasure` with scale and type parameters
6. **Store** as `current.json` + daily `.jsonl` files
7. **Display** with a simple HTML page reading the JSON
8. **Automate** with cron

The whole thing runs without any external dependencies beyond Python's `requests` library and a web server to serve the JSON files. No database, no framework, no build step.

---

*Netatmo API documentation: [dev.netatmo.com/apidocumentation](https://dev.netatmo.com/apidocumentation)*
