///可以換的badges系統，把badges 換成v2 的nft，也可以把nft 換回badges

module dapp::Task1 {

    use std::option;
    use std::signer;
    use std::signer::address_of;
    use std::string;
    use std::string::utf8;
    use std::vector;
    use aptos_std::capability;
    use aptos_std::debug;
    use aptos_framework::account;
    use aptos_framework::account::{SignerCapability, create_resource_address, create_signer_with_capability};
    use aptos_framework::object;
    use aptos_framework::object::Object;
    use aptos_token_objects::aptos_token;
    use aptos_token_objects::collection::{create_unlimited_collection};
    use aptos_token_objects::royalty;
    use aptos_token_objects::token;
    use aptos_token_objects::token::{Token, burn};

    struct Resouce_cap has key {
        cap:SignerCapability
    }

    struct Object_cap_main has key,store {
        extend_ref:object::ExtendRef,
        trans_ref:object::TransferRef
    }

    struct Object_cap_user has key, store {
        extend_ref:object::ExtendRef,
        trans_ref:object::TransferRef,
        del_ref:object::DeleteRef
    }
    struct NFT_cap_user has key, store,drop {
        mut_ref:token::MutatorRef,
        burn_ref:token::BurnRef
    }
    struct NFT_badges has key ,store,drop{
        badges:Badges,
        cap:NFT_cap_user,

    }
    struct Store_nft_data has key , store,drop{
        obj:Object<Token>,
        name_of_nft:string::String,
        address_of_token:address,
    }

    struct Badges has key ,store,drop{
        Name:string::String,
        url:string::String,
    }
    struct User_account has key ,store,drop{
         store:vector<Badges>
    }
    struct User_store_object_address has key , store ,drop{
        store_obj_address : vector<Store_nft_data>
    }
    const Seed:vector<u8> = b"asf";

    const Diffusion_url :vector<u8> = b"https://github.com/yue1823/diffusion/blob/main/client/src/art/diffusion_black.png?raw=true";
    const Diffusion_collection:vector<u8> =b"Badges of diffusion";
    const Diffusion_describe : vector<u8> =b"Diffusion collection";
    const Badges_url:vector<u8> =b"https://github.com/yue1823/diffusion/blob/main/client/src/art/diffusion4.png?raw=true";

    const No_this_badges :u64 = 1;

    #[view]
    public fun return_badges (target:address):vector<Badges> acquires User_account {
        let new_vector = vector::empty<Badges>();
        let length = vector::length(&borrow_global<User_account>(target).store);
        let i = 0 ;
        while(i < length ){
            let specfic = vector::borrow(&borrow_global<User_account>(target).store,i);
            let new_badges = Badges{
                Name:specfic.Name,
                url:specfic.url
            };
            vector::push_back(&mut new_vector,new_badges);
            i=i+1;
        };
        return new_vector
    }
    #[view]
    public fun return_nft_data (target:address):vector<Store_nft_data> acquires User_store_object_address {
        let new_vector = vector::empty<Store_nft_data>();
        let length = vector::length(&borrow_global<User_store_object_address>(target).store_obj_address);
        let i = 0 ;
        while(i < length ){
            let specfic = vector::borrow(&borrow_global<User_store_object_address>(target).store_obj_address,i);
            let new_badges = Store_nft_data{
                obj:specfic.obj,
                name_of_nft:specfic.name_of_nft,
                address_of_token:specfic.address_of_token
            };
            vector::push_back(&mut new_vector,new_badges);
            i=i+1;
        };
        return new_vector
    }
    public entry fun nft_burn_to_badges(caller:&signer,badges_name:string::String) acquires User_store_object_address, NFT_badges, User_account {
        let borrow = borrow_global_mut<User_store_object_address>(signer::address_of(caller));
        let (have_or_not,index) = vector::find(&borrow.store_obj_address,|store|seach_user_store_token_object(store,badges_name));
        if(have_or_not){
            let old_nft = vector::borrow(&borrow.store_obj_address,index);
            // let token_data =&borrow_global<NFT_badges>(old_nft.address_of_token).cap;
            let NFT_badges{badges,cap} = move_from<NFT_badges>(old_nft.address_of_token);
            let NFT_cap_user{mut_ref,burn_ref } = cap;
            debug::print(&utf8(b"is owner of caller"));
            debug::print(& object::is_owner(old_nft.obj,address_of(caller)));
            burn(burn_ref);
            vector::push_back(&mut borrow_global_mut<User_account >(signer::address_of(caller)).store,badges);
            vector::swap_remove(&mut borrow.store_obj_address,index);
        }
    }


    public entry fun badges_mint_nft(caller:&signer,badges_name:string::String) acquires User_store_object_address, User_account, Resouce_cap {
        let resorce_cap =borrow_global<Resouce_cap>(create_resource_address(&@dapp,Seed));
        let resource_signer = create_signer_with_capability(&resorce_cap.cap);
        let royalthy = royalty::create(10,100,@admin);
        let option_ro = option::some(royalthy);
        let new_name=utf8(b" - ");
        string::append(&mut new_name,badges_name);
        let token_cons = &token::create_numbered_token(&resource_signer,utf8(Diffusion_collection),utf8( Diffusion_describe ),utf8(b"Diffusion Badges #"),new_name,option_ro,utf8(Badges_url));
        let token_mutref = token::generate_mutator_ref(token_cons);
        let token_burnref = token::generate_burn_ref(token_cons);
        let token_signer = object::generate_signer(token_cons);
        // let token_transfer_ref = object::generate_transfer_ref(token_cons);
        // let token_linear_trsns = object::generate_linear_transfer_ref(&token_transfer_ref);

        if(!exists<User_store_object_address>(signer::address_of(caller))){
            move_to(caller,User_store_object_address{
                store_obj_address :vector::empty<Store_nft_data>()
            })
        };
        let User_store_object_address{store_obj_address}=move_from<User_store_object_address>(address_of(caller));

        let new_store = Store_nft_data{
            obj:object::object_from_constructor_ref<Token>(token_cons),
            name_of_nft:badges_name,
            address_of_token:object::address_from_constructor_ref(token_cons)
        };
        // debug::print(&utf8(b"token address"));
        // debug::print(&new_store );
        vector::push_back(&mut store_obj_address,new_store );
        move_to(caller,User_store_object_address{store_obj_address});

        let borrow_badges = borrow_global_mut<User_account>(signer::address_of(caller));
        // let new_v = borrow_badges.store.filter(|badge| select_correct_badges(badge, badges_name));
        // let length =vector::length(&new_v);
        let (new_s,number)=vector::find( &borrow_badges.store,|badge| select_correct_badges(badge, badges_name));
        if( new_s){
            let new_nft_cap = NFT_cap_user{
                mut_ref:token_mutref,
                burn_ref:token_burnref,
            };
            let new_badges = vector::swap_remove(&mut borrow_badges.store,number);
            let new_nft = NFT_badges{
                badges:new_badges,
                cap:new_nft_cap
            };
            move_to(&token_signer,new_nft);
            //object::transfer_with_ref(token_linear_trsns,signer::address_of(caller));
            object::transfer(&resource_signer,object::object_from_constructor_ref<Token>(token_cons),signer::address_of(caller))
        };
        // debug::print(&utf8(b"borrow badges"));
        // debug::print(&borrow_badges.store);
        // debug::print(&utf8(b"badges true or not"));
        // debug::print(&new_s);
        // debug::print(&number);

    }

    public entry fun add_badges(caller:&signer,badges_name:string::String) acquires User_account {
        if(!exists<User_account>(signer::address_of(caller))){
            move_to(caller,User_account{
                store:vector::empty<Badges>()
            })
        };
        let User_account{store}=move_from<User_account>(signer::address_of(caller));
        let new_badges = Badges{
            Name:badges_name,
            url:utf8(b"")
        };
        vector::push_back(&mut store,new_badges );
        move_to(caller,User_account{store });
    }

    fun init_module (caller:&signer){
        let (resource_signer, resource_cap) = account::create_resource_account(
                    caller,
                    Seed
                );
        let royalthy = royalty::create(10,100,@admin);
        let option_ro = option::some(royalthy);
        let construct = &create_unlimited_collection(&resource_signer,utf8(Diffusion_describe),utf8(Diffusion_collection),option_ro,utf8(Diffusion_url));
        let object_ext = object::generate_extend_ref(construct);
        let object_tran = object::generate_transfer_ref(construct);
        move_to(&resource_signer,Object_cap_main{
            extend_ref:object_ext,
            trans_ref:object_tran
        });
        move_to(&resource_signer,Resouce_cap{cap:resource_cap});
    }

    //logic fun

    fun select_correct_badges(badges:&Badges,target_search:string::String):bool{
        badges.Name == target_search
    }

    fun seach_user_store_token_object(store:&Store_nft_data,target_search:string::String):bool{
        store.name_of_nft == target_search
    }
    //test fun

    #[test(caller=@dapp)]
    fun test_bagdes_to_nft(caller:&signer) acquires User_account, User_store_object_address, Resouce_cap, NFT_badges {
        init_module(caller);
        add_badges(caller,utf8(b"love you"));
        add_badges(caller,utf8(b"toy"));
        // debug::print(&utf8(b"Badges vector"));
        // debug::print(&borrow_global<User_account>(signer::address_of(caller)).store);

        badges_mint_nft(caller,utf8(b"toy"));
        nft_burn_to_badges(caller,utf8(b"toy"));
    }
}
