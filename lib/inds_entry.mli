module Make(Entry : S.ENTRY_ELIGIBLE) : sig
  include S.ENTRY with type entry = Entry.t
end
