module Hybrid_Asset::Hybrid_Asset {

    use std::option;
    use std::string::utf8;
    use aptos_framework::fungible_asset::{Metadata, FungibleStore, create_store};
    use aptos_framework::object::{Object, object_from_constructor_ref};
    use hybrid_address::hybrid;
    use hybrid_address::hybrid::HybridCollection;
    #[test_only]
    use std::signer::address_of;
    #[test_only]
    use aptos_std::debug;
    #[test_only]
    use aptos_std::string_utils;
    #[test_only]
    use aptos_framework::account::create_account_for_test;
    #[test_only]
    use aptos_framework::fungible_asset;
    #[test_only]
    use aptos_framework::fungible_asset::amount;
    #[test_only]
    use aptos_framework::object::create_object;
    #[test_only]
    use hybrid_address::package_manager;

    struct HA_meta has key,store{
        HA_mata:Object<HybridCollection>,
    }

    public fun create_HA(caller:&signer){
       let hybird_conf = hybrid::create(caller,utf8(b"shares"),utf8(b"HA shares"),utf8(b""),utf8(b"shares holder"),utf8(b""),utf8(b""),100000,100,1,10,@admin,false,utf8(b"HA shares"),utf8(b"HA shares"),6,utf8(b""),utf8(b""),option::none(),option::none());
        move_to(caller,HA_meta{
            HA_mata:object_from_constructor_ref<HybridCollection>(&hybird_conf),
        })
    }

    #[test(aptos_framework=@aptos_framework,caller=@0x123,user=@0x1293)]
    fun test_create_HA(aptos_framework:&signer,caller:&signer,user:&signer) acquires HA_meta {
        create_account_for_test(address_of(user));
        ready_hybrid(aptos_framework);
        create_HA(caller);
        //mint 100 HA - caller
        mint_some_HA(caller,20000000000);
        //send 1 HA to user
        send_HA_to_user(caller,address_of(user),100000000);
        print_balance_of_HA(user,true,caller);
        print_nft_of_owner(user,caller);

        send_HA_without_mint(user,address_of(caller),caller,100000000);
        print_balance_of_HA(user,true,caller);
        print_nft_of_owner(user,caller);
    }
    #[test_only]
    fun mint_some_HA(caller:&signer,amount:u64) acquires HA_meta {
        let borrow = borrow_global<HA_meta>(address_of(caller));
        hybrid::mint_to_treasury(caller,borrow.HA_mata,amount);
    }

    #[test_only]
    fun send_HA_to_user(caller:&signer,user:address,amount:u64) acquires HA_meta {
        let borrow = borrow_global<HA_meta>(address_of(caller));
        hybrid::send_from_treasury_to_user(caller,borrow.HA_mata,user,amount);
    }
    #[test_only]
    fun send_HA_without_mint(caller:&signer,receiver:address,ha_store:&signer,amount:u64) acquires HA_meta {
        let borrow = borrow_global<HA_meta>(address_of(ha_store));
        let object_conf = create_object(receiver);
        let fungible_store = create_store(& object_conf,borrow.HA_mata);
        hybrid::send_from_treasury_to_store(caller,borrow.HA_mata,fungible_store,amount);
    }
    #[test_only]
    fun ready_hybrid(aptos_framework:&signer){
        package_manager::initialize_for_test(aptos_framework);
    }
    #[test_only]
    fun print_balance_of_HA(caller:&signer,dec:bool,ha_store:&signer) acquires HA_meta {
        let borrow = borrow_global<HA_meta>(address_of(ha_store));
        let balance =hybrid::get_treasury_balance( borrow.HA_mata);
        //debug::print(&string_utils::format2(&b"{} HA balance is {}",address_of(caller),balance));
        if(dec){
            debug::print(&string_utils::format2(&b"{} HA balance is {}",address_of(caller),balance/100000000));
        }else{
            debug::print(&string_utils::format2(&b"{} HA balance is {}",address_of(caller),balance));
        }
    }
    #[test_only]
    fun print_nft_of_owner(caller:&signer,ha_store:&signer) acquires HA_meta {
        let borrow = borrow_global<HA_meta>(address_of(ha_store));
        let v =hybrid::get_nfts_by_owner(address_of(caller),borrow.HA_mata);
        debug::print(&string_utils::format2(&b"{} user own  {}",address_of(caller),v));
    }
}
