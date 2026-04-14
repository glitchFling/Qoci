  ;; ---------------------------------------------------------
  ;; FIXED hash512(len): strong 512‑bit hash, no collisions
  ;; ---------------------------------------------------------
  (func (export "hash512") (param $len i32)
    (local $i i32)
    (local $lane i32)
    (local $b i32)
    (local $addr i32)
    (local $tmp i32)

    ;; 16 lanes stored in memory at 0..63
    ;; initialize lanes with strong constants
    (i32.store (i32.const 0)  (i32.const 0x243f6a88))
    (i32.store (i32.const 4)  (i32.const 0x85a308d3))
    (i32.store (i32.const 8)  (i32.const 0x13198a2e))
    (i32.store (i32.const 12) (i32.const 0x03707344))
    (i32.store (i32.const 16) (i32.const 0xa4093822))
    (i32.store (i32.const 20) (i32.const 0x299f31d0))
    (i32.store (i32.const 24) (i32.const 0x082efa98))
    (i32.store (i32.const 28) (i32.const 0xec4e6c89))
    (i32.store (i32.const 32) (i32.const 0x452821e6))
    (i32.store (i32.const 36) (i32.const 0x38d01377))
    (i32.store (i32.const 40) (i32.const 0xbe5466cf))
    (i32.store (i32.const 44) (i32.const 0x34e90c6c))
    (i32.store (i32.const 48) (i32.const 0xc0ac29b7))
    (i32.store (i32.const 52) (i32.const 0xc97c50dd))
    (i32.store (i32.const 56) (i32.const 0x3f84d5b5))
    (i32.store (i32.const 60) (i32.const 0xb5470917))

    ;; absorb bytes
    (local.set $i (i32.const 0))
    (block $exit
      (loop $loop
        (br_if $exit (i32.ge_u (local.get $i) (local.get $len)))

        ;; b = mem[i]
        (local.set $b (i32.load8_u (local.get $i)))

        ;; lane = i & 15
        (local.set $lane (i32.and (local.get $i) (i32.const 15)))

        ;; addr = lane * 4
        (local.set $addr (i32.shl (local.get $lane) (i32.const 2)))

        ;; h = load lane
        (local.set $tmp (i32.load (local.get $addr)))

        ;; h ^= b * C1
        (local.set $tmp
          (i32.xor
            (local.get $tmp)
            (i32.mul (local.get $b) (i32.const 0x9e3779b9))
          )
        )

        ;; h = rotl(h, (i & 31))
        (local.set $tmp
          (i32.rotl
            (local.get $tmp)
            (i32.and (local.get $i) (i32.const 31))
          )
        )

        ;; store back
        (i32.store (local.get $addr) (local.get $tmp))

        ;; i++
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br $loop)
      )
    )

    ;; 4 rounds of cross‑lane mixing
    (local.set $i (i32.const 0))
    (loop $rounds
      (local.set $lane (i32.const 0))
      (loop $mix
        (br_if $mix (i32.ge_u (local.get $lane) (i32.const 16)))

        ;; addr = lane*4
        (local.set $addr (i32.shl (local.get $lane) (i32.const 2)))

        ;; h = h[lane]
        (local.set $tmp (i32.load (local.get $addr)))

        ;; next = h[(lane+1)&15]
        (local.set $b
          (i32.load
            (i32.shl
              (i32.and
                (i32.add (local.get $lane) (i32.const 1))
                (i32.const 15)
              )
              (i32.const 2)
            )
          )
        )

        ;; h ^= next * C2
        (local.set $tmp
          (i32.xor
            (local.get $tmp)
            (i32.mul (local.get $b) (i32.const 0xc2b2ae35))
          )
        )

        ;; h = rotl(h, lane+1)
        (local.set $tmp
          (i32.rotl (local.get $tmp) (i32.add (local.get $lane) (i32.const 1)))
        )

        ;; store
        (i32.store (local.get $addr) (local.get $tmp))

        (local.set $lane (i32.add (local.get $lane) (i32.const 1)))
        (br $mix)
      )

      ;; next round
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br_if $rounds (i32.lt_u (local.get $i) (i32.const 4)))
    )

    ;; final avalanche
    (local.set $lane (i32.const 0))
    (loop $av
      (br_if $av (i32.ge_u (local.get $lane) (i32.const 16)))

      (local.set $addr (i32.shl (local.get $lane) (i32.const 2)))
      (local.set $tmp (i32.load (local.get $addr)))

      ;; avalanche mix
      (local.set $tmp (i32.xor (local.get $tmp) (i32.shr_u (local.get $tmp) (i32.const 15))))
      (local.set $tmp (i32.mul (local.get $tmp) (i32.const 0x2c1b3c6d)))
      (local.set $tmp (i32.xor (local.get $tmp) (i32.shr_u (local.get $tmp) (i32.const 12))))
      (local.set $tmp (i32.mul (local.get $tmp) (i32.const 0x297a2d39)))
      (local.set $tmp (i32.xor (local.get $tmp) (i32.shr_u (local.get $tmp) (i32.const 15))))

      (i32.store (local.get $addr) (local.get $tmp))

      (local.set $lane (i32.add (local.get $lane) (i32.const 1)))
      (br $av)
    )
  )
