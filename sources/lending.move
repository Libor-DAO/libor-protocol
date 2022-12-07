module libor_prototol::contract {
  use sui::object::{Self, UID};
  use sui::transfer;
  use sui::tx_context::{Self, TxContext};
  use sui::balance::{Self, Balance};

  struct Contract has key {
    id: UID,
    owner: address,
    max_num_assets: u32,
  }

  struct LendingPool<phantom T> has key, store {
      id: UID,
      supplied: Pool<T>,
      borrowed: Pool<T>,
      reserved: u128,
      last_update_timestamp: u64,
      config: PoolConfig,
  }

  struct Pool<phantom T> has store {
    shares: Balance<T>,
    balance: Balance<T>,
  }

  struct PoolConfig has store, drop {
      reserve_ratio: u32,
      target_utilization: u32,
      target_utilization_rate: u128,
      max_utilization_rate: u128,
      volatility_ratio: u32,
      extra_decimals: u8,
      can_deposit: bool,
      can_withdraw: bool,
      can_use_as_collateral: bool,
      can_borrow: bool,
  }

  fun init(ctx: &mut TxContext) {
    let id = object::new(ctx);
    let owner = tx_context::sender(ctx);

    transfer::share_object(Contract {
      id,
      owner,
      max_num_assets: 10
    })
  }

  public entry fun create_pool<T> (ctx: &mut TxContext) {
    let pool = LendingPool<T> {
      id: object::new(ctx),
      supplied: Pool {
        shares: balance::zero<T>(),
        balance: balance::zero<T>(),
      },
      borrowed: Pool {
        shares: balance::zero<T>(),
        balance: balance::zero<T>(),
      },
      reserved: 0,
      last_update_timestamp: 0,
      config: PoolConfig {
        reserve_ratio: 2500,
        target_utilization: 0,
        target_utilization_rate: 0,
        max_utilization_rate: 0,
        volatility_ratio: 6000,
        extra_decimals: 0,
        can_deposit: true,
        can_withdraw: true,
        can_use_as_collateral: true,
        can_borrow: true,
      },
    };
    transfer::share_object(pool);
  }


  #[test_only]
  public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
  }
}