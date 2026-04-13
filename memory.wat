(module
  ;; 16 MiB memory (same as your original)
  (memory (export "memory") 16384)

  ;; ---------------------------------------------------------
  ;; Your original iterator, unchanged
  ;; ---------------------------------------------------------
  (func (export "iterate_memory") (param $byteLimit i32) (param $seed i32)
    (local $ptr i32)
    (local $state i32)
    
    (local.set $ptr (i32.const 0))
    (local.set $state (local.get $seed))

    (block $exit
      (br_if $exit (i32.eq (local.get $byteLimit) (i32.const 0)))
      
      (loop $loop
        ;; LCG Math: state = (state * 1664525 + 1013904223)
        (local.set $state 
          (i32.add 
            (i32.mul (local.get $state) (i32.const 1664525)) 
            (i32.const 1013904223)
          )
        )

        ;; Store the lower 8 bits of the random state in RAM
        (i32.store8 (local.get $ptr) (local.get $state))

        ;; Increment
        (local.set $ptr (i32.add (local.get $ptr) (i32.const 1)))

        (br_if $loop (i32.lt_u (local.get $ptr) (local.get $byteLimit)))
      )
    )
  )

  ;; ---------------------------------------------------------
  ;; 512-bit hash over first `len` bytes of memory
  ;; Writes 16 x i32 words (64 bytes) starting at offset 0
  ;; ---------------------------------------------------------
  (func (export "hash512") (param $len i32)
    (local $i i32)
    (local $b0 i32) (local $b1 i32) (local $b2 i32) (local $b3 i32)
    (local $b4 i32) (local $b5 i32) (local $b6 i32) (local $b7 i32)
    (local $b8 i32) (local $b9 i32) (local $b10 i32) (local $b11 i32)
    (local $b12 i32) (local $b13 i32) (local $b14 i32) (local $b15 i32)

    (local $h0 i32) (local $h1 i32) (local $h2 i32) (local $h3 i32)
    (local $h4 i32) (local $h5 i32) (local $h6 i32) (local $h7 i32)
    (local $h8 i32) (local $h9 i32) (local $h10 i32) (local $h11 i32)
    (local $h12 i32) (local $h13 i32) (local $h14 i32) (local $h15 i32)

    ;; init lanes with different constants
    (local.set $h0  (i32.const 0x9e3779b9))
    (local.set $h1  (i32.const 0x85ebca6b))
    (local.set $h2  (i32.const 0xc2b2ae35))
    (local.set $h3  (i32.const 0x27d4eb2f))
    (local.set $h4  (i32.const 0x165667b1))
    (local.set $h5  (i32.const 0xd3a2646c))
    (local.set $h6  (i32.const 0x7f4a7c15))
    (local.set $h7  (i32.const 0xf39cc060))
    (local.set $h8  (i32.const 0x106aa070))
    (local.set $h9  (i32.const 0x1e376c08))
    (local.set $h10 (i32.const 0x2748774c))
    (local.set $h11 (i32.const 0x34b0bcb5))
    (local.set $h12 (i32.const 0x391c0cb3))
    (local.set $h13 (i32.const 0x4ed8aa4a))
    (local.set $h14 (i32.const 0x5b9cca4f))
    (local.set $h15 (i32.const 0x682e6ff3))

    (local.set $i (i32.const 0))

    (block $exit
      (loop $loop
        ;; stop if i + 15 >= len
        (br_if $exit
          (i32.ge_u
            (i32.add (local.get $i) (i32.const 15))
            (local.get $len)
          )
        )

        ;; load 16 bytes
        (local.set $b0  (i32.load8_u (local.get $i)))
        (local.set $b1  (i32.load8_u (i32.add (local.get $i) (i32.const 1))))
        (local.set $b2  (i32.load8_u (i32.add (local.get $i) (i32.const 2))))
        (local.set $b3  (i32.load8_u (i32.add (local.get $i) (i32.const 3))))
        (local.set $b4  (i32.load8_u (i32.add (local.get $i) (i32.const 4))))
        (local.set $b5  (i32.load8_u (i32.add (local.get $i) (i32.const 5))))
        (local.set $b6  (i32.load8_u (i32.add (local.get $i) (i32.const 6))))
        (local.set $b7  (i32.load8_u (i32.add (local.get $i) (i32.const 7))))
        (local.set $b8  (i32.load8_u (i32.add (local.get $i) (i32.const 8))))
        (local.set $b9  (i32.load8_u (i32.add (local.get $i) (i32.const 9))))
        (local.set $b10 (i32.load8_u (i32.add (local.get $i) (i32.const 10))))
        (local.set $b11 (i32.load8_u (i32.add (local.get $i) (i32.const 11))))
        (local.set $b12 (i32.load8_u (i32.add (local.get $i) (i32.const 12))))
        (local.set $b13 (i32.load8_u (i32.add (local.get $i) (i32.const 13))))
        (local.set $b14 (i32.load8_u (i32.add (local.get $i) (i32.const 14))))
        (local.set $b15 (i32.load8_u (i32.add (local.get $i) (i32.const 15))))

        ;; simple mixing per lane: h = (h ^ b) * C
        (local.set $h0  (i32.mul (i32.xor (local.get $h0)  (local.get $b0))  (i32.const 0x85ebca6b)))
        (local.set $h1  (i32.mul (i32.xor (local.get $h1)  (local.get $b1))  (i32.const 0xc2b2ae35)))
        (local.set $h2  (i32.mul (i32.xor (local.get $h2)  (local.get $b2))  (i32.const 0x27d4eb2f)))
        (local.set $h3  (i32.mul (i32.xor (local.get $h3)  (local.get $b3))  (i32.const 0x165667b1)))
        (local.set $h4  (i32.mul (i32.xor (local.get $h4)  (local.get $b4))  (i32.const 0xd3a2646c)))
        (local.set $h5  (i32.mul (i32.xor (local.get $h5)  (local.get $b5))  (i32.const 0x7f4a7c15)))
        (local.set $h6  (i32.mul (i32.xor (local.get $h6)  (local.get $b6))  (i32.const 0xf39cc060)))
        (local.set $h7  (i32.mul (i32.xor (local.get $h7)  (local.get $b7))  (i32.const 0x106aa070)))
        (local.set $h8  (i32.mul (i32.xor (local.get $h8)  (local.get $b8))  (i32.const 0x1e376c08)))
        (local.set $h9  (i32.mul (i32.xor (local.get $h9)  (local.get $b9))  (i32.const 0x2748774c)))
        (local.set $h10 (i32.mul (i32.xor (local.get $h10) (local.get $b10)) (i32.const 0x34b0bcb5)))
        (local.set $h11 (i32.mul (i32.xor (local.get $h11) (local.get $b11)) (i32.const 0x391c0cb3)))
        (local.set $h12 (i32.mul (i32.xor (local.get $h12) (local.get $b12)) (i32.const 0x4ed8aa4a)))
        (local.set $h13 (i32.mul (i32.xor (local.get $h13) (local.get $b13)) (i32.const 0x5b9cca4f)))
        (local.set $h14 (i32.mul (i32.xor (local.get $h14) (local.get $b14)) (i32.const 0x682e6ff3)))
        (local.set $h15 (i32.mul (i32.xor (local.get $h15) (local.get $b15)) (i32.const 0x748f82ee)))

        ;; advance by 16 bytes
        (local.set $i (i32.add (local.get $i) (i32.const 16)))
        (br $loop)
      )
    )

    ;; store 16 x i32 words at offset 0 (64 bytes)
    (i32.store (i32.const 0)  (local.get $h0))
    (i32.store (i32.const 4)  (local.get $h1))
    (i32.store (i32.const 8)  (local.get $h2))
    (i32.store (i32.const 12) (local.get $h3))
    (i32.store (i32.const 16) (local.get $h4))
    (i32.store (i32.const 20) (local.get $h5))
    (i32.store (i32.const 24) (local.get $h6))
    (i32.store (i32.const 28) (local.get $h7))
    (i32.store (i32.const 32) (local.get $h8))
    (i32.store (i32.const 36) (local.get $h9))
    (i32.store (i32.const 40) (local.get $h10))
    (i32.store (i32.const 44) (local.get $h11))
    (i32.store (i32.const 48) (local.get $h12))
    (i32.store (i32.const 52) (local.get $h13))
    (i32.store (i32.const 56) (local.get $h14))
    (i32.store (i32.const 60) (local.get $h15))
  )
)
