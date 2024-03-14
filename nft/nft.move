module mynft::mynft{

        use std::string::{String,utf8};
        use std::string;
        use std::option;
        use std::error;

        use std::vector;
        use std::signer;
        use aptos_framework::object::{Self,Object, LinearTransferRef};
        use aptos_token_objects::collection;
        use aptos_token_objects::token;
        use aptos_token_objects::token::Token;
        use aptos_token_objects::property_map;
        use aptos_framework::event;
        use aptos_framework::account;
        use aptos_std::string_utils::{to_string};
        use aptos_std::type_info::struct_name;
        use aptos_framework::fungible_asset::{BurnRef, TransferRef};
        use aptos_token_objects::collection::MutatorRef;
        use aptos_framework::account::SignerCapability;

    #[test_only]
        use aptos_token_objects::aptos_token::create_collection;

        //the token not exist
        const Token_does_not_exist:u64 =1;
        //the provide signer is cretor
        const Not_creator:u64=2;
        const Mycollection:vector<u8> =b"mycollection";
        const Project:address=@0x1;
         struct CollectionRefsStore has key {

             mutator_ref:collection::MutatorRef,

         }
    struct Content has key,drop{
        content:string::String
    }
    #[event]
    struct Mintevent has drop ,store{
        owner:address,
        token_id:address,
        content:string::String
    }
    #[event]
    struct SetContentEvent has drop, store {
        owner: address,
        token_id: address,
        old_content: string::String,
        new_content: string::String
    }
    #[event]
    struct BurnEvent has drop,store {
        owner:address,
        token_id:address,
        content:string::String
    }
    struct Resoucecap has key{
        cap:SignerCapability
    }
    struct Tokenstore has key{
        mutator_ref: token::MutatorRef,
        burn_ref: token::BurnRef,
        extend_ref: object::ExtendRef,
        transfer_ref: option::Option<object::TransferRef>
    }


    fun init_module(caller:&signer){

        let (resource_signer, resource_cap) = account::create_resource_account(
            caller,
            Mycollection
        );

        move_to(&resource_signer,Resoucecap{cap:resource_cap});
        // if (exists<Resoucecap>(signer::address_of(&resource_signer))){
        //     debug::print(&utf8(b"1.yes ResourceCap"));
        // }else{
        //     debug::print(&utf8(b"1.no ResourceCap"));
        // };
        // debug::print(&utf8(Mycollection));

        let max_supply = 1000;
        let des:String = utf8(b"test nft");
        let name:String =utf8(b"nft");
        let web_Addr :String = utf8(b"https://pot-124.4everland.store/IMG_0714.JPG");
        let collection=collection::create_fixed_collection(
            &resource_signer,
            utf8(b"test nft"),
            1000,
            utf8(b"nft"),
            option::none(),
            utf8(b"https://pot-124.4everland.store/IMG_0714.JPG")
        );
        let collection_signer = object::generate_signer(&collection );
        let mutator_ref = aptos_token_objects::collection::generate_mutator_ref(&collection);
        move_to(&collection_signer,CollectionRefsStore{mutator_ref});


        // if (exists<CollectionRefsStore>(signer::address_of(&collection_signer))){
        //     debug::print(&utf8(b"2.yes CollectionRefsStore"));
        // }else{
        //     debug::print(&utf8(b"2.no CollectionRefsStore"));
        // };
    }

    // #[test(caller=@0x1)]
    // fun test_mint(caller:&signer)acquires Resoucecap {
    //     init_module(caller);
    //     let yee : String=utf8(b"1");
    //     mint(caller,yee);
    // }
    //&@mynft
    entry public fun mint(caller :&signer,content:string::String)acquires Resoucecap {
        //let resourf = aptos_framework::account::create_resource_address(&@mynft,Mycollection);

        // debug::print(&utf8(Mycollection));
        // if (exists<Resoucecap>(resourf)){
        //     debug::print(&utf8(b"3.yes Resoucecap"));
        // }else{
        //     debug::print(&utf8(b"3.no Resoucecap"));
        // };

        let resource_cap = &borrow_global<Resoucecap>(aptos_framework::account::create_resource_address(&@mynft,Mycollection)).cap;
        let resource_signer = &account::create_signer_with_capability(resource_cap);
        let token_cref = token::create(resource_signer,utf8(b"nft"),utf8(Mycollection),utf8(b"test nft"),option::none(),utf8(b"https://pot-124.4everland.store/IMG_0714.JPG"));
        let token_signer = object::generate_signer(&token_cref);
        let token_mutator_ref = token::generate_mutator_ref(&token_cref);
        let token_burn_ref =token::generate_burn_ref(&token_cref);
        move_to(
            &token_signer,
            Tokenstore {
                mutator_ref: token_mutator_ref,
                burn_ref: token_burn_ref,
                extend_ref: object::generate_extend_ref(&token_cref),
                transfer_ref: option::none()
            }
        );
        move_to(
            &token_signer,
            Content {
                content
            }
        );


        event::emit(
            Mintevent{
                owner:signer::address_of(caller),
                token_id:object::address_from_constructor_ref(&token_cref),
                content}
        );
        object::transfer(
            resource_signer,
            object::object_from_constructor_ref<Token>(&token_cref),
            signer::address_of(caller),
        );

    }

    entry fun burn(caller:&signer,object:Object<Content>)acquires Tokenstore,Content {
        assert!(object::is_owner(object,signer::address_of(caller)),1);
        let Tokenstore{
            mutator_ref: _,
            burn_ref,
            extend_ref: _,
            transfer_ref: _
        } = move_from<Tokenstore>(object::object_address(&object));

        let Content {
            content
        } = move_from<Content>(object::object_address(&object));
        event::emit(
            BurnEvent {
                owner: object::owner(object),
                token_id: object::object_address(&object),
                content
            }
        );
        token::burn(burn_ref);
    }

    entry fun set_content(
        caller: &signer,
        object: Object<Content>,
        content: string::String
    )acquires Content{
        let old_content =borrow_content(signer::address_of(caller),object).content;
        event::emit(
            SetContentEvent {
                owner: object::owner(object),
                token_id: object::object_address(&object),
                old_content,
                new_content: content
            }
        );
        borrow_mut_content(signer::address_of(caller), object).content = content;
    }
    #[view]
    public fun get_content(object: Object<Content>): string::String acquires Content {
        borrow_global<Content>(object::object_address(&object)).content
    }
    inline fun borrow_content(owner: address, object: Object<Content>): &Content {
        assert!(object::is_owner(object, owner), 1);
        borrow_global<Content>(object::object_address(&object))
    }
    inline fun borrow_mut_content(owner: address, object: Object<Content>): &mut Content {
        assert!(object::is_owner(object, owner), 1);
        borrow_global_mut<Content>(object::object_address(&object))
    }
    #[test_only]
    public fun init_for_test(sender: &signer) {
        init_module(sender)
    }





