import sys
import pandas as pd
import os

from supplychain import convertDataToJSON, pinJSONtoIPFS, initContract, w3
from pprint import pprint
from datetime import date
from datetime import datetime

import warnings
warnings.filterwarnings('ignore')

supply_chain = initContract()

current_date = date.today().strftime("%b-%d-%Y")
current_time = datetime.now().strftime("%H:%M")

def createShippingReport():
    print("Record Shipping Details.")
    print("Enter following information")
    date = input("Date of the shipment (mm-dd-yyyy): ")
    description = input("Description of the shipment: ")
    owner = input("Owner ID / Address: ")
    token_id = int(input("Contract / Token ID: "))
    ship_uri = input("Enter Shipping/Document URI: ")

    json_data = convertDataToJSON(date, description, ship_uri)
    report_uri = pinJSONtoIPFS(json_data)

    return owner, token_id, report_uri


def logShipment(owner, token_id, report_uri):
    tx_hash = supply_chain.functions.reportShipment(owner, token_id, report_uri).transact(
        {"from": w3.eth.accounts[0]}
    )
    receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    return receipt


def getShippingReports(token_id):
    supply_filter = supply_chain.events.advanceStage.createFilter(
        fromBlock="0x0", argument_filters={"token_id": token_id}
    )
    return supply_filter.get_all_entries()

def displayHeading(action):
    os.system('cls')

    print('-'*41)

    if action == "report":
        print("| HAIR FLIP LOGISTICS: Shipping Report  |")
    
    else :
        print("| HAIR FLIP LOGISTICS: Log Shippment    |")

    
    print('-'*41)
    print("")


def displayReport(report, shipment):

        report_df = pd.DataFrame(report).transpose()

        print()        
        print(f"Contract Transaction Report: {current_date} - {current_time}")
        print("-"*89)

        if shipment[2] == 0 :
             print(f"| Contract Status: Shipping Completed.{' '*50}|")
             print(f"| Contract Balance: {shipment[2]}{' '*67}|")
             print("-"*89)
        else :
             print(f"| Contract Status: Shipment is in stage {shipment[0]}{' '*47}|")
             print(f"| Stage {shipment[0]} Balance: {str(shipment[1]).ljust(5)}{' '*63}|")
             print(f"| Contract Balance: {str(shipment[2]/1000000000000000000).ljust(5)}{' '*63}|")
             print("-"*89)
             
        if report_df.shape[0] != 0:    
            print(f"| Address: {report_df[0][0]}{' '*35}|")
            print(f"| Event: {report_df[0][4]}{' '*67}|")
            print(f"| Block Hash: {report_df[0][2].hex()}{' '*8}|")
            print(f"| Transaction Hash: {report_df[0][6].hex()}  |")
            print(f"| Transaction Index: {report_df[0][7]}{' '*66}|")
            print("-"*89)

def displayReceipt(receipt, report_uri):
        
        print()
        print(f"Contract Transaction Receipt: {current_date} - {current_time}")
        print("-"*90)    
        print(f"| Report IPFS Hash:: {report_uri}{' '*2}|")
        print(f"| Gas Used: {str(receipt['gasUsed']).ljust(5)}{' '*72}|")
        print(f"| Block Number: {str(receipt['blockNumber']).ljust(5)}{' '*69}|")
        print(f"| Block Hash: {receipt['blockHash'].hex()}{' '*9}|")
        print(f"| Transaction Hash: {receipt['transactionHash'].hex()}{' '*3}|")
        print("-"*90)

# sys.argv is the list of arguments passed from the command line
# sys.argv[0] is always the name of the script
# sys.argv[1] is the first argument, and so on
# For example:
#        sys.argv[0]        sys.argv[1]    sys.argv[2]
# python logShipment.py        log
# python logShipment.py        report
def main():
    if sys.argv[1] == "log":

        displayHeading(sys.argv[1])

        try:
            owner, token_id, report_uri = createShippingReport()
            receipt = logShipment(owner, token_id, report_uri)
            displayReceipt(receipt, report_uri)
        except:
            print("Error has occured:")
            print()
            print(sys.exc_info()[1:2])
            
        

    if sys.argv[1] == "report":
        
        displayHeading(sys.argv[1])

        print("Please provide Contract or Token ID")
        token_id = int(input("Contract / Token ID: "))

        try:

            shipment = supply_chain.functions.shipments(token_id).call()
            reports = getShippingReports(token_id)
            #balance = supply_chain.functions.contractBalance.call()
            displayReport(reports, shipment)
        except:
            print("Invalid Contract / Token ID:", sys.exc_info()[0])
       

main()