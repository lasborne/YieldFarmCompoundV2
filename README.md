# Yield Farm Contract using Compound Finance V2

This is a basic Yield Farm (not deployed). It borrows any specified amount of a valid ERC-20 token from Aave V3 Pool utilizing the PoolAddressesProvider, and has the framework for the funds to be used for yield farming on Compound Finance v2 (Note that Compund v2 can only be used on Ethereum mainnet and Goerli testnet). This flash loan and yield farming must be done in the same transaction, else, the entire transaction rolls back. This is known as the atomicity property i.e. either all transaction must work within same transaction or the entire transaction bundle fails.

Refer to week17 (Basic Flash Loan) project on 'https://github.com/lasborne' to get scripts framework. Also go to Aave and Compound Docs.

Try running some of the following tasks:

npx hardhat help 
npx hardhat node 
npx hardhat compile
Special credits to Gregory @DappUniversity, Julian @EatTheBlocks, AAVE V3 and Compound v2 docs.
