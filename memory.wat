(module
  ;; 1. Allocate 1GB of linear memory (16384 pages * 64KiB)
  ;; This ensures the "Bot-Killer" RAM pressure is available.
  (memory (export "memory") 16384)

  ;; 2. The iteration function
  ;; Takes $byteLimit as an argument from JavaScript
  (func (export "iterate_memory") (param $byteLimit i32)
    (local $ptr i32)
    
    ;; Initialize pointer at start of memory
    (local.set $ptr (i32.const 0))

    ;; Safety block: If JS passes 0, we skip the loop entirely
    (block $exit
      (br_if $exit (i32.eq (local.get $byteLimit) (i32.const 0)))
      
      ;; Start of the heavy iteration loop
      (loop $loop
        ;; Store the byte value 1 at current pointer address
        (i32.store8 (local.get $ptr) (i32.const 1))

        ;; Increment pointer by 1 byte
        (local.set $ptr (i32.add (local.get $ptr) (i32.const 1)))

        ;; Comparison: Loop back if $ptr < $byteLimit
        (br_if $loop (i32.lt_u (local.get $ptr) (local.get $byteLimit)))
      )
    )
  )
)
