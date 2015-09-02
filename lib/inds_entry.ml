module Make(Entry: Inds_types.ENTRY_ELIGIBLE) = struct

  type result = [ `Ok of Entry.t | `Timeout ]
  type entry = Entry.t
  type t = 
    | Confirmed of int * Entry.t

  let make_confirmed time entry = Confirmed (time, entry)

  let to_json = function
    | Confirmed (time, entry) -> 
      let expiry = Ezjsonm.int time in
      let entry = Ezjsonm.string (Entry.to_string entry) in
      Ezjsonm.dict [("expiry", expiry); ("entry", entry)]

  let of_json (json : Ezjsonm.value) = match json with
    | `A _ | `Null | `Bool _ | `Float _ | `String _ ->
      raise (Invalid_argument "entry.of_json expects a dictionary,
      but was given some other json")
    | `O items ->
        let open Ezjsonm in
          match (Entry.of_string (get_string (find (dict items) ["entry"]))) with
          | None -> raise (Invalid_argument "parse failure in an entry")
          | Some address -> (
            let expiry = get_int (find (dict items) ["expiry"]) in
            Confirmed (expiry, address))

  let compare p q =
    match (p, q) with
    | Confirmed (p_time, _), Confirmed (q_time, _) -> compare p_time q_time

  let make_confirmed f m = Confirmed (f, m)

end
