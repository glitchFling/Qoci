(module
  ;; Use i64 for memory64 support. 163840 pages = 10GB.
  (memory i64 163840 163840)
  (export "memory" (memory 0))

  ;; Memory-hard WAT: Randomly writes to the 10GB range
  (func $init (export "init")
    (local $i i64)
    (local $addr i64)
    (local $state i64)

    ;; Initialize state
    local.set $state (i64.const 0xABCDEF1234567890)
    
    ;; Simple loop to touch memory across the 10GB range
    (loop $loop
      ;; Calculate a pseudo-random address within 10GB (10 * 1024^3)
      ;; Masking ensures we don't go out of bounds
      local.get $state
      i64.const 0x27FFFFFFF ;; Mask for ~10.7GB range
      i64.and
      local.set $addr

      ;; Write the state to the memory address
      local.get $addr
      local.get $state
      i64.store

      ;; Update state for the next "random" jump
      local.get $state
      i64.const 6364136223846793005 ;; LCG multiplier
      i64.mul
      i64.const 1
      i64.add
      local.set $state

      ;; Loop counter
      local.get $i
      i64.const 1
      i64.add
      local.tee $i
      i64.const 1000000 ;; Perform 1 million random writes
      i64.lt_u
      br_if $loop
    )
  )
)
