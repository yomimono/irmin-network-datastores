module Make(Entry: Expiring_entry.ENTRY) (P: Irmin.Path.S) : sig
  module M : Map.S with type key = Ipaddr.V4.t
  module Ops : sig
    include Tc.S0 with type t = Entry.t M.t (* map from ip -> entry *)
  end
  include Irmin.Contents.S with module Path = P
  val to_map : t -> Entry.t M.t
  val of_map : Entry.t M.t -> t
  val add : Ipv4_key.t -> Entry.t -> t -> t
  val remove : Ipv4_key.t -> t -> t
  val find : Ipv4_key.t -> t -> Entry.t
  val empty : t
  val expire : t -> float -> t
end
