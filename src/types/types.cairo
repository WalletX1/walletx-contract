use starknet::ContractAddress;

#[derive(Drop, Debug, Copy, Serde, Clone, starknet::Store, PartialEq)]
#[allow(starknet::store_no_default_variant)]
pub enum UserRole {
    Admin,
    Member,
}

#[derive(Drop, Copy, Serde, starknet::Store)]
pub struct WalletOrganisation {
    pub admin_address: ContractAddress,
    pub wallet_name: felt252,
    pub wallet_balance: u256,
    pub active: bool,
    pub wallet_id: u256,
    pub role: UserRole,
}


#[derive(Drop, Copy, Serde, starknet::Store)]
pub struct WalletMember{
    pub member_address: ContractAddress,
    pub admin_address: ContractAddress,
    pub organisation_name: felt252,
    pub name: felt252,
    pub active: bool,
    pub spend_limit: u256,
    pub member_identifier: u256,
    pub role: UserRole
}