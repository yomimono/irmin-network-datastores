open Test_lib
module Macaddr_entry = Inds_entry.Make(Inds_wrappers.Macaddr_entry)

let arbitrary_mac_entry =
  let open QuickCheck_gen in
  Arbitrary.arbitrary_mac >>= fun mac ->
  QuickCheck.arbitrary_int >>= fun time ->
  ret_gen (Macaddr_entry.make_confirmed time mac)

(* verify that store/read of a single key/value pair when no previous mapping
   existed preserves meaning *)
(* this is actually a test of read/write for values, which could be a
   property test *)
let check_macs =
  QuickCheck.(quickCheck (testable_fun Arbitrary.arbitrary_mac
                            (Macaddr.to_string ~sep:':') testable_bool))

let check_addrs =
  QuickCheck.(quickCheck (testable_fun Arbitrary.arbitrary_ipv4
                            Ipaddr.V4.to_string testable_bool))

let check_entries =
  let str_of_value v = Ezjsonm.to_string (Ezjsonm.wrap v) in
  let show entry = str_of_value (Macaddr_entry.to_json entry) in
  QuickCheck.(quickCheck (testable_fun arbitrary_mac_entry show testable_bool))

let assert_succeeds =
  OUnit.assert_equal ~printer:Arbitrary.qc_printer QuickCheck.Success

let test_json_ipv4_keys () =
  let prop_json_lossless ipv4 =
    let module K = Inds_key.Make(Inds_wrappers.Ipv4addr_key) in
    (Ipaddr.V4.compare ipv4 (K.of_json (K.to_json ipv4))) = 0
  in
  assert_succeeds (check_addrs prop_json_lossless)

let test_json_mac_keys () =
  let prop_json_lossless mac =
    let module K = Inds_key.Make(Inds_wrappers.Macaddr_entry) in
    (Macaddr.compare mac (K.of_json (K.to_json mac))) = 0
  in
  assert_succeeds (check_macs prop_json_lossless)

let test_json_mac_entries () =
  let prop_json_lossless entry =
    Macaddr_entry.(compare entry (of_json (to_json entry))) = 0
  in
  assert_succeeds (check_entries prop_json_lossless)

let prop_key_rw_lossless (type t) (module K : Inds_types.KEY_ELIGIBLE with type t = t) (t : t) =
  let module Key = Inds_key.Make(K) in
  let buf = Cstruct.create (Key.size_of t) in
  Cstruct.memset buf 0;
  let _ = Key.write t buf in
  Key.compare t (Key.read (Mstruct.of_cstruct buf)) = 0

let prop_entry_rw_lossless t =
  let buf = Cstruct.create (Entry.size_of t) in
  Cstruct.memset buf 0;
  let _ = Entry.write t buf in
  Entry.compare t (Entry.read (Mstruct.of_cstruct buf)) = 0

let test_rw_ipv4_keys () =
  assert_succeeds (check_addrs (prop_key_rw_lossless (module Inds_wrappers.Ipv4addr_key)))

let test_rw_mac_keys () =
  assert_succeeds (check_macs (prop_key_rw_lossless (module Inds_wrappers.Macaddr_entry)))

let test_rw_mac_entries () =
  assert_succeeds (check_entries prop_entry_rw_lossless)

let test_empty_json_read () =
  OUnit.assert_raises (Tc.Read_error "semantically unparseable json") (fun () -> Entry.of_json (Ezjsonm.unit ()))

let test_empty_buffer () =
  OUnit.assert_raises (Tc.Read_error "unparseable entry") (fun () -> Entry.read (Mstruct.create 0))

let () =
  let bad_reads = [
    "empty_json", `Quick, test_empty_json_read;
    "empty_buffer", `Quick, test_empty_buffer;
  ] in
  let json = [ 
    "json_ipv4_keys", `Quick, test_json_ipv4_keys;
    "json_mac_keys", `Quick, test_json_mac_keys;
    "json_mac_entries", `Quick, test_json_mac_entries;
  ] in
  let read_write = [
    "rw_ipv4_keys", `Quick, test_rw_ipv4_keys;
    "rw_mac_keys", `Quick, test_rw_mac_keys;
    "rw_mac_entries", `Quick, test_rw_mac_entries;
  ] in
  Alcotest.run "Irmin_arp.Ops" [
    "bad_reads", bad_reads;
    "from_to_json", json;
    "from_to_buffer", read_write;
  ]
