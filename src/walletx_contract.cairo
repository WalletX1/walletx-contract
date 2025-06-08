#[starknet::contract]
pub mod WalletXContract {
    use starknet::storage::Vec;
    use starknet::storage::{StoragePointerWriteAccess,StoragePointerReadAccess, StoragePathEntry,StorageMapWriteAccess};
    use starknet::{ContractAddress, contract_address_const};
    use walletx::interface::iwallet::IWallet;
    use starknet::storage::Map;
    use walletx::types::types::{WalletOrganisation, UserRole,WalletMember};

    #[storage]
    struct Storage {
        wallet_admins: Map<ContractAddress, bool>,
        wallet_organisations: Map<ContractAddress, WalletOrganisation>,
        wallet_id: u256,
        org_members: Map<(ContractAddress, u32), WalletMember>,
        org_member_count: Map<ContractAddress, u32>,
        member_to_org: Map<ContractAddress, ContractAddress>,

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

        fn onboard_memeber(
        ref self: ContractState,
        member_address: ContractAddress,
        admin_address: ContractAddress,
        member_name: felt252,
        fund_amount: u256,
        member_identifier: u256
    ){

        assert(member_address != contract_address_const::<'0x0'>(), 'can not use address 0');
        assert(self.is_admin(admin_address), 'Admin address does not exist ');

      
        let wallet_name =  self.wallet_organisations.entry(admin_address).read().wallet_name;
        let newMember = WalletMember{
            member_address: member_address,
            admin_address: admin_address,
            organisation_name:wallet_name,
            name: member_name,
            active: true,
            spend_limit: fund_amount,
            member_identifier: member_identifier,
            role: UserRole::Member
        };
        let current_count = self.org_member_count.entry(admin_address).read();
        self.org_members.write((admin_address, current_count), newMember);
        self.org_member_count.write(admin_address, current_count);
        self.member_to_org.write(member_address,admin_address)
    }

}
}

