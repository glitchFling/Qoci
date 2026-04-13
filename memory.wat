(module
  ;; Declare 1 page of memory (64KiB)
  (memory 1)
  (export "memory" (memory 0))

  (func $hash512 (export "hash512") (param $len i32)
    (local $i i32)
    (local $tail i32)
    (local $shift i32)
    (local $v0 i32)
    (local $v1 i32)
    (local $v2 i32)
    (local $v3 i32)
    (local $w i32)
    (local $x i32)

    ;; init
    i32.const 0x243f6a88
    local.get $len
    i32.xor
    local.set $v0

    i32.const 0x85a308d3
    local.get $len
    i32.const 0x9e3779b1
    i32.mul
    i32.xor
    local.set $v1

    i32.const 0x13198a2e
    local.get $len
    i32.const 0x85ebca6b
    i32.mul
    i32.xor
    local.set $v2

    i32.const 0x03707344
    local.get $len
    i32.const 0xc2b2ae35
    i32.mul
    i32.xor
    local.set $v3

    i32.const 0
    local.set $i

    ;; main loop: 4-byte chunks
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

        ;; v0 += w
        local.get $v0
        local.get $w
        i32.add
        local.set $v0

        ;; v1 ^= rotl(v0,13); v1 *= 0x85ebca6b
        local.get $v0
        i32.const 13
        i32.rotl
        local.get $v1
        i32.xor
        i32.const 0x85ebca6b
        i32.mul
        local.set $v1

        ;; v2 += w
        local.get $v2
        local.get $w
        i32.add
        local.set $v2

        ;; v3 ^= rotl(v2,17); v3 *= 0xc2b2ae35
        local.get $v2
        i32.const 17
        i32.rotl
        local.get $v3
        i32.xor
        i32.const 0xc2b2ae35
        i32.mul
        local.set $v3

        ;; cross-lane
        local.get $v0
        local.get $v3
        i32.xor
        local.set $v0

        local.get $v2
        local.get $v1
        i32.xor
        local.set $v2

        local.get $i
        i32.const 4
        i32.add
        local.set $i

        br $loop
      end
    end

    ;; tail bytes
    i32.const 0
    local.set $tail
    i32.const 0
    local.set $shift

    block $tbreak
      loop $tloop
        local.get $i
        local.get $len
        i32.ge_u
        br_if $tbreak

        local.get $tail
        local.get $i
        i32.load8_u
        local.get $shift
        i32.shl
        i32.or
        local.set $tail

        local.get $shift
        i32.const 8
        i32.add
        local.set $shift

        local.get $i
        i32.const 1
        i32.add
        local.set $i

        br $tloop
      end
    end

    local.get $shift
    i32.const 0
    i32.gt_s
    if
      local.get $v0
      local.get $tail
      i32.add
      local.set $v0

      local.get $v0
      i32.const 15
      i32.rotl
      local.get $v1
      i32.xor
      i32.const 0x85ebca6b
      i32.mul
      local.set $v1
    end

    ;; avalanche v0..v3
    local.get $v0
    local.get $v0
    i32.const 16
    i32.shr_u
    i32.xor
    i32.const 0x85ebca6b
    i32.mul
    local.tee $v0
    local.get $v0
    i32.const 13
    i32.shr_u
    i32.xor
    i32.const 0xc2b2ae35
    i32.mul
    local.tee $v0
    local.get $v0
    i32.const 16
    i32.shr_u
    i32.xor
    local.set $v0

    local.get $v1
    local.get $v1
    i32.const 16
    i32.shr_u
    i32.xor
    i32.const 0x85ebca6b
    i32.mul
    local.tee $v1
    local.get $v1
    i32.const 13
    i32.shr_u
    i32.xor
    i32.const 0xc2b2ae35
    i32.mul
    local.tee $v1
    local.get $v1
    i32.const 16
    i32.shr_u
    i32.xor
    local.set $v1

    local.get $v2
    local.get $v2
    i32.const 16
    i32.shr_u
    i32.xor
    i32.const 0x85ebca6b
    i32.mul
    local.tee $v2
    local.get $v2
    i32.const 13
    i32.shr_u
    i32.xor
    i32.const 0xc2b2ae35
    i32.mul
    local.tee $v2
    local.get $v2
    i32.const 16
    i32.shr_u
    i32.xor
    local.set $v2

    local.get $v3
    local.get $v3
    i32.const 16
    i32.shr_u
    i32.xor
    i32.const 0x85ebca6b
    i32.mul
    local.tee $v3
    local.get $v3
    i32.const 13
    i32.shr_u
    i32.xor
    i32.const 0xc2b2ae35
    i32.mul
    local.tee $v3
    local.get $v3
    i32.const 16
    i32.shr_u
    i32.xor
    local.set $v3

    ;; write 16 words
    i32.const 0
    local.get $v0
    i32.store

    i32.const 4
    local.get $v1
    i32.store

    i32.const 8
    local.get $v2
    i32.store

    i32.const 12
    local.get $v3
    i32.store

    i32.const 16
    local.get $v0
    local.get $v1
    i32.xor
    i32.store

    i32.const 20
    local.get $v0
    local.get $v2
    i32.xor
    i32.store

    i32.const 24
    local.get $v0
    local.get $v3
    i32.xor
    i32.store

    i32.const 28
    local.get $v1
    local.get $v2
    i32.xor
    i32.store

    i32.const 32
    local.get $v1
    local.get $v3
    i32.xor
    i32.store

    i32.const 36
    local.get $v2
    local.get $v3
    i32.xor
    i32.store

    i32.const 40
    local.get $v0
    local.get $v1
    i32.add
    i32.store

    i32.const 44
    local.get $v0
    local.get $v2
    i32.add
    i32.store

    i32.const 48
    local.get $v0
    local.get $v3
    i32.add
    i32.store

    i32.const 52
    local.get $v1
    local.get $v2
    i32.add
    i32.store

    i32.const 56
    local.get $v1
    local.get $v3
    i32.add
    i32.store

    i32.const 60
    local.get $v2
    local.get $v3
    i32.add
    i32.store
  )
)
