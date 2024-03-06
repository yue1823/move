module 0x42::lesson2{
 use std::debug::print;

  struct Wallet has drop{
    balance:u64

  }
    #[test]
    fun test_Wallet(){
        let wallet  = Wallet {balance: 1000};
        let wallet2 = wallet;
        print (&wallet.balance);
        //print (&wallet.balance);

    }

}
