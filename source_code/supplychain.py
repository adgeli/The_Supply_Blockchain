import requests
import json
import os

from dotenv import load_dotenv
from pathlib import Path

from web3.auto import w3

load_dotenv()

headers = {
    "Content-Type": "application/json",
    "pinata_api_key": os.getenv("PINATA_API_KEY"),
    "pinata_secret_api_key": os.getenv("PINATA_SECRET_API_KEY"),
}


def initContract():
    with open(Path("SupplyChain.json")) as json_file:
        abi = json.load(json_file)

    return w3.eth.contract(address=os.getenv("SUPPLYCHAIN_ADDRESS"), abi=abi)


def convertDataToJSON(time, description, ship_uri):
    data = {
        "pinataOptions": {"cidVersion": 1},
        "pinataContent": {
            "name": "Shipping Report",
            "description": description,
            "document": ship_uri,
            "time": time,
        },
    }
    return json.dumps(data)


def pinJSONtoIPFS(json):
    r = requests.post(
        "https://api.pinata.cloud/pinning/pinJSONToIPFS", data=json, headers=headers
    )
    ipfs_hash = r.json()["IpfsHash"]
    return f"ipfs://{ipfs_hash}"


