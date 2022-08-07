# Rentable

This protocol allows anyone to rent out the ownership of their NFT in a completely permissionless way. Furthermore, the owner never has to actively seek and make a contract with the renter. Rather, they can post their desired payment currency and rental cost for any perspective renter to come pay and use. 

Steps: OWNER
1. Create a rentable
- Specify currency of choice
- Specify rental cost
2. Deposit NFT into rentable contract
3. If would like it back withdraw NFT 

Steps: RENTER
1. Pay rental fee
2. Call 'executeAction' function to execute any arbitrary function (as long as NFT is returned at the end)

This set of contracts has two types of rentables:
Free- owner can reclaim a rented NFT at any time. If reclaimed while its rented out the renter is completely reimbursed for the rental.
Locked- owner can only reclaim if there is no active rental.

Any protocol that requires a custodied NFT can rent the NFT out while in custody using the free alternative in order to potentially increase earning power. The custodian would have no risk of not being able to recall the NFT since the free nature allows a call to be made at any time!

This code is completely open source and all services provided by it are and will always be free (no fee taken by creator of the protocol). Feel free to use it or modify as you please :)
