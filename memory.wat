(module
  (memory 1) ;; Initialize 1 page (64KB)
  (func $nuke
    (loop $more
      (memory.grow (i32.const 1)) ;; Request another 64KB page
      drop                         ;; Discard growth result
      br $more                     ;; Repeat until crash
    )
  )
  (export "nuke" (func $nuke))
)
