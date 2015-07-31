module Make(Entry : Expiring_entry.ENTRY_ELIGIBLE) : sig
  include Expiring_entry.ENTRY with type entry = Entry.t
end
