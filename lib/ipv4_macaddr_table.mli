module Make(P: Irmin.Path.S) : sig
  module M : Map.S with type key = Ipaddr.V4.t
  module Ops : sig
    include Tc.S0 with type t = Macaddr_entry.t M.t (* map from ip -> entry *)
  end
  include Irmin.Contents.S with module Path = P
  val to_map : t -> Macaddr_entry.t M.t
  val of_map : Macaddr_entry.t M.t -> t
  val add : Ipv4_key.t -> Macaddr_entry.t -> t -> t
  val remove : Ipv4_key.t -> t -> t
  val find : Ipv4_key.t -> t -> Macaddr_entry.t
  val empty : t
  val expire : t -> float -> t
end
