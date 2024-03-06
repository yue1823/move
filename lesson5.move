module 0x42::Demo{
    use std::debug;
    use std::vector;

    #[test]
    fun test_push_back(){
        let vec = vector[1,2,3];
        vector::push_back(&mut vec ,4);
        debug::print(&vec);

    }

    #[test]
    fun test_append(){
        let vec1= vector[1,2,3];
        let vec2 = vector[4,5,6];
        vector::append(&mut vec1,vec2);
        debug::print(&vec1);

    }

    #[test]
    fun test_rev(){
        let ver1 =vector[1,2,3];
        let ver2 = vector[4,5,6];
        vector::reverse_append(&mut ver1,ver2);
        debug::print(&ver1)

    }
    #[test]
    fun test_pop_back(){
        let vec =vector[1,2,3];
        let x=vector::pop_back(&mut vec);
        debug::print(&x);
        debug::print(&vec);

    }

    #[test]

    fun test_swap(){
        let vec1 = vector[1,2,3,4,5];
        vector::swap(&mut vec1,0,2);
        debug::print(&vec1);
    }
    #[test]
    fun test_reverse(){
        let vec1 = vector[3,5,2,1,4];
        vector::reverse(&mut vec1);
        debug::print(&vec1);


    }



}