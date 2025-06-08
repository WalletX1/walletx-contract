use starknet::ContractAddress;

#[starknet::interface]
pub trait IWallet<TContractState> {
    fn register_wallet(
        ref self: TContractState,
        admin_address: ContractAddress,
        wallet_name: felt252,
        fund_amount: u256,
    );
    fn onboard_memeber(
        ref self: TContractState,
        member_address: ContractAddress,
        admin_address: ContractAddress,
        member_name: felt252,
        fund_amount: u256,
        member_identifier: u256
    );
}
