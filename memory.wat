(func $hash512 (export "hash512") (param $len i32)
  (local $i i32)
  (local $tail i32)
  (local $shift i32)

  ;; 4 core state words
  (local $v0 i32)
  (local $v1 i32)
  (local $v2 i32)
  (local $v3 i32)

  ;; temp
  (local $w i32)
  (local $tmp i32)

  ;; initialize state with constants ^ len
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

  ;; i = 0
  i32.const 0
  local.set $i

  ;; ---- MAIN LOOP: process 4-byte words ----
  block $break
    loop $loop
      ;; if i+4 > len break
      local.get $i
      i32.const 4
      i32.add
      local.get $len
      i32.gt_u
      br_if $break

      ;; load 32-bit word w = *(u32*)(i)
      local.get $i
      i32.load
      local.set $w

      ;; v0 += w
      local.get $v0
      local.get $w
      i32.add
      local.set $v0

      ;; v1 ^= rotl(v0,13)
      local.get $v0
      i32.const 13
      i32.rotl
      local.get $v1
      i32.xor
      local.set $v1

      ;; v1 *= 0x85ebca6b
      local.get $v1
      i32.const 0x85ebca6b
      i32.mul
      local.set $v1

      ;; v2 += w
      local.get $v2
      local.get $w
      i32.add
      local.set $v2

      ;; v3 ^= rotl(v2,17)
      local.get $v2
      i32.const 17
      i32.rotl
      local.get $v3
      i32.xor
      local.set $v3

      ;; v3 *= 0xc2b2ae35
      local.get $v3
      i32.const 0xc2b2ae35
      i32.mul
      local.set $v3

      ;; cross-lane mixing
      ;; v0 ^= v3
      local.get $v0
      local.get $v3
      i32.xor
      local.set $v0

      ;; v2 ^= v1
      local.get $v2
      local.get $v1
      i32.xor
      local.set $v2

      ;; i += 4
      local.get $i
      i32.const 4
      i32.add
      local.set $i

      br $loop
    end
  end

  ;; ---- TAIL BYTES ----
  i32.const 0
  local.set $tail
  i32.const 0
  local.set $shift

  block $tailbreak
    loop $tailloop
      local.get $i
      local.get $len
      i32.ge_u
      br_if $tailbreak

      ;; tail |= mem[i] << shift
      local.get $tail
      local.get $i
      i32.load8_u
      local.get $shift
      i32.shl
      i32.or
      local.set $tail

      ;; shift += 8
      local.get $shift
      i32.const 8
      i32.add
      local.set $shift

      ;; i++
      local.get $i
      i32.const 1
      i32.add
      local.set $i

      br $tailloop
    end
  end

  ;; if tail != 0: mix it
  local.get $shift
  i32.const 0
  i32.gt_s
  if
    ;; v0 += tail
    local.get $v0
    local.get $tail
    i32.add
    local.set $v0

    ;; v1 ^= rotl(v0,15)
    local.get $v0
    i32.const 15
    i32.rotl
    local.get $v1
    i32.xor
    local.set $v1

    ;; v1 *= 0x85ebca6b
    local.get $v1
    i32.const 0x85ebca6b
    i32.mul
    local.set $v1
  end

  ;; ---- AVALANCHE FUNCTION ----
  ;; define inline macro-like avalanche(x):
  ;; x ^= x >> 16
  ;; x *= 0x85ebca6b
  ;; x ^= x >> 13
  ;; x *= 0xc2b2ae35
  ;; x ^= x >> 16

  ;; avalanche v0
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

  ;; avalanche v1
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

  ;; avalanche v2
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

  ;; avalanche v3
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

  ;; ---- EXPAND 4 WORDS → 16 WORDS (512 bits) ----

  ;; store v0..v3
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

  ;; derive 12 more words via mixing
  ;; out[4] = avalanche(v0 ^ v1)
  i32.const 16
  local.get $v0
  local.get $v1
  i32.xor
  call $av
  i32.store

  ;; out[5] = avalanche(v0 ^ v2)
  i32.const 20
  local.get $v0
  local.get $v2
  i32.xor
  call $av
  i32.store

  ;; out[6] = avalanche(v0 ^ v3)
  i32.const 24
  local.get $v0
  local.get $v3
  i32.xor
  call $av
  i32.store

  ;; out[7] = avalanche(v1 ^ v2)
  i32.const 28
  local.get $v1
  local.get $v2
  i32.xor
  call $av
  i32.store

  ;; out[8] = avalanche(v1 ^ v3)
  i32.const 32
  local.get $v1
  local.get $v3
  i32.xor
  call $av
  i32.store

  ;; out[9] = avalanche(v2 ^ v3)
  i32.const 36
  local.get $v2
  local.get $v3
  i32.xor
  call $av
  i32.store

  ;; out[10] = avalanche(v0 + v1)
  i32.const 40
  local.get $v0
  local.get $v1
  i32.add
  call $av
  i32.store

  ;; out[11] = avalanche(v0 + v2)
  i32.const 44
  local.get $v0
  local.get $v2
  i32.add
  call $av
  i32.store

  ;; out[12] = avalanche(v0 + v3)
  i32.const 48
  local.get $v0
  local.get $v3
  i32.add
  call $av
  i32.store

  ;; out[13] = avalanche(v1 + v2)
  i32.const 52
  local.get $v1
  local.get $v2
  i32.add
  call $av
  i32.store

  ;; out[14] = avalanche(v1 + v3)
  i32.const 56
  local.get $v1
  local.get $v3
  i32.add
  call $av
  i32.store

  ;; out[15] = avalanche(v2 + v3)
  i32.const 60
  local.get $v2
  local.get $v3
  i32.add
  call $av
  i32.store
)

;; helper avalanche function
(func $av (param $x i32) (result i32)
  local.get $x
  local.get $x
  i32.const 16
  i32.shr_u
  i32.xor
  i32.const 0x85ebca6b
  i32.mul
  local.tee $x
  local.get $x
  i32.const 13
  i32.shr_u
  i32.xor
  i32.const 0xc2b2ae35
  i32.mul
  local.tee $x
  local.get $x
  i32.const 16
  i32.shr_u
  i32.xor
)
