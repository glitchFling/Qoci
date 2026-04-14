;; 16,384-bit hash
;; hash16384(len, seed, laneBase, outBase)
(func (export "hash16384")
  (param $len i32)        ;; number of bytes to hash
  (param $seed i32)       ;; seed for domain separation
  (param $laneBase i32)   ;; base address of 512 lanes (each i32)
  (param $outBase i32)    ;; base address of 2048-byte output
  (local $i i32)
  (local $round i32)
  (local $lane i32)
  (local $idx i32)
  (local $idxNext i32)
  (local $v i32)
  (local $h i32)
  (local $b i32)

  ;; ---------------------------------------------------------
  ;; 1) Initialize 512 lanes: h[i] = seed ^ (i * 0x9e3779b9)
  ;; ---------------------------------------------------------
  (local.set $i (i32.const 0))
  (block $init_exit
    (loop $init_loop
      (br_if $init_exit
        (i32.ge_u (local.get $i) (i32.const 512))
      )

      ;; h = seed ^ (i * 0x9e3779b9)
      (local.set $h
        (i32.xor
          (local.get $seed)
          (i32.mul (local.get $i) (i32.const 0x9e3779b9))
        )
      )

      ;; store lane i
      (i32.store
        (i32.add
          (local.get $laneBase)
          (i32.shl (local.get $i) (i32.const 2)) ;; i * 4
        )
        (local.get $h)
      )

      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $init_loop)
    )
  )

  ;; ---------------------------------------------------------
  ;; 2) Absorb input bytes into lanes
  ;;    lane = i & 511
  ;;    h[lane] = rotl( (h[lane] ^ (b * C1)), (i & 31) )
  ;; ---------------------------------------------------------
  (local.set $i (i32.const 0))
  (block $absorb_exit
    (loop $absorb_loop
      (br_if $absorb_exit
        (i32.ge_u (local.get $i) (local.get $len))
      )

      ;; load byte b = mem[i]
      (local.set $b
        (i32.load8_u (local.get $i))
      )

      ;; lane = i & 511
      (local.set $lane
        (i32.and (local.get $i) (i32.const 511))
      )

      ;; idx = laneBase + lane * 4
      (local.set $idx
        (i32.add
          (local.get $laneBase)
          (i32.shl (local.get $lane) (i32.const 2))
        )
      )

      ;; h = load lane
      (local.set $h
        (i32.load (local.get $idx))
      )

      ;; h ^= b * C1
      (local.set $h
        (i32.xor
          (local.get $h)
          (i32.mul (local.get $b) (i32.const 0x85ebca6b))
        )
      )

      ;; h = rotl(h, (i & 31))
      (local.set $h
        (i32.rotl
          (local.get $h)
          (i32.and (local.get $i) (i32.const 31))
        )
      )

      ;; store back
      (i32.store (local.get $idx) (local.get $h))

      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $absorb_loop)
    )
  )

  ;; ---------------------------------------------------------
  ;; 3) Cross-lane mixing (4 rounds)
  ;;    h[i] = rotl( h[i] ^ (h[(i+1)&511] * C2), (i & 31) )
  ;; ---------------------------------------------------------
  (local.set $round (i32.const 0))
  (block $mix_rounds_exit
    (loop $mix_rounds_loop
      (br_if $mix_rounds_exit
        (i32.ge_u (local.get $round) (i32.const 4))
      )

      (local.set $i (i32.const 0))
      (block $mix_exit
        (loop $mix_loop
          (br_if $mix_exit
            (i32.ge_u (local.get $i) (i32.const 512))
          )

          ;; idx = laneBase + i * 4
          (local.set $idx
            (i32.add
              (local.get $laneBase)
              (i32.shl (local.get $i) (i32.const 2))
            )
          )

          ;; idxNext = laneBase + ((i+1)&511) * 4
          (local.set $idxNext
            (i32.add
              (local.get $laneBase)
              (i32.shl
                (i32.and
                  (i32.add (local.get $i) (i32.const 1))
                  (i32.const 511)
                )
                (i32.const 2)
              )
            )
          )

          ;; h = load h[i]
          (local.set $h
            (i32.load (local.get $idx))
          )

          ;; v = h[(i+1)&511]
          (local.set $v
            (i32.load (local.get $idxNext))
          )

          ;; h ^= v * C2
          (local.set $h
            (i32.xor
              (local.get $h)
              (i32.mul (local.get $v) (i32.const 0xc2b2ae35))
            )
          )

          ;; h = rotl(h, (i & 31))
          (local.set $h
            (i32.rotl
              (local.get $h)
              (i32.and (local.get $i) (i32.const 31))
            )
          )

          ;; store back
          (i32.store (local.get $idx) (local.get $h))

          (local.set $i (i32.add (local.get $i) (i32.const 1)))
          (br $mix_loop)
        )
      )

      (local.set $round (i32.add (local.get $round) (i32.const 1)))
      (br $mix_rounds_loop)
    )
  )

  ;; ---------------------------------------------------------
  ;; 4) Avalanche (2 rounds)
  ;;    h[i] ^= h[(i+17)&511] * C3
  ;;    h[i] = rotl(h[i], 13)
  ;; ---------------------------------------------------------
  (local.set $round (i32.const 0))
  (block $av_rounds_exit
    (loop $av_rounds_loop
      (br_if $av_rounds_exit
        (i32.ge_u (local.get $round) (i32.const 2))
      )

      (local.set $i (i32.const 0))
      (block $av_exit
        (loop $av_loop
          (br_if $av_exit
            (i32.ge_u (local.get $i) (i32.const 512))
          )

          ;; idx = laneBase + i * 4
          (local.set $idx
            (i32.add
              (local.get $laneBase)
              (i32.shl (local.get $i) (i32.const 2))
            )
          )

          ;; idxNext = laneBase + ((i+17)&511) * 4
          (local.set $idxNext
            (i32.add
              (local.get $laneBase)
              (i32.shl
                (i32.and
                  (i32.add (local.get $i) (i32.const 17))
                  (i32.const 511)
                )
                (i32.const 2)
              )
            )
          )

          ;; h = load h[i]
          (local.set $h
            (i32.load (local.get $idx))
          )

          ;; v = h[(i+17)&511]
          (local.set $v
            (i32.load (local.get $idxNext))
          )

          ;; h ^= v * C3
          (local.set $h
            (i32.xor
              (local.get $h)
              (i32.mul (local.get $v) (i32.const 0x165667b1))
            )
          )

          ;; h = rotl(h, 13)
          (local.set $h
            (i32.rotl (local.get $h) (i32.const 13))
          )

          ;; store back
          (i32.store (local.get $idx) (local.get $h))

          (local.set $i (i32.add (local.get $i) (i32.const 1)))
          (br $av_loop)
        )
      )

      (local.set $round (i32.add (local.get $round) (i32.const 1)))
      (br $av_rounds_loop)
    )
  )

  ;; ---------------------------------------------------------
  ;; 5) Write 512 lanes (2048 bytes) to outputBase
  ;; ---------------------------------------------------------
  (local.set $i (i32.const 0))
  (block $out_exit
    (loop $out_loop
      (br_if $out_exit
        (i32.ge_u (local.get $i) (i32.const 512))
      )

      ;; h = load lane i
      (local.set $h
        (i32.load
          (i32.add
            (local.get $laneBase)
            (i32.shl (local.get $i) (i32.const 2))
          )
        )
      )

      ;; store to outBase + i*4
      (i32.store
        (i32.add
          (local.get $outBase)
          (i32.shl (local.get $i) (i32.const 2))
        )
        (local.get $h)
      )

      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $out_loop)
    )
  )
)
