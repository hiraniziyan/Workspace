# Run Instructions

---

## python
To run, type:

```bash
python3 collatz.py <start> <end>
```

## fortran

To compile, type: 
```bash
gfortran collatz.f90
```
To run, type: 
```bash
./a.out <start> <finish>
```

# recursedFortran

To compile, type: 
```bash
gfortran -O3 -o rec_collatz rec_collatz.f90
```

To run, type:
```bash
./rec_collatz <start> <finish>
```

## julia

To run, type:
```bash
julia collatz.jl <start> <finish>
```

## recursedJulia

To run, type: 
```bash
julia rec_collatz.jl <start> <finish>
```

## lisp

To run, type:
```bash
sbcl --script collatz.lisp <start> <finish>
```

## recursedLisp

To run, type:
```bash
sbcl --script rec_collatz.lisp <start> <finish>
```

## rust

To run, type:
```bash
cargo run --release -- <start> <finish>
```

## recursedRust

To run, type:
```bash
cargo run --release -- <start> <finish>
```

