address 0x42{
        module main{
                use std::debug;
                use aptos_framework::object;
                use aptos_framework::object::{Object,ConstructorRef,ObjectCore};
                use std::signer;

                const NAME:vector <u8> =b"myObject";

                        //create_deletable_object
                public fun createdeletableobject(caller :&signer ):ConstructorRef{
                        let caller_address = signer::address_of(caller);
                        let obj = object::create_object(caller_address);
                        obj

                }
                //non-deletable-object
                public fun create_undeletable_object(caller :&signer):ConstructorRef{

                        let obj = object::create_named_object(caller,NAME);

                        obj
                }
                //create_sticky_object
                public fun create_sticky_object(caller:&signer):ConstructorRef{
                        let caller_addr = signer::address_of(caller);
                        let obj = object::create_sticky_object(caller_addr);
                        obj
                }
                #[test(caller=@0x88)]
                fun testcreatedeletableobject(caller:&signer){
                        let obj = createdeletableobject(caller);

                        debug::print(&obj);
                }
                #[test(caller=@0x88)]
                fun test_undeletetable_object(caller:&signer){
                        let obj = create_undeletable_object(caller);
                        debug::print(&obj);

                }
                #[test(caller=@0x88)]
                fun test_sticky_object(caller:&signer){
                        let obj = create_sticky_object(caller);
                        debug::print(&obj);
                }

        }


}