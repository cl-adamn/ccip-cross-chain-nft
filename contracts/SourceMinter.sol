// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {Withdraw} from "./utils/Withdraw.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract SourceMinter is Withdraw {
    enum PayFeesIn {
        Native,
        LINK
    }

    address immutable i_router;
    address immutable i_link;

    event MessageSent(bytes32 messageId);

    constructor(address router, address link) {
        i_router = router;
        i_link = link;
        LinkTokenInterface(i_link).approve(i_router, type(uint256).max);
    }

    receive() external payable {}

    function mint(
        uint64 destinationChainSelector,
        address receiver,
        PayFeesIn payFeesIn,
        address _seller,
        address _token,
        uint256 _amount
    ) external {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encodeWithSignature("mint(address,address,uint256)", msg.sender, _seller, _amount),
            tokenAmounts: new Client.EVMTokenAmount[](1),
            extraArgs: "",
            feeToken: payFeesIn == PayFeesIn.LINK ? i_link : address(0)
        });

        // Set token and amount in the EVMTokenAmount struct
        message.tokenAmounts[0] = Client.EVMTokenAmount({
            _token: _token,
            _amount: _amount
        });

        uint256 fee = IRouterClient(i_router).getFee(
            destinationChainSelector,
            message
        );

        bytes32 messageId;

        if (payFeesIn == PayFeesIn.LINK) {
            // LinkTokenInterface(i_link).approve(i_router, fee);
            messageId = IRouterClient(i_router).ccipSend(
                destinationChainSelector,
                message
            );
        } else {
            messageId = IRouterClient(i_router).ccipSend{value: fee}(
                destinationChainSelector,
                message
            );
        }

        emit MessageSent(messageId);
    }
}
