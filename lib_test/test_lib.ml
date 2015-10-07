module Entry = Inds_entry.Make(Inds_wrappers.Macaddr_entry)
module Key = Inds_key.Make(Inds_wrappers.Ipv4addr_key)

let parse ip mac time = (Ipaddr.V4.of_string_exn ip, Macaddr.of_string_exn
                           mac, time)
let confirm time mac = Entry.make_confirmed time mac

let ip1_str, mac1_str = "192.168.3.11", "10:9a:dd:00:00:11"
let ip2_str, mac2_str = "192.168.3.22", "00:16:3e:00:00:22"
let ip3_str, mac3_str = "192.168.3.50", "a0:23:4a:00:00:50"

let ip1, mac1, time1 = parse ip1_str mac1_str 0
let ip2, mac2, time2 = parse ip2_str mac2_str 1
let ip3, mac3, time3 = parse ip3_str mac3_str 2
