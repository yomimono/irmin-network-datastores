module Make (Key: Inds_types.KEY) (Entry: Inds_types.ENTRY) (P: Irmin.Path.S) : sig
  module M : Map.S with type key = Key.t
  module Ops : sig
    include Tc.S0 with type t = Entry.t M.t (* map from ip -> entry *)
  end
  include Irmin.Contents.S with module Path = P
  val to_map : t -> Entry.t M.t
  val of_map : Entry.t M.t -> t
  val add : Key.t -> Entry.t -> t -> t
  val remove : Key.t -> t -> t
  val find : Key.t -> t -> Entry.t
  val mem : Key.t -> t -> bool
  val empty : t
  val expire : t -> int -> t
end
