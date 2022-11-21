open! Core

module Test1 = struct
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

let%expect_test "test 1.2" =
  Record_array.num_fields
  |> printf !"%{sexp: int}";
  [%expect {| 3 |}]

end 

module Test2 = struct
type t = {
  only_field: float;
}[@@deriving equal, array]

let%expect_test "test 2.0" =
  Record_array.to_array { only_field = 3.14159 }
  |> printf !"%{sexp: float array}";
  [%expect {| (3.14159) |}]
end