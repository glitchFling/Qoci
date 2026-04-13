(module
  ;; 1. Allocate 510MB (8160 pages * 64KiB)
  ;; Format: (memory $name initial_pages)
  (memory (export "memory") 8160)

  ;; 2. Iteration Function
  (func (export "iterate_memory")
    (local $ptr i32)   ;; Current memory address (pointer)
    (local $end i32)   ;; End address (510 * 1024 * 1024)
    
    ;; Set end boundary: 534,773,760 bytes
    (local.set $end (i32.const 534773760))
    (local.set $ptr (i32.const 0))

    (loop $loop
      ;; Store the value 1 at the current pointer address
      ;; (i32.store8 address value)
      (i32.store8 (local.get $ptr) (i32.const 1))

      ;; Increment pointer by 1 byte
      (local.set $ptr (i32.add (local.get $ptr) (i32.const 1)))

      ;; Branch back to $loop if $ptr < $end
      (br_if $loop (i32.lt_u (local.get $ptr) (local.get $end)))
    )
  )
)
