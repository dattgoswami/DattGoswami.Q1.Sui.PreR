module examples::restricted_transfer {
    use sui::tx_context::{Self, TxContext};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::sui::SUI;

    const EWrongAmount: u64 = 0;

    struct GovernmentCapability has key { id: UID }

    struct TitleDeed has key {
        id: UID
    }

    struct LandRegistry has key {
        id: UID,
        balance: Balance<SUI>,
        fee: u64
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(GovernmentCapability {
            id: object::new(ctx)
        }, tx_context::sender(ctx));

        transfer::share_object(LandRegistry {
            id: object::new(ctx),
            balance: balance::zero<SUI>(),
            fee: 10000
        })
    }

    public fun issue_title_deed(
        _: &GovernmentCapability,
        for: address,
        ctx: &mut TxContext
    ) {
        transfer::transfer(TitleDeed {
            id: object::new(ctx)
        }, for)
    }

    public fun transfer_ownership(
        registry: &mut LandRegistry,
        paper: TitleDeed,
        fee: Coin<SUI>,
        to: address,
    ) {
        assert!(coin::value(&fee) == registry.fee, EWrongAmount);

        balance::join(&mut registry.balance, coin::into_balance(fee));

        transfer::transfer(paper, to)
    }
}
