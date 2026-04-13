(module
  ;; Declare 16 pages of memory (approx 1MB) to ensure byteLimit fits
  (memory (export "memory") 16)

  (func $hash512 (export "hash512") (param $len i32)
    (local $i i32)
    (local $tail i32)
    (local $shift i32)
    (local $v0 i32)
    (local $v1 i32)
    (local $v2 i32)
    (local $v3 i32)
    (local $w i32)

    ;; 1. Improved Initialization with distinct primes
    i32.const 0x243f6a88
    local.get $len
    i32.xor
    local.set $v0

    i32.const 0x85a308d3
    local.get $len
    i32.const 0x9e3779b1
    i32.mul
    i32.add
    local.set $v1

    i32.const 0x13198a2e
    local.get $v0
    i32.const 19
    i32.rotl
    i32.xor
    local.set $v2

    i32.const 0x03707344
    local.get $v1
    i32.const 17
    i32.rotl
    i32.xor
    local.set $v3

    i32.const 0
    local.set $i

    ;; 2. Main loop: 4-byte chunks
    block $break
      loop $loop
        local.get $i
        i32.const 4
        i32.add
        local.get $len
        i32.gt_u
        br_if $break

        local.get $i
        i32.load
        local.set $w

        ;; Mix w into v0 and v2
        local.get $v0
        local.get $w
        i32.add
        i32.const 0x85ebca6b
        i32.mul
        local.set $v0

        local.get $v2
        local.get $w
        i32.xor
        i32.const 0xc2b2ae35
        i32.mul
        local.set $v2

        ;; Rotate and XOR (Diffusion)
        local.get $v1
        local.get $v0
        i32.const 13
        i32.rotl
        i32.xor
        local.set $v1

        local.get $v3
        local.get $v2
        i32.const 17
        i32.rotl
        i32.xor
        local.set $v3

        ;; Cross-link all lanes to prevent independent collisions
        local.get $v0
        local.get $v1
        i32.add
        local.set $v0

        local.get $v2
        local.get $v3
        i32.add
        local.set $v2

        local.get $i
        i32.const 4
        i32.add
        local.set $i
        br $loop
      end
    end

    ;; 3. Final Avalanche: Using distinct constants per lane to maximize divergence
    ;; v0 Avalanche
    local.get $v0
    local.get $v0
    i32.const 16
    i32.shr_u
    i32.xor
    i32.const 0x85ebca6b
    i32.mul
    local.set $v0

    ;; v1 Avalanche
    local.get $v1
    local.get $v1
    i32.const 15
    i32.shr_u
    i32.xor
    i32.const 0xc2b2ae35
    i32.mul
    local.set $v1

    ;; v2 Avalanche
    local.get $v2
    local.get $v2
    i32.const 13
    i32.shr_u
    i32.xor
    i32.const 0x7fb5d329
    i32.mul
    local.set $v2

    ;; v3 Avalanche
    local.get $v3
    local.get $v3
    i32.const 11
    i32.shr_u
    i32.xor
    i32.const 0x3c6ef372
    i32.mul
    local.set $v3

    ;; 4. Write 16 distinct words to memory (0-60)
    i32.const 0  local.get $v0 i32.store
    i32.const 4  local.get $v1 i32.store
    i32.const 8  local.get $v2 i32.store
    i32.const 12 local.get $v3 i32.store

    ;; Derivative outputs to fill the rest of the 64 bytes
    i32.const 16 local.get $v0 local.get $v1 i32.xor i32.store
    i32.const 20 local.get $v1 local.get $v2 i32.xor i32.store
    i32.const 24 local.get $v2 local.get $v3 i32.xor i32.store
    i32.const 28 local.get $v3 local.get $v0 i32.xor i32.store
    
    i32.const 32 local.get $v0 i32.const 0x9e3779b1 i32.mul i32.store
    i32.const 36 local.get $v1 i32.const 0x85ebca6b i32.mul i32.store
    i32.const 40 local.get $v2 i32.const 0xc2b2ae35 i32.mul i32.store
    i32.const 44 local.get $v3 i32.const 0x27d4eb2f i32.mul i32.store

    i32.const 48 local.get $v0 local.get $v2 i32.add i32.store
    i32.const 52 local.get $v1 local.get $v3 i32.add i32.store
    i32.const 56 local.get $v0 local.get $v3 i32.sub i32.store
    i32.const 60 local.get $v1 local.get $v2 i32.sub i32.store
  )
)
