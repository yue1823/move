
module MyPacke::m2{

    #[test]
    fun main2(){
        use std::debug;
        use MyPacke::main::num;
        let n=num();
        debug::print(&n);
    }

    #[test]
    fun test2(){
        use std::debug;
        use MyPacke::main::num2;
        let n= num2();
        debug::print(&n);
    }


}