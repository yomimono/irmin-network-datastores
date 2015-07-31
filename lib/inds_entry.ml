module Make(Entry: S.ENTRY_ELIGIBLE) = struct

  type result = [ `Ok of Entry.t | `Timeout ]
  type entry = Entry.t
  type t = 
    | Confirmed of float * Entry.t

  let make_confirmed time mac = Confirmed (time, mac)

  let to_string = function
    | Confirmed (time, mac) -> Printf.sprintf "%s expiring at %f"
                                 (Entry.to_string mac) time

  let to_json = function
    | Confirmed (time, mac) -> 
      let expiry = Ezjsonm.float time in
      let mac = Ezjsonm.string (Entry.to_string mac) in
      Ezjsonm.dict [("expiry", expiry); ("mac", mac)]

  let of_json (json : Ezjsonm.value) : t option = match json with
    | `A _ | `Null | `Bool _ | `Float _ | `String _ -> None
    | `O items ->
        let open Ezjsonm in
          match (Entry.of_string (get_string (find (dict items) ["mac"]))) with
          | None -> None
          | Some address -> (
            let expiry = get_float (find (dict items) ["expiry"]) in
            Some (Confirmed (expiry, address)) )

  let compare p q =
    match (p, q) with
    | Confirmed (p_time, _), Confirmed (q_time, _) -> compare p_time q_time

  let make_confirmed f m = Confirmed (f, m)

end
