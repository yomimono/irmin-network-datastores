module Macaddr_entry : sig
  include Inds_types.ENTRY_ELIGIBLE with type t = Macaddr.t
end = struct
  type t = Macaddr.t
  let compare = Macaddr.compare
  let to_string = Macaddr.to_string ~sep:':' (* a lot of work for a sep:':'! *)
  let of_string = Macaddr.of_string
end

module Ipv4addr_key : sig
  include Inds_types.KEY_ELIGIBLE with type t = Ipaddr.V4.t
  val of_json : Ezjsonm.value -> t
  val to_json : t -> Ezjsonm.value
end = struct
  include Ipaddr.V4
  let size_of addr = Ipaddr.V4.to_string addr |> String.length
  let of_json = function
    | `String s -> Ipaddr.V4.of_string_exn s
    | _ -> raise (Invalid_argument "invalid json presented to ipv4")

  let to_json t =
    Ezjsonm.from_string (Ipaddr.V4.to_string t)
end
