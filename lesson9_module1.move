
    module MyPacke::main{
        use std::debug;
        friend MyPacke::m2;
        friend MyPacke::m3;
        public fun num():u64{
            66
        }

        public(friend) fun num2():u64{
            88
        }

    }
