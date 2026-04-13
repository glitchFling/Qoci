(module
  ;; 16 KB memory (adjust as needed)
  (memory (export "memory") 16384)

  ;; Global hash accumulator (32-bit)
  (global $hash (mut i32) (i32.const 0))

  ;; ---------------------------------------------------------
  ;; iterate_memory(byteLimit, seed)
  ;; Your original memory-scrambler, unchanged
  ;; ---------------------------------------------------------
  (func (export "iterate_memory") (param $byteLimit i32) (param $seed i32)
    (local $ptr i32)
    (local $state i32)

    (local.set $ptr (i32.const 0))
    (local.set $state (local.get $seed))

    (block $exit
      (br_if $exit (i32.eq (local.get $byteLimit) (i32.const 0)))

      (loop $loop
        ;; LCG: state = state * 1664525 + 1013904223
        (local.set $state
          (i32.add
            (i32.mul (local.get $state) (i32.const 1664525))
            (i32.const 1013904223)
          )
        )

        ;; Store low byte
        (i32.store8 (local.get $ptr) (local.get $state))

        ;; Increment pointer
        (local.set $ptr (i32.add (local.get $ptr) (i32.const 1)))

        ;; Continue until ptr == byteLimit
        (br_if $loop (i32.lt_u (local.get $ptr) (local.get $byteLimit)))
      )
    )
  )

  ;; ---------------------------------------------------------
  ;; finalize_hash()
  ;; Simple deterministic fold over memory
  ;; NOT SHA, NOT crypto, NOT secure — just a mixer
  ;; ---------------------------------------------------------
  (func (export "finalize_hash")
    (local $i i32)
    (local $b i32)

    ;; Reset hash
    (global.set $hash (i32.const 0))
    (local.set $i (i32.const 0))

    (loop $loop
      ;; Load byte
      (local.set $b (i32.load8_u (local.get $i)))

      ;; Mix: hash = (hash * 16777619) XOR b
      (global.set $hash
        (i32.xor
          (i32.mul (global.get $hash) (i32.const 16777619))
          (local.get $b)
        )
      )

      ;; i++
      (local.set $i (i32.add (local.get $i) (i32.const 1)))

      ;; Loop until end of memory
      (br_if $loop (i32.lt_u (local.get $i) (memory.size)))
    )
  )

  ;; ---------------------------------------------------------
  ;; get_hash() → i32
  ;; Returns the WASM-generated hash
  ;; ---------------------------------------------------------
  (func (export "get_hash") (result i32)
    (global.get $hash)
  )
)
