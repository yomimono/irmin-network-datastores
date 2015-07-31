module Make(Key : S.KEY_ELIGIBLE) : sig
  include Tc.S0 with type t = Key.t
  val of_string : string -> t option
  val to_string : t -> string
end
