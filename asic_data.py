import requests
import json
from requests.auth import HTTPDigestAuth

# Configuration for two ASICs
asic_configs = [
    {"ip": "192.168.1.49", "json_filename": "asic_status_1.json"},
    {"ip": "192.168.1.146", "json_filename": "asic_status_2.json"}
]

username = "REDACTED"
password = "REDACTED"

def fetch_asic_data(ip):
    url = f"http://{ip}/cgi-bin/get_miner_status.cgi"
    response = requests.get(url, auth=HTTPDigestAuth(username, password))
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error fetching data from {ip}: {response.status_code}")
        return None

def save_data_to_json(data, filename):
    if data:
        with open(filename, "w") as json_file:
            json.dump(data, json_file, indent=4)
        print(f"Data saved to {filename}")
    else:
        print(f"No data to save for {filename}.")

def main():
    for asic in asic_configs:
        data = fetch_asic_data(asic["ip"])
        save_data_to_json(data, asic["json_filename"])

if __name__ == "__main__":
    main()

input("Press Enter to exit...")
