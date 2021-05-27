(module

(import "console" "log" (func $log(param i32) (param i32)))
(import "math" "rand" (func $rand(result f32)))



(memory (export "mem") 2) ;;64KB pages

(global $alive i32 (i32.const 0xFF0000FF))
(global $dying  i32 (i32.const 0xFF00FF00))
(global $dead i32 (i32.const 0x1FFFFFFF))

(global $colors (mut i32)(i32.const 0xff))
(global $inited (mut i32)(i32.const 0x00));;//set when game initialized
;;block $started 


(func $clear (param $color i32)
    (local $i i32);;define a local variable
     (loop $loop
        (i32.store offset=0x0            
            (local.get $i) (local.get $color)) ;;//store color at 0x0000 + $i
        (local.set $i
            (i32.add (local.get $i) (i32.const 4))) ;;"shorthand"
        (br_if $loop
            (i32.lt_s (local.get $i) (i32.const 90000)))
     )   
     (global.set $inited (i32.const 1))
)
(func (export "run")        
    
    block $b0
        global.get $inited
        i32.const 0
        i32.gt_s
        br_if $b0        
            (call $clear
                (global.get $dead) 
            )
            (drop (call $loop))
    end    
    
)






(func $rnd (result i32) ;;//get random cell row or col - base = 150
    (f32.mul (f32.const 150) (call $rand))
    i32.trunc_f32_u
)


(func $loop (result i32) ;;color random pixels
    (local $lps i32)
    (local.set $lps (i32.const 0))
    block $p
        loop $lo
            (call $colorcell (call $rnd)(call $rnd)(i32.const 0xff_00_FF_00))            
            (local.tee $lps (i32.add(local.get $lps)(i32.const 1)) )            
            i32.const 10 ;; start with 10 
            i32.lt_s
            br_if $lo
        end
        
    end
    i32.const 99
)



(func $cell (param $row i32) (param $col i32) (param $color i32)
    (local $off i32)
    ;;(call $log(local.get $off) (i32.const 22))
    ;;;600 per rows = 75
    (local.set $off (i32.mul (local.get $row)(i32.const 600)))
    ;;(local.set $off (i32.mul (local.get $row)(local.get $col)))
    ;;(call $log(local.get $off) (i32.const 22))
    (local.set $off (i32.add (local.get $off) (local.get $col)))
    (call $log(local.get $off) (call $celladdress(i32.const 2)(i32.const 8)))
    (i32.store offset=0x00
        (local.get $off) (local.get $color))
)

(func $colorcell (param $row i32) (param $col i32) (param $color i32)
    ;;(call $log(i32.const 0xFF)(call $celladdress (local.get $row)(local.get $col)))
    (i32.store offset=0x00 (call $celladdress (local.get $row)(local.get $col))(local.get $color))
    nop
)


(func $celladdress (param $row i32) (param $col i32) (result i32)    
    ;;;600 per rows = 75
    (i32.mul (local.get $row) (i32.const 0x258))
    (i32.add (i32.mul (local.get $col)(i32.const 0x4)))
)

);;module

