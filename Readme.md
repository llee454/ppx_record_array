# Record Array PPX

The record array PPX allows developers to define records comprised of
float fields and automatically generates functions that convert these
records into arrays and vice versa.

## Examples

```ocaml
type t = {
  a: float;
  b: float;
  c: float;
}
[@@deriving equal, array]

let%expect_test "test 1.0" =
  Record_array.to_array { a = 1.0; b = 2.0; c = 3.0 }
  |> printf !"%{sexp: float array}";
  [%expect {| (1 2 3) |}]

let%expect_test "test 1.1" =
  let open Record_array in
  let x = { a = Random.float 5.0; b = Random.float 5.0; c = Random.float 5.0 } in
  to_array x |> of_array |> [%equal: t] x
  |> printf !"%{sexp: bool}";
  [%expect {| true |}]
```

Given a record type that only contains float fields and has the
`array` deriver attached, this PPX will generate a module named
`Record_array` that contains two functions: `to_array` and `of_array`.
These functions can be used to efficiently convert the record into and
arrays and vice versa.

Additionally, `Record_array` defines a constant, `num_fields`, that
gives the number fields contained in the record/array.


## Initializing the Build Environment

opam switch create . ocaml-variants.4.14.0+options
opam update
opam install --deps-only .
