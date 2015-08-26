(* provide Tc.S0 stuff for Key *)
module Make(Key : Inds_types.KEY_ELIGIBLE) = struct
  include Key

  let read buf =
    let raw = Mstruct.to_string buf in
    match Key.of_string raw with
    | Some key -> key
    | None -> raise (Tc.Read_error raw)

  let write k buf = 
    let s  = Key.to_string k in
    Cstruct.blit_from_string s 0 buf 0 (String.length s);
    Cstruct.sub buf (String.length s) (Cstruct.len buf - (String.length s))

  let size_of k = String.length (Key.to_string k)

  let to_json k = Ezjsonm.string (Key.to_string k)

  let of_json = function
    | `Null | `Bool _ | `O _ | `A _ | `Float _ ->
      raise (Tc.Read_error "structurally invalid json")
    | `String s ->
      match Key.of_string s with
      | None -> raise (Tc.Read_error "semantically invalid json")
      | Some key -> key

  let hash = Hashtbl.hash
  let equal p q = ((Key.compare p q) = 0)
end
