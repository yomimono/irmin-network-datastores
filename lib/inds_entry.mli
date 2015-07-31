module Make(Entry : Inds_types.ENTRY_ELIGIBLE) : sig
  include Inds_types.ENTRY with type entry = Entry.t
end
