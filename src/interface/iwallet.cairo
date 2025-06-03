use starknet::ContractAddress;

#[starknet::interface]
pub trait IWallet<TContractState> {
    fn register_wallet(
        ref self: TContractState,
        admin_address: ContractAddress,
        wallet_name: felt252,
        fund_amount: u256,
    );
}
