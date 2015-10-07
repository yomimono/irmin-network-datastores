module Make(Entry: Inds_types.ENTRY_ELIGIBLE) = struct

  type result = [ `Ok of Entry.t | `Timeout ]
  type entry = Entry.t
  type t = 
    | Confirmed of int * Entry.t

  let entry_key = "entry"
  let expiry_key = "expiry"

  let make_confirmed time entry = Confirmed (time, entry)

  let to_json = function
    | Confirmed (time, entry) -> 
      let expiry = Ezjsonm.int time in
      let entry = Ezjsonm.string (Entry.to_string entry) in
      Ezjsonm.dict [(expiry_key, expiry); (entry_key, entry)]

  let of_json (json : Ezjsonm.value) = match json with
    | `A _ | `Null | `Bool _ | `Float _ | `String _ ->
      raise (Tc.Read_error "semantically unparseable json")
    | `O items ->
        let open Ezjsonm in
          match (Entry.of_string (get_string (find (dict items) [entry_key]))) with
          | None -> raise (Tc.Read_error "semantically unparseable json")
          | Some address -> (
            let expiry = get_int (find (dict items) [expiry_key]) in
            Confirmed (expiry, address))

  let compare p q =
    match (p, q) with
    | Confirmed (p_time, _), Confirmed (q_time, _) -> compare p_time q_time

  let make_confirmed f m = Confirmed (f, m)

  let size_of (Confirmed (time, entry)) =
    let out = string_of_int time ^ " " ^ (Entry.to_string entry) in
    String.length out

  let write (Confirmed (time, entry)) buf =
    let out = string_of_int time ^ " " ^ (Entry.to_string entry) in
    Cstruct.blit_from_string out 0 buf 0 (String.length out);
    buf

  let read buf =
    match Mstruct.get_delim buf ' ' (fun b -> int_of_string (Mstruct.to_string b))with
    | None -> raise (Tc.Read_error "unparseable entry")
    | Some time ->
      (* get_delim shifts the buffer to after the occurrence of the delimiter *)
      match Entry.of_string (Mstruct.to_string buf) with
      | None -> raise (Tc.Read_error "unparseable entry")
      | Some t -> Confirmed (time, t)

end
