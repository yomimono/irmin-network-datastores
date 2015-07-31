module type ENTRY_ELIGIBLE = sig
  type t
  val compare : t -> t -> int
  val to_string : t -> string
  val of_string : string -> t option
end

module type ENTRY = sig

  type entry
  type t = 
    | Confirmed of float * entry

  type result = [ `Ok of entry | `Timeout ]

  val to_string : t -> string
  val to_json : t -> Ezjsonm.value
  val of_json : Ezjsonm.value -> t option
  val compare : t -> t -> int
  val make_confirmed : float -> entry -> t
end

