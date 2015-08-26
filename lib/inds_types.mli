module type SERIALIZABLE = sig
  type t
  val to_string : t -> string
  val of_string : string -> t option
end

module type ENTRY_ELIGIBLE = sig
  include Map.OrderedType
  include SERIALIZABLE with type t := t
end

module type ENTRY = sig
  type entry
  type t = | Confirmed of int * entry
  type result = [ `Ok of entry | `Timeout ]
  val of_json : Ezjsonm.value -> t option
  val to_json : t -> Ezjsonm.value
  val compare : t -> t -> int
  val to_string : t -> string
  val make_confirmed : int -> entry -> t
end

module type KEY_ELIGIBLE = sig
  include Map.OrderedType
  include SERIALIZABLE with type t := t
end

module type KEY = sig
  include Map.OrderedType
  include KEY_ELIGIBLE with type t := t
  val to_json : t -> Ezjsonm.value
  val of_json : Ezjsonm.value -> t
  val read : t Tc.reader
  val write : t Tc.writer
  val size_of : t -> int
end
