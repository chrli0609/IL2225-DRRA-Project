#cd into the specific partition
read_db .

place_design
ccopt_design
route_design

write_db ./pnr/
write_ilm
