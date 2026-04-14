(module
  ;; Requires memory64 extension to exceed 4GB
  (memory i64 163840 163840)
  (export "memory" (memory 0))

  (func $init (export "init")
    (local $i i64)
    (local $addr i64)
    (local $state i64)

    ;; Correct way to set a local: push value, then call set
    i64.const 0xABCDEF1234567890
    local.set $state
    
    (loop $loop
      ;; 1. Calculate pseudo-random address (state & mask)
      local.get $state
      i64.const 0x27FFFFFFF ;; Mask for ~10.7GB
      i64.and
      local.set $addr

      ;; 2. Store state at that address: [address, value]
      local.get $addr
      local.get $state
      i64.store

      ;; 3. Update state: state = (state * mult) + 1
      local.get $state
      i64.const 6364136223846793005
      i64.mul
      i64.const 1
      i64.add
      local.set $state

      ;; 4. Increment and check counter
      local.get $i
      i64.const 1
      i64.add
      local.tee $i
      i64.const 1000000 
      i64.lt_u
      br_if $loop
    )
  )
)
