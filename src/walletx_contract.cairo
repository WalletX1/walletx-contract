#[starknet::contract]
pub mod WalletXContract {
    use starknet::storage::StorageMapWriteAccess;
    use starknet::storage::StoragePointerWriteAccess;
    use starknet::storage::StoragePointerReadAccess;
    use starknet::storage::StoragePathEntry;
    use starknet::{ContractAddress, contract_address_const};
    use walletx::interface::IWallet::IWallet;
    use starknet::storage::Map;
    use walletx::types::types::{WalletOrganisation, UserRole};

    #[storage]
    struct Storage {
        wallet_admins: Map<ContractAddress, bool>,
        wallet_organisations: Map<ContractAddress, WalletOrganisation>,
        wallet_id: u256,
    }

    #[generate_trait]
    pub impl InternalImpl of InternalTrait {
        fn is_admin(self: @ContractState, address: ContractAddress) -> bool {
            self.wallet_admins.entry(address).read()
        }
    }

    #[abi(embed_v0)]
    impl WalletImpl of IWallet<ContractState> {
        fn register_wallet(
            ref self: ContractState,
            admin_address: ContractAddress,
            wallet_name: felt252,
            fund_amount: u256,
        ) {
            assert(admin_address != contract_address_const::<'0x0'>(), 'can not use address 0');
            assert(!self.is_admin(admin_address), 'wallet address exists already');

            let current_id = self.wallet_id.read();
            let new_id = current_id + u256 { low: 1, high: 0 };
            self.wallet_id.write(new_id);

            let organisation = WalletOrganisation {
                admin_address: admin_address,
                wallet_name: wallet_name,
                wallet_balance: fund_amount,
                active: true,
                role: UserRole::Admin,
                wallet_id: new_id,
            };

            self.wallet_admins.entry(admin_address).write(true);
            self.wallet_organisations.write(admin_address, organisation);
        }
    }
}

