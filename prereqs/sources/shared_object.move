module examples::pizza {
    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    const ENotEnough: u64 = 0;
    
    struct ShopOwnerCap has key { id: UID }

    struct Pizza has key { id : UID }

    struct PizzaShop has key {
        id: UID,
        price: u64,
        balance: Balance<SUI>
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(ShopOwnerCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));

        transfer::share_object(PizzaShop {
            id: object::new(ctx),
            price: 1000,
            balance: balance::zero()
        })
    }

    public fun buy_pizza(
        shop: &mut PizzaShop, payment: &mut Coin<SUI>, ctx: &mut TxContext
    ) {
        assert!(coin::value(payment) >= shop.price, ENotEnough);

        let coin_balance = coin::balance_mut(payment);
        let paid = balance::split(coin_balance, shop.price);

        balance::join(&mut shop.balance, paid);

        transfer::transfer(Pizza {
            id: object::new(ctx)
        }, tx_context::sender(ctx))
    }

    public fun eat_pizza(d: Pizza) {
        let Pizza { id } = d;
        object::delete(id);
    }

    public fun collect_profits(
        _: &ShopOwnerCap, shop: &mut PizzaShop, ctx: &mut TxContext
    ): Coin<SUI> {
        let amount = balance::value(&shop.balance);
        coin::take(&mut shop.balance, amount, ctx)
    }
}