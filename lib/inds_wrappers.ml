module Macaddr_entry : sig
  include Inds_types.ENTRY_ELIGIBLE with type t = Macaddr.t
end = struct
  type t = Macaddr.t
  let compare = Macaddr.compare
  let to_string = Macaddr.to_string ~sep:':' (* a lot of work for a sep:':'! *)
  let of_string = Macaddr.of_string
end
