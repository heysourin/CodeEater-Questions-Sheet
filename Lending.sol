// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract LendingPlatform {
    struct Loan {
        address borrower;
        uint256 amount;
        uint256 interestRate;
        uint256 duration;
        uint256 start;
        bool repaid;
    }

    mapping(address => uint256) public balances;
    Loan[] public loans;
    uint256 public constant MINIMUM_LOAN_AMOUNT = 0.01 ether;


    function lend() public payable {
        require(
            msg.value >= MINIMUM_LOAN_AMOUNT,
            "Loan amount must be at least 0.01 ether"
        );
        balances[msg.sender] += msg.value;
    }

    function borrow(
        uint256 amount,
        uint256 interestRate,
        uint256 duration
    ) public {
        require(amount > 0, "Loan amount must be greater than 0");
        require(interestRate > 0, "Interest rate must be greater than 0");
        require(duration > 0, "Loan duration must be greater than 0");
        require(
            amount <= address(this).balance,
            "Insufficient funds in lending pool"
        );

        Loan memory newLoan = Loan({
            borrower: msg.sender,
            amount: amount,
            interestRate: interestRate,
            duration: duration,
            start: block.timestamp,
            repaid: false
        });

        loans.push(newLoan);
        balances[msg.sender] += amount;
        payable(msg.sender).transfer(amount);
    }

    function repay(uint256 loanIndex) public payable {
        Loan storage loan = loans[loanIndex];
        require(!loan.repaid, "Loan has already been repaid");
        require(
            msg.sender == loan.borrower,
            "Only the borrower can repay the loan"
        );
        require(
            msg.value == loan.amount + (loan.amount * loan.interestRate) / 100,
            "Incorrect repayment amount"
        );

        loan.repaid = true;
        balances[address(this)] -= loan.amount;
        balances[msg.sender] -=
            loan.amount +
            (loan.amount * loan.interestRate) /
            100;
        payable(address(msg.sender)).transfer(
            loan.amount + (loan.amount * loan.interestRate) / 100
        );
    }

    function getLoanCount() public view returns (uint256) {
        return loans.length;
    }

    function getLoan(uint256 loanIndex)
        public
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        Loan storage loan = loans[loanIndex];
        return (
            loan.borrower,
            loan.amount,
            loan.interestRate,
            loan.duration,
            loan.start,
            loan.repaid
        );
    }
}
