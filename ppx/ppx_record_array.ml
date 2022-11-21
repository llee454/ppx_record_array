open! Core
open! Ppxlib
open! Ast_builder.Default

let get_field_spec (ld : label_declaration) = ld.pld_name.txt

let get_num_fields_def ~loc specs =
  [%stri let num_fields = [%e eint ~loc (List.length specs)]]

let get_to_array_def ~loc specs =
  let rhs = List.map ~f:(evar ~loc) specs |> pexp_array ~loc in
  let pat = ppat_record ~loc (List.map ~f:(fun s -> ({ txt = Lident s; loc = loc }, pvar ~loc s)) specs) Closed in
  [%stri let to_array [%p pat] = [%e rhs]]
  [@@warning "-26"]

let get_of_array_def ~loc specs =
  let pat = List.map ~f:(pvar ~loc) specs |> ppat_array ~loc in
  let rhs = pexp_record ~loc (List.map ~f:(fun s -> ({ txt = Lident s; loc = loc }, evar ~loc s)) specs) None in
  [%stri let of_array = function | [%p pat] -> [%e rhs] | xs -> failwiths ~here:[%here] "Invalid array" xs [%sexp_of: float array]]
  [@@warning "-26"]

let generate_impl ~ctxt (_rec_flag, type_declarations) =
  let loc = Expansion_context.Deriver.derived_item_loc ctxt in
  let items =
    List.map type_declarations ~f:(fun (td : type_declaration) ->
        match td with
        | { ptype_kind = Ptype_abstract | Ptype_variant _ | Ptype_open; ptype_loc; _ } ->
          let ext = Location.raise_errorf ~loc:ptype_loc "Cannot derive accessors for non record types" in
          [ Ast_builder.Default.pstr_extension ~loc ext [] ]
        | { ptype_kind = Ptype_record fields; _ } ->
          let specs = List.map fields ~f:get_field_spec in
          [
            get_num_fields_def ~loc specs;
            get_to_array_def ~loc specs;
            get_of_array_def ~loc specs
          ])
    |> List.concat
  in
  [
    {
      pstr_desc =
        Pstr_module
          (module_binding ~loc ~name:{ txt = Some "Record_array"; loc }
             ~expr:{ pmod_desc = Pmod_structure items; pmod_loc = loc; pmod_attributes = [] });
      pstr_loc = loc;
    };
  ]

let generate_intf ~ctxt:_ (_rec_flag, _type_declarations) : signature_item list = []

let impl_generator = Deriving.Generator.V2.make_noarg generate_impl

let intf_generator = Deriving.Generator.V2.make_noarg generate_intf

let ppx_validation = Deriving.add "array" ~str_type_decl:impl_generator ~sig_type_decl:intf_generator
