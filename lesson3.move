module 0x42::Type{
    use std::debug::print;
    use std::string;
    use std::string::{utf8};
    #[test_only]
    use std::string::String;

    #[test]
    fun test_num(){
        let num_u8 : u8 = 42; //
        let num_u8_2 =43u8;
        let num_u8_3 :u8 =0x2A; //hash

        let num_u256:u256  = 100_000;
        let num_sum  = (num_u8 as u256) + num_u256 ;

        print(&num_u8);
        print(&num_u8_2);
        print(&num_u8_3);
        print(&num_u256);
        print(&num_sum);
    }

    #[test]
    fun test_bool(){
        let bool_true : bool = true;
        let bool_false : bool =false ;
        print(&bool_true);
        print(&bool_false);
        print(&(bool_true == bool_false));
    }

    #[test]
    fun test_String(){
        let str:String =utf8(b"hellow world");
        print(&str);
    }

    #[test]
    fun test_address(){

        let add:address =@0x2A;
        print(&add);
    }

}