// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./VRFv2Consumer.sol";

contract DisputeHandler {
    address[] public participants;// All members in community 
    uint256 public count; // count of disputes to index dispute info mapping
    VRFv2Consumer public consumer; // contract with vrf function
    uint256 constant stakePrice = 0.01 ether; //Price needed for Staking for dispute. Dispute filer loses their stake if dispute fails

    enum Status {
        scheduled,
        voting,
        notfulfilled,
        completed,
        tied_completed,
        review
    } //Dispute status Enum
    mapping(address => bool) public isAdmin; //admin status

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Non-Admin access denied");
        _;
    }

    constructor(address _consumer) {
        consumer = VRFv2Consumer(_consumer);
        isAdmin[msg.sender] = true;
    }

    struct Dispute {
        string title;
        address booker;
        address pointed;
        string FilerDesc;
        string RecieverDesc;
        uint256 staked;
        bool stakeUnlocked;
        Status status;
        uint256 votes_for;
        uint256 votes_against;
        uint256 VRFrequestId;
        uint256 expiring;
        address winner;
    }
    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(address => uint256[]) public memberDisputes;
    mapping(uint256 => Dispute) public disputeInfo;
    mapping(uint256 => mapping(address => bool)) public disputeVoterVoteStatus;
    mapping(uint256 => mapping(address => bool)) public disputeVoterWhitelisted;

    function requestRandomAndGetId(uint256 disputeId) private {
        uint256 requestId = consumer.requestRandomWords();
        disputeInfo[disputeId].VRFrequestId = requestId;
    }

    function startDispute(
        address pointed,
        string memory title,
        string memory desc
    ) external payable {
        require(msg.value == stakePrice);
        memberDisputes[msg.sender].push(count);
        memberDisputes[pointed].push(count);
        disputeInfo[count] = Dispute(
            title,
            msg.sender,
            pointed,
            desc,
            "",
            stakePrice,
            false,
            Status.notfulfilled,
            0,
            0,
            0,
            0,
            address(0)
        );
        requestRandomAndGetId(count);

        count++;
    }

    function setParticipants(address[] memory participantsNew)
        external
        onlyAdmin
    {
        participants = participantsNew;
    }

    function verifyFullfillnessAndStartVoting(uint256 disputeId)
        external
        onlyAdmin
    {
        require(disputeInfo[disputeId].status == Status.notfulfilled);
        (bool fulfilled, uint256[] memory randomWords) = consumer
            .getRequestStatus(disputeInfo[disputeId].VRFrequestId);
        require(fulfilled);
        uint256[] memory selected = randomWords;
        for (uint256 i = 0; i < 2; i++) {
            disputeVoterWhitelisted[disputeId][
                participants[selected[i] % participants.length]
            ] = true;
        }
        disputeInfo[disputeId].status = Status.voting;
        disputeInfo[disputeId].expiring = block.timestamp + 2 days;
    }

    function declareResultForDispute(uint256 disputeId) external {
        require(block.timestamp > disputeInfo[disputeId].expiring);
        require(disputeInfo[disputeId].status == Status.voting);
        if (
            disputeInfo[disputeId].votes_for >
            disputeInfo[disputeId].votes_against
        ) {
            disputeInfo[disputeId].status = Status.completed;
            disputeInfo[disputeId].winner = disputeInfo[disputeId].booker;
            disputeInfo[disputeId].stakeUnlocked = true;
            (bool sent, ) = disputeInfo[disputeId].booker.call{
                value: stakePrice / 2
            }("");
            require(sent);
        } else if (
            disputeInfo[disputeId].votes_for <
            disputeInfo[disputeId].votes_against
        ) {
            disputeInfo[disputeId].winner = disputeInfo[disputeId].pointed;
            disputeInfo[disputeId].status = Status.completed;
            disputeInfo[disputeId].stakeUnlocked = true;
            (bool sent, ) = disputeInfo[disputeId].pointed.call{
                value: stakePrice / 2
            }("");
            require(sent);
        } else {
            disputeInfo[disputeId].status = Status.tied_completed;
        }
    }

    function voteForDispute(uint256 disputeId, bool forVote) external {
        require(disputeVoterWhitelisted[disputeId][msg.sender]);
        require(!disputeVoterVoteStatus[disputeId][msg.sender]);
        require(disputeInfo[disputeId].expiring > block.timestamp);
        disputeVoterVoteStatus[disputeId][msg.sender] = true;
        if (forVote) {
            disputeInfo[disputeId].votes_for++;
        } else {
            disputeInfo[disputeId].votes_against++;
        }
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
