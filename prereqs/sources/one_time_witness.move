module examples::one_time_witness_registry {
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};
    use std::string::String;
    use sui::transfer;

    use sui::types;

    const ENotOneTimeWitness: u64 = 0;

    struct UniqueTypeRecord<phantom T> has key {
        id: UID,
        name: String
    }

    public fun add_record<T: drop>(
        witness: T,
        name: String,
        ctx: &mut TxContext
    ) {
        assert!(types::is_one_time_witness(&witness), ENotOneTimeWitness);

        transfer::share_object(UniqueTypeRecord<T> {
            id: object::new(ctx),
            name
        });
    }
}

module examples::my_otw {
    use std::string;
    use sui::tx_context::TxContext;
    use examples::one_time_witness_registry as registry;

    struct MY_OTW has drop {}

    fun init(witness: MY_OTW, ctx: &mut TxContext) {
        registry::add_record(
            witness, 
            string::utf8(b"My awesome record"),
            ctx
        )
    }
}
