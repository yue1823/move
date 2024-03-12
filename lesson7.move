address 0x42{
    module main{
        use std::debug;
        use std::signer;


        struct Foo has drop{
            u:u64,
            b:bool
        }
        #[test]
        fun oo(){
            let f =Foo{u:42,b:true};
            let Foo{u,b}=f;
            debug::print(&u);
            debug::print(&b);
        }
        #[test]

        fun test2(){
            let f=Foo{u:42,b:true};
            let Foo{ u,b}=&mut f;
            *u=43;
            debug::print(&f.u);
            debug::print(&f.b);

        }

        //copy

        struct Cancopy has copy, drop{
            u:u64,
            b:u64
        }
        #[test]
        fun test3(){
            let f = Cancopy{u:1,b:8};
            let f2 = copy f;
            debug::print(&f2.u);
            debug::print(&f2.b);
            debug::print(&f.u);
            debug::print(&f.b);

        }

        struct Key has key,drop{
            s:Store

        }
        struct Store has store,drop{
            s:u64,y:u64
        }
        #[test]
        fun test4(){
            let y=Store{s:1,y:2};
            let k = Key{s:y};
            debug::print(&k.s.s);
            debug::print(&k.s.y);

        }
    }



}