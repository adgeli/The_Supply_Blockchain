pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol"; // only works in Remix


contract SupplyChain is ERC721Full {
    
    using SafeMath for uint;

    constructor() ERC721Full("SupplyChain", "SPLY") public { }

    using Counters for Counters.Counter;
    Counters.Counter token_ids;
    
    uint public amt_stage_1 = 1.0;
    uint public amt_stage_2 = 2.0;
    uint public amt_stage_3 = 3.0;
    uint public amt_stage_4 = 2.0;
    uint public amt_stage_5 = 2.0;
    
    uint rate = 1000000000000000000;
    
    uint public contractBalance; 
    

    struct Shipment {
        uint stage;
        uint stage_amount;
        uint contract_balance;
        address payable owner_stage_1;
        address payable owner_stage_2;
        address payable owner_stage_3;
        address payable owner_stage_4;
        address payable owner_stage_5;
    }

    // Stores token_id => Shipment
    // Only permanent data that you would need to use within the smart contract later should be stored on-chain
    mapping(uint => Shipment) public shipments;

    event advanceStage(uint token_id, string report_uri);
    
    function deposit() public payable {
        contractBalance = address(this).balance;
    }
    
    function registerShipment(address owner, 
            address payable owner_stage_1, 
            address payable owner_stage_2, 
            address payable owner_stage_3,
            address payable owner_stage_4,
            address payable owner_stage_5,
            string memory token_uri) public payable returns(uint) {
                
        token_ids.increment();
        uint token_id = token_ids.current();

        _mint(owner, token_id);
        _setTokenURI(token_id, token_uri);

        shipments[token_id] = Shipment(1,amt_stage_1, 
                msg.value, 
                owner_stage_1, 
                owner_stage_2,
                owner_stage_3, 
                owner_stage_4,
                owner_stage_5);
        
        deposit();
        
        return token_id;
    }

    function reportShipment(address payable stage_owner, uint token_id, string memory report_uri) public payable returns(uint) {
        require(contractBalance > 0, "Shipment has been completed!");
        
        uint ntx_stage = shipments[token_id].stage.add(1);
        
        if (shipments[token_id].stage == 1) {
               require(shipments[token_id].owner_stage_1 == stage_owner, "You are not the owner of shipping stage 1");
               
               stage_owner.transfer(amt_stage_1.mul(rate));
               shipments[token_id].stage = ntx_stage;
               shipments[token_id].stage_amount = amt_stage_2;
               contractBalance = address(this).balance;
               shipments[token_id].contract_balance = contractBalance;

        } else if (shipments[token_id].stage == 2) {
               require(shipments[token_id].owner_stage_2 == stage_owner, "You are not the owner of shipping stage 2");
               
               stage_owner.transfer(amt_stage_2.mul(rate));
               shipments[token_id].stage = ntx_stage;
               shipments[token_id].stage_amount = amt_stage_3;
               contractBalance = address(this).balance;
               shipments[token_id].contract_balance = contractBalance;
               
        } else if (shipments[token_id].stage == 3) {
               require(shipments[token_id].owner_stage_3 == stage_owner, "You are not the owner of shipping stage 3");
               
               stage_owner.transfer(amt_stage_3.mul(rate));
               shipments[token_id].stage = ntx_stage;
               shipments[token_id].stage_amount = amt_stage_4;
               contractBalance = address(this).balance;
               shipments[token_id].contract_balance = contractBalance;
               
        } else if (shipments[token_id].stage == 4) {
               require(shipments[token_id].owner_stage_4 == stage_owner, "You are not the owner of shipping stage 4");
               
               stage_owner.transfer(amt_stage_4.mul(rate));
               shipments[token_id].stage = ntx_stage;
               shipments[token_id].stage_amount = amt_stage_5;
               contractBalance = address(this).balance;
               shipments[token_id].contract_balance = contractBalance;
               
        } else if (shipments[token_id].stage == 5) {
               require(shipments[token_id].owner_stage_5 == stage_owner, "You are not the owner of shipping stage 5");
               
               stage_owner.transfer(amt_stage_5.mul(rate));
               shipments[token_id].stage = 0;
               shipments[token_id].stage_amount = 0;
               contractBalance = address(this).balance;
               shipments[token_id].contract_balance = contractBalance;
        }

        
        
        emit advanceStage(token_id, report_uri);

        return shipments[token_id].stage;
    }
    
    function() external payable {}
  
}
