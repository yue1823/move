module 0x42::HELLOWWORLD{

    use std::debug::print;
    use std::string::utf8;

    #[test]
    fun test_hello_eorld(){
        print(&utf8(b"Hello World")); 
    }
}