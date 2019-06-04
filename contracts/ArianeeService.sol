pragma solidity 0.5.6;

import "@0xcert/ethereum-utils-contracts/src/contracts/permission/ownable.sol";

contract ERC721Interface {
    function canOperate(uint256 _tokenId, address _operator) public returns(bool);
}

contract ArianeeWhitelist {
    function addWhitelistedAddress(uint256 _tokenId, address _address) public;
}

contract ArianeeService is
Ownable{
    
    address arianeeStoreAddress;
    ArianeeWhitelist arianeeWhitelist;
    ERC721Interface smartAsset;
    
    mapping(uint256 => Service[]) public serviceList;
    
    mapping(uint256 => uint256[]) public rewards;
    
    struct Service{
        string URI;
        bytes32 imprint;
        address provider;
        bool accepted;
    }
    
    modifier onlyStore(){
        require(msg.sender == arianeeStoreAddress);
        _;
    }
    
    modifier canOperate(uint256 _tokenId,address _operator){
        require(smartAsset.canOperate(_tokenId, _operator));
        _;
    }
    
    constructor(address _arianeeStoreAddress, address _smartAssetAddress, address _arianeeWhitelistAddress) public{
        arianeeStoreAddress = _arianeeStoreAddress;
        arianeeWhitelist = ArianeeWhitelist(address(_arianeeWhitelistAddress));
        smartAsset = ERC721Interface(address(_smartAssetAddress));
    }
    /**
     * @dev set a new store address
     * @notice can only be called by the contract owner.
     * @param _storeAddress new address of the store.
     */
    function setStoreAddress(address _storeAddress) public onlyOwner(){
        arianeeStoreAddress = _storeAddress;
    }
    
    /**
     * @dev create a new service linked to a nft
     * @notice can only be called through the store.
     * @param _tokenId id of the NFT
     * @param _uri uri of the JSON of the service.
     * @param _imprint of the JSON.
     * @return the id of the service.
     */
    function createService(uint256 _tokenId, string memory _uri, bytes32 _imprint, uint256 _reward) public onlyStore() returns(uint256){
        Service memory _service = Service({
            URI : _uri,
            imprint : _imprint,
            provider : tx.origin,
            accepted: false
        });
        uint256 _serviceId = serviceList[_tokenId].push(_service);
        rewards[_tokenId].push(_reward);
        return _serviceId;
    }
    
    /**
     * @dev Accept a service so it can be concidered as valid.
     * @notice can only be called through the store by an operator of the NFT.
     * @param _tokenId id of the NFT.
     * @param _serviceId id of the service.
     */
    function acceptService(uint256 _tokenId, uint256 _serviceId) public onlyStore() canOperate(_tokenId, tx.origin) returns(uint256){
        serviceList[_tokenId][_serviceId].accepted = true;
        arianeeWhitelist.addWhitelistedAddress(_tokenId, serviceList[_tokenId][_serviceId].provider);
        uint256 reward = rewards[_tokenId][_serviceId];
        delete rewards[_tokenId][_serviceId];
        return reward;
    }
    
}