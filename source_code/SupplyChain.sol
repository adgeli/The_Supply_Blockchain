pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol"; // only works in Remix


contract SupplyChain is ERC721Full {
    
    using SafeMath for uint;

    constructor() ERC721Full("SupplyChain", "SPLY") public { }

    using Counters for Counters.Counter;
    Counters.Counter token_ids;

// Eth exchage rate - used to convert contract amount to Eth    
    uint rate = 1000000000000000000;

// Contact Balance     
    uint public contractBalance; 
    
// Contract struct with each shipping stage and payment for each stage
// Stage and stage amount used to track which stage the contract is currently in and the stage amount
    struct Shipment {
        uint stage;
        uint stage_amount;
        uint contract_balance;
        address payable owner_stage_1;
        uint amt_stage_1;
        address payable owner_stage_2;
        uint amt_stage_2;
        address payable owner_stage_3;
        uint amt_stage_3;
        address payable owner_stage_4;
        uint amt_stage_4;
        address payable owner_stage_5;
        uint amt_stage_5;
    }

// Stores token_id => Shipment
    mapping(uint => Shipment) public shipments;

// Event to write to contract stage change and payment
    event advanceStage(uint token_id, string report_uri);

// Deposit function to transfer Eth from contract to stage owner    
    function deposit() public payable {
        contractBalance = address(this).balance;
    }

// Function to intialise the contract and creates a list of contract tokens capturing the
// stage owner, amount for the stage and document URI address for the contract initialization.
    function registerShipment(address owner, 
            address payable owner_stage_1,
            uint amt_stage_1,
            address payable owner_stage_2, 
            uint amt_stage_2,
            address payable owner_stage_3,
            uint amt_stage_3,
            address payable owner_stage_4,
            uint amt_stage_4,
            address payable owner_stage_5,
            uint amt_stage_5,
            string memory token_uri) public payable returns(uint) {

// Advance the token number                
        token_ids.increment();
        uint token_id = token_ids.current();

// Mint and record the token URI
        _mint(owner, token_id);
        _setTokenURI(token_id, token_uri);

// Set the token stage owners and stage amounts with the contact total amount.
// Also set the which stage the contract is currently in and the stage amount
        shipments[token_id] = Shipment(1,amt_stage_1, 
                msg.value, 
                owner_stage_1,
                amt_stage_1,
                owner_stage_2,
                amt_stage_2,
                owner_stage_3,
                amt_stage_3,
                owner_stage_4,
                amt_stage_4,
                owner_stage_5,
                amt_stage_5);
 
 // Call deposit function to set the current value of the contract       
        deposit();
        
        return token_id;
    }

// Function reports stage completion and pays the stage owner from the contract
// Contract is then advanced to the next stage awaiting completion.
// Before payment in made to the stage owner the following must be met 
//   1) contact balance must be greater than 0 otherwise the contact is assumed to be completed.
//   2) owner logging the stage payment must be the stage owner 

    function reportShipment(address payable stage_owner, uint token_id, string memory report_uri) public payable returns(uint) {
        require(contractBalance > 0, "Shipment has been completed!");

// place holder for the stage advancement        
        uint ntx_stage = shipments[token_id].stage.add(1);

// Stage 1 pay out and advance        
        if (shipments[token_id].stage == 1) {
            
            // verify stage owner
               require(shipments[token_id].owner_stage_1 == stage_owner, "You are not the owner of shipping stage 1");
               
            // payment transfered to owner   
               stage_owner.transfer(shipments[token_id].amt_stage_1.mul(rate));
            
            // advance token shipment stage
               shipments[token_id].stage = ntx_stage;
               
            // set next stage amount
               shipments[token_id].stage_amount = shipments[token_id].amt_stage_2;
               
            // set the contract balance   
               contractBalance = address(this).balance;
               shipments[token_id].contract_balance = contractBalance;

// Stage 2 pay out and advance   
        } else if (shipments[token_id].stage == 2) {
            
            // verify stage owner
               require(shipments[token_id].owner_stage_2 == stage_owner, "You are not the owner of shipping stage 2");
            
            // payment transfered to owner     
               stage_owner.transfer(shipments[token_id].amt_stage_2.mul(rate));
               
            // advance token shipment stage   
               shipments[token_id].stage = ntx_stage;
             
            // set next stage amount   
               shipments[token_id].stage_amount = shipments[token_id].amt_stage_3;
               
            // set the contract balance    
               contractBalance = address(this).balance;
               shipments[token_id].contract_balance = contractBalance;

// Stage 3 pay out and advance                  
        } else if (shipments[token_id].stage == 3) {
            
            // verify stage owner
               require(shipments[token_id].owner_stage_3 == stage_owner, "You are not the owner of shipping stage 3");
            
            // payment transfered to owner    
               stage_owner.transfer(shipments[token_id].amt_stage_3.mul(rate));
               
            // advance token shipment stage    
               shipments[token_id].stage = ntx_stage;
               
            // set next stage amount    
               shipments[token_id].stage_amount = shipments[token_id].amt_stage_4;
               
            // set the contract balance   
               contractBalance = address(this).balance;
               shipments[token_id].contract_balance = contractBalance;

// Stage 4 pay out and advance                  
        } else if (shipments[token_id].stage == 4) {
            
            // verify stage owner
               require(shipments[token_id].owner_stage_4 == stage_owner, "You are not the owner of shipping stage 4");
            
            // payment transfered to owner    
               stage_owner.transfer(shipments[token_id].amt_stage_4.mul(rate));
               
            // advance token shipment stage    
               shipments[token_id].stage = ntx_stage;
               
            // set next stage amount   
               shipments[token_id].stage_amount = shipments[token_id].amt_stage_5;
               
            // set the contract balance   
               contractBalance = address(this).balance;
               shipments[token_id].contract_balance = contractBalance;

// Stage 5 pay out and advance                  
        } else if (shipments[token_id].stage == 5) {
            
            // verify stage owner
               require(shipments[token_id].owner_stage_5 == stage_owner, "You are not the owner of shipping stage 5");
            
            // payment transfered to owner    
               stage_owner.transfer(shipments[token_id].amt_stage_5.mul(rate));
               
            // set stage to 0 as stages are complete    
               shipments[token_id].stage = 0;
               
            // set stage amount to 0 as stage amount is 0    
               shipments[token_id].stage_amount = 0;
               
            // set the contract balance.  Balance should be 0   
               contractBalance = address(this).balance;
               shipments[token_id].contract_balance = contractBalance;
        }

        
 // Write details to block       
        emit advanceStage(token_id, report_uri);

        return shipments[token_id].stage;
    }
    
    function() external payable {}
  
}
