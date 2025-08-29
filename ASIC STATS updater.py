import requests
import json
import time

# Telegram Bot Configuration
TOKEN = "REDACTED"
CHAT_ID = "REDACTED"

# Paths to your JSON status files for both ASICs
json_filenames = [
    "C:/Users/YoungWolf/Documents/asic_status_1.json",
    "C:/Users/YoungWolf/Documents/asic_status_2.json"
]

def read_asic_data(json_filename):
    with open(json_filename, 'r') as f:
        return json.load(f)

def format_asic_data(data, asic_number):
    best_share = data['summary']['bestshare']
    ghsav = data['summary']['ghsav']
    ghs_mhs = float(ghsav) * 1000

    temps = [dev['temp'] for dev in data['devs']]
    temp_message = " | ".join([f"Temp {i+1}: {temp}°C" for i, temp in enumerate(temps)])

    accepted_shares = data['summary']['accepted']
    rejected_shares = data['summary']['rejected']
    stale_shares = data['summary']['stale']
    hw_errors = data['summary']['hw']

    fan_speeds = [dev['fan1'] for dev in data['devs']]
    fan_message = "💨 " + " | ".join([f"Fan {i+1}: {fan} RPM" for i, fan in enumerate(fan_speeds)])

    message = f"""
ASIC #{asic_number} Status Update:

🧮 Best Share: `{best_share}`
📊 Hashrate: `{ghs_mhs} MH/s`

🌡️ Temperatures: {temp_message}
{fan_message}

🛠️ Hardware Errors: `{hw_errors}`
✅ Accepted Shares: `{accepted_shares}`
❌ Rejected Shares: `{rejected_shares}`
🛑 Stale Shares: `{stale_shares}`
"""
    return message

def send_to_telegram(message):
    url = f"https://api.telegram.org/bot{TOKEN}/sendMessage"
    message = f"```\n{message}\n```"

    data = {
        "chat_id": CHAT_ID,
        "text": message,
        "parse_mode": "MarkdownV2"
    }

    response = requests.post(url, data=data)
    if response.status_code == 200:
        print("Message sent successfully!")
    else:
        print(f"Failed to send message. Status code: {response.status_code}")
        print(response.text)

def main():
    combined_message = ""
    for i, json_file in enumerate(json_filenames, start=1):
        try:
            data = read_asic_data(json_file)
            combined_message += format_asic_data(data, i) + "\n\n"
        except Exception as e:
            print(f"Error reading {json_file}: {e}")

    if combined_message:
        combined_message += f"⏰ Time: `{time.strftime('%Y-%m-%d %H:%M:%S')}`"
        send_to_telegram(combined_message)

if __name__ == "__main__":
    main()

