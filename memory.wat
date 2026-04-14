(module
  ;; 819200 pages * 64KB = 53,687,091,200 bytes (~50GB)
  (memory i64 819200 819200)
  (export "memory" (memory 0))

  (func $init (export "init")
    (local $i i64)
    (local $addr i64)
    (local $state i64)

    i64.const 0xABCDEF1234567890
    local.set $state
    
    (loop $loop
      local.get $state
      ;; Mask for ~51.5GB range (0xBFFFFFFFF)
      i64.const 0xBFFFFFFFF 
      i64.and
      local.set $addr

      local.get $addr
      local.get $state
      i64.store

      local.get $state
      i64.const 6364136223846793005
      i64.mul
      i64.const 1
      i64.add
      local.set $state

      local.get $i
      i64.const 1
      i64.add
      local.tee $i
      i64.const 5000000 ;; Increased iterations for the larger space
      i64.lt_u
      br_if $loop
    )
  )
)
