wait_for_session_exit() {
    local session_name=$1

    while tmux has-session -t "$session_name" 2>/dev/null; do
        sleep 1
    done
}

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'source ../phy/scr/create_partitions.tcl' Enter
tmux send-keys -t innovus_session 'exit' Enter

tmux new-session -d -s innovus_session_0 'innovus -stylus'
tmux send-keys -t innovus_session_0 'cd ../phy/db/part/Silago_top_left_corner.enc.dat/' Enter
tmux send-keys -t innovus_session_0 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session_0 'exit' Enter
# wait_for_session_exit innovus_session

tmux new-session -d -s innovus_session_1 'innovus -stylus'
tmux send-keys -t innovus_session_1 'cd ../phy/db/part/Silago_bot_left_corner.enc.dat/' Enter
tmux send-keys -t innovus_session_1 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session_1 'exit' Enter
# wait_for_session_exit innovus_session

tmux new-session -d -s innovus_session_2 'innovus -stylus'
tmux send-keys -t innovus_session_2 'cd ../phy/db/part/Silago_top.enc.dat/' Enter
tmux send-keys -t innovus_session_2 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session_2 'exit' Enter
# wait_for_session_exit innovus_session

tmux new-session -d -s innovus_session_3 'innovus -stylus'
tmux send-keys -t innovus_session_3 'cd ../phy/db/part/Silago_bot.enc.dat/' Enter
tmux send-keys -t innovus_session_3 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session_3 'exit' Enter
# wait_for_session_exit innovus_session

for i in  {1..5}; do
	tmux new-session -d -s "innovus_session_top_$i" 'innovus -stylus'
	tmux send-keys -t "innovus_session_top_$i" "cd ../phy/db/part/Silago_top_SPC_$i.enc.dat/" Enter
	tmux send-keys -t "innovus_session_top_$i" 'source ../../../scr/pnr_partition.tcl' Enter
	tmux send-keys -t "innovus_session_top_$i" 'exit' Enter
	# wait_for_session_exit innovus_session_top
	
	tmux new-session -d -s "innovus_session_bot_$i" 'innovus -stylus'
	tmux send-keys -t "innovus_session_bot_$i" "cd ../phy/db/part/Silago_bot_SPC_$i.enc.dat/" Enter
	tmux send-keys -t "innovus_session_bot_$i" 'source ../../../scr/pnr_partition.tcl' Enter
	tmux send-keys -t "innovus_session_bot_$i" 'exit' Enter
	# wait_for_session_exit innovus_session_bot
done

tmux new-session -d -s innovus_session_4 'innovus -stylus'
tmux send-keys -t innovus_session_4 'cd ../phy/db/part/Silago_top_right_corner.enc.dat/' Enter
tmux send-keys -t innovus_session_4 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session_4 'exit' Enter
# wait_for_session_exit innovus_session

tmux new-session -d -s innovus_session_5 'innovus -stylus'
tmux send-keys -t innovus_session_5 'cd ../phy/db/part/Silago_bot_right_corner.enc.dat/' Enter
tmux send-keys -t innovus_session_5 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session_5 'exit' Enter
# wait_for_session_exit innovus_session

# tmux new-session -d -s innovus_session 'innovus -stylus'
# tmux send-keys -t innovus_session 'source ../phy/scr/pnr_top.tcl' Enter
# tmux send-keys -t innovus_session 'exit' Enter
# wait_for_session_exit innovus_session
# 
# tmux new-session -d -s innovus_session 'innovus -stylus'
# tmux send-keys -t innovus_session 'source ../phy/scr/assembly_design.tcl' Enter
