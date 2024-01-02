tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'source ../phy/scr/create_partitions.tcl' Enter
tmux send-keys -t innovus_session 'exit' Enter

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_top_left_corner.enc.dat/' Enter
tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session 'exit' Enter

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_bot_left_corner.enc.dat/' Enter
tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session 'exit' Enter

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_top.enc.dat/' Enter
tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session 'exit' Enter

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_bot.enc.dat/' Enter
tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session 'exit' Enter

for i in  {1..5}; do
	tmux new-session -d -s innovus_session 'innovus -stylus'
	tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_top_SPC_$i.enc.dat/' Enter
	tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
	tmux send-keys -t innovus_session 'exit' Enter
	
	tmux new-session -d -s innovus_session 'innovus -stylus'
	tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_bot_SPC_$i.enc.dat/' Enter
	tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
	tmux send-keys -t innovus_session 'exit' Enter
done

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_top_right_corner.enc.dat/' Enter
tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session 'exit' Enter

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_bot_right_corner.enc.dat/' Enter
tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session 'exit' Enter

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'source ../phy/scr/pnr_top.tcl' Enter
tmux send-keys -t innovus_session 'exit' Enter

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'source ../phy/scr/assembly_design.tcl' Enter
