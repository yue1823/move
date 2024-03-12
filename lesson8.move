address 0x42{
    module main{
        use std::debug;
        use std::signer;
        #[test]
        fun test_if(){
            let x=6;
            if(x==5){
                debug::print(&x);
            }else{
                debug::print(&10);
            }

        }

        #[test]
        fun test_while(){
            let x= 5;
            while(x>0){
                x=x-1;
                if (x==3){
                    // break;
                    continue;
                };
                debug::print(&x);
            }

        }

        #[test]
        fun test_loop(){
            let x=10;
            loop{
                x=x-1;
                if(x<=5){

                    break
                };
                debug::print(&x);
            };
        return
        }

    }
}