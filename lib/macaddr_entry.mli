module Make(Entry : Expiring_entry.C_S) : sig
  include Expiring_entry.ENTRY with type entry = Entry.t
end
