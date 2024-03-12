module 0x42::myaddes{
    use std::signer;
    use aptos_framework::object;
    use aptos_framework::object::ObjectCore;

    entry fun create_adn_traction(caller:&signer,destination :address){
        let caller_address = signer::address_of(caller);
        let construstr_ref = object::create_object(caller_address);


        let object = object::object_from_constructor_ref<ObjectCore>(
            &construstr_ref
        );
        object::transfer(caller,object,destination);
    }

}